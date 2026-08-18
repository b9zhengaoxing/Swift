import CoreGraphics
import Foundation
import Vision

public struct JisiluOCRTextLine {
    public let text: String
    public let boundingBox: CGRect

    public init(text: String, boundingBox: CGRect = .zero) {
        self.text = text
        self.boundingBox = boundingBox
    }
}

public struct JisiluImageImportResult {
    public let sourceImageURL: URL
    public let ownerName: String
    public let sourceModifiedAt: Date
    public let fileURL: URL
    public let metadata: JisiluMetadata
    public let records: [JisiluHoldingRecord]
}

private enum JisiluImageImportError: LocalizedError {
    case imageNotFound(String)
    case visionUnavailable(String)
    case missingTotalAssets
    case noHoldingRows(String)
    case noImageFolder(String)
    case noImageFile(String)
    case missingModificationDate(String)
    case cannotWrite(String)

    var errorDescription: String? {
        switch self {
        case .imageNotFound(let path):
            return "找不到持仓截图：\(path)"
        case .visionUnavailable(let reason):
            return "无法识别持仓截图：\(reason)"
        case .missingTotalAssets:
            return "持仓截图中没有识别到总资产"
        case .noHoldingRows(let fileName):
            return "持仓截图中没有识别到股票持仓：\(fileName)"
        case .noImageFolder(let path):
            return "找不到 image 文件夹：\(path)"
        case .noImageFile(let path):
            return "image 文件夹内没有可识别的图片：\(path)"
        case .missingModificationDate(let path):
            return "无法读取图片修改时间：\(path)"
        case .cannotWrite(let path):
            return "无法写入 Jisilu XLS：\(path)"
        }
    }
}

public enum JisiluImageImporter {
    private static let supportedImageExtensions: Set<String> = [
        "jpg",
        "jpeg",
        "png",
        "heic",
        "heif",
        "tif",
        "tiff",
        "bmp"
    ]

    public static func importLatestImage(
        in folders: [URL]? = nil,
        outputFolder: URL? = nil,
        exportedAt: Date? = nil
    ) throws -> JisiluImageImportResult {
        let imageURL = try latestImageURL(in: folders ?? defaultImageFolders())
        return try importImage(
            at: imageURL,
            outputFolder: outputFolder,
            exportedAt: exportedAt
        )
    }

    public static func importImage(
        at imageURL: URL,
        outputFolder: URL? = nil,
        exportedAt: Date? = nil
    ) throws -> JisiluImageImportResult {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(
            atPath: imageURL.path,
            isDirectory: &isDirectory
        ), !isDirectory.boolValue else {
            throw JisiluImageImportError.imageNotFound(imageURL.path)
        }

        let sourceModifiedAt = try imageModificationDate(at: imageURL)
        let effectiveExportedAt = exportedAt ?? sourceModifiedAt
        let ownerName = ownerName(from: imageURL)
        let lines = try recognizeTextLines(in: imageURL)
        let parsed = try parseOCRLines(
            lines,
            exportedAt: effectiveExportedAt,
            sourceName: imageURL.lastPathComponent
        )
        let destination = try writeXLS(
            metadata: parsed.metadata,
            records: parsed.records,
            to: outputFolder ?? defaultOutputFolder(),
            exportedAt: effectiveExportedAt,
            ownerName: ownerName
        )

        return JisiluImageImportResult(
            sourceImageURL: imageURL,
            ownerName: ownerName,
            sourceModifiedAt: sourceModifiedAt,
            fileURL: destination,
            metadata: parsed.metadata,
            records: parsed.records
        )
    }

    static func latestImageURL(in folders: [URL]) throws -> URL {
        var visitedFolderPaths = Set<String>()
        var foundFolder = false
        var latestFile: (url: URL, modifiedAt: Date)?

        for folderURL in folders {
            let folderPath = folderURL.standardizedFileURL.path
            guard visitedFolderPaths.insert(folderPath).inserted else {
                continue
            }

            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(
                atPath: folderURL.path,
                isDirectory: &isDirectory
            ), isDirectory.boolValue else {
                continue
            }
            foundFolder = true

            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )
            let candidates: [(url: URL, modifiedAt: Date)] = fileURLs.compactMap { url in
                guard supportedImageExtensions.contains(url.pathExtension.lowercased()) else {
                    return nil
                }
                let modifiedAt = (try? url.resourceValues(
                    forKeys: [.contentModificationDateKey]
                ).contentModificationDate) ?? .distantPast
                return (url, modifiedAt)
            }

            guard let folderLatest = candidates.max(by: { left, right in
                if left.modifiedAt != right.modifiedAt {
                    return left.modifiedAt < right.modifiedAt
                }
                return left.url.lastPathComponent < right.url.lastPathComponent
            }) else {
                continue
            }

            if let currentLatest = latestFile {
                if currentLatest.modifiedAt < folderLatest.modifiedAt
                    || (
                        currentLatest.modifiedAt == folderLatest.modifiedAt
                        && currentLatest.url.path < folderLatest.url.path
                    ) {
                    latestFile = folderLatest
                }
            } else {
                latestFile = folderLatest
            }
        }

        if let latestFile {
            return latestFile.url
        }

        let paths = folders.map(\.path).joined(separator: "，")
        throw foundFolder
            ? JisiluImageImportError.noImageFile(paths)
            : JisiluImageImportError.noImageFolder(paths)
    }

    static func parseOCRLines(
        _ rawLines: [JisiluOCRTextLine],
        exportedAt: Date,
        sourceName: String = "image"
    ) throws -> (metadata: JisiluMetadata, records: [JisiluHoldingRecord]) {
        let lines = normalizedLines(rawLines)
        guard let totalAssets = totalAssets(from: lines) else {
            throw JisiluImageImportError.missingTotalAssets
        }

        let records = holdingRecords(from: lines)
        guard !records.isEmpty else {
            throw JisiluImageImportError.noHoldingRows(sourceName)
        }

        return (
            JisiluMetadata(
                currentTotalAssets: totalAssets,
                exportedAt: exportedAt
            ),
            records
        )
    }

    @discardableResult
    static func writeXLS(
        metadata: JisiluMetadata,
        records: [JisiluHoldingRecord],
        to folderURL: URL,
        exportedAt: Date,
        ownerName: String? = nil
    ) throws -> URL {
        do {
            try FileManager.default.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true
            )
        } catch {
            throw JisiluImageImportError.cannotWrite(folderURL.path)
        }

        let fileURL = uniqueOutputURL(
            in: folderURL,
            exportedAt: exportedAt,
            ownerName: ownerName
        )
        let html = jisiluHTML(
            metadata: metadata,
            records: records,
            ownerName: ownerName
        )
        do {
            try html.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw JisiluImageImportError.cannotWrite(fileURL.path)
        }
        return fileURL
    }

    static func imageModificationDate(at imageURL: URL) throws -> Date {
        if let date = try imageURL.resourceValues(
            forKeys: [.contentModificationDateKey]
        ).contentModificationDate {
            return date
        }
        throw JisiluImageImportError.missingModificationDate(imageURL.path)
    }

    static func ownerName(from imageURL: URL) -> String {
        imageURL.deletingPathExtension().lastPathComponent
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func recognizeTextLines(in imageURL: URL) throws -> [JisiluOCRTextLine] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["zh-Hans", "en-US"]

        let handler = VNImageRequestHandler(url: imageURL)
        do {
            try handler.perform([request])
        } catch {
            throw JisiluImageImportError.visionUnavailable(error.localizedDescription)
        }

        guard let observations = request.results else {
            throw JisiluImageImportError.visionUnavailable("OCR 没有返回结果")
        }

        return observations.compactMap { observation in
            guard let text = observation.topCandidates(1).first?.string else {
                return nil
            }
            return JisiluOCRTextLine(text: text, boundingBox: observation.boundingBox)
        }
    }

    private static func defaultOutputFolder() -> URL {
        if let customPath = ProcessInfo.processInfo.environment["JISILU_FOLDER"],
           !customPath.isEmpty {
            return URL(fileURLWithPath: customPath, isDirectory: true)
        }

        let currentURL = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let packageURL = packageRootURL()
        let candidates = [
            currentURL.appendingPathComponent("Jisilu", isDirectory: true),
            currentURL.deletingLastPathComponent()
                .appendingPathComponent("Jisilu", isDirectory: true),
            packageURL.appendingPathComponent("Jisilu", isDirectory: true),
            packageURL.deletingLastPathComponent()
                .appendingPathComponent("Jisilu", isDirectory: true)
        ]

        if let existingFolder = candidates.first(where: { folderExists($0) }) {
            return existingFolder
        }
        return packageURL.deletingLastPathComponent()
            .appendingPathComponent("Jisilu", isDirectory: true)
    }

    private static func defaultImageFolders() -> [URL] {
        var folderURLs: [URL] = []

        if let customPath = ProcessInfo.processInfo.environment["JISILU_IMAGE_FOLDER"],
           !customPath.isEmpty {
            folderURLs.append(URL(fileURLWithPath: customPath, isDirectory: true))
        }

        let currentURL = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let packageURL = packageRootURL()
        folderURLs.append(currentURL.appendingPathComponent("image", isDirectory: true))
        folderURLs.append(
            currentURL.deletingLastPathComponent()
                .appendingPathComponent("image", isDirectory: true)
        )
        folderURLs.append(packageURL.appendingPathComponent("image", isDirectory: true))
        folderURLs.append(
            packageURL.deletingLastPathComponent()
                .appendingPathComponent("image", isDirectory: true)
        )
        return folderURLs
    }

    private static func packageRootURL() -> URL {
        // JisiluImageImporter.swift -> target -> Sources -> package root.
        var packageURL = URL(fileURLWithPath: #filePath)
        for _ in 0..<3 {
            packageURL.deleteLastPathComponent()
        }
        return packageURL
    }

    private static func folderExists(_ folderURL: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(
            atPath: folderURL.path,
            isDirectory: &isDirectory
        ) && isDirectory.boolValue
    }

    private static func normalizedLines(
        _ rawLines: [JisiluOCRTextLine]
    ) -> [JisiluOCRTextLine] {
        rawLines
            .map {
                JisiluOCRTextLine(
                    text: normalizeOCRText($0.text),
                    boundingBox: $0.boundingBox
                )
            }
            .filter { !$0.text.isEmpty }
            .sorted { left, right in
                if abs(left.boundingBox.midY - right.boundingBox.midY) > 0.003 {
                    return left.boundingBox.midY > right.boundingBox.midY
                }
                return left.boundingBox.minX < right.boundingBox.minX
            }
    }

    private static func totalAssets(from lines: [JisiluOCRTextLine]) -> Double? {
        for (index, line) in lines.enumerated()
            where compactText(line.text).contains("总资产")
                && !compactText(line.text).contains("总市值") {
            let inlineNumbers = decimalValues(in: line.text)
            if let inlineTotal = inlineNumbers.first(where: { $0 >= 1_000 }) {
                return inlineTotal
            }

            let belowCandidates = lines
                .dropFirst(index + 1)
                .filter {
                    isBelow($0, line)
                        && horizontalDistance($0, line) < 0.25
                }
                .prefix(8)

            for candidate in belowCandidates {
                if let value = decimalValues(in: candidate.text).first(where: { $0 >= 1_000 }) {
                    return value
                }
            }

            for candidate in lines.dropFirst(index + 1).prefix(8) {
                if let value = decimalValues(in: candidate.text).first(where: { $0 >= 1_000 }) {
                    return value
                }
            }
        }
        return nil
    }

    private static func holdingRecords(from lines: [JisiluOCRTextLine]) -> [JisiluHoldingRecord] {
        var records: [JisiluHoldingRecord] = []
        var seenCodes = Set<Int>()

        for (index, line) in lines.enumerated() {
            guard let codeText = firstStockCode(in: line.text), let code = Int(codeText) else {
                continue
            }
            guard seenCodes.insert(code).inserted else {
                continue
            }

            let name = holdingName(near: line, at: index, in: lines)
            let marketValue = marketValue(near: line, at: index, in: lines)
            guard let name, let marketValue else {
                continue
            }

            records.append(
                JisiluHoldingRecord(
                    name: name,
                    code: code,
                    marketValue: marketValue
                )
            )
        }

        return records
    }

    private static func holdingName(
        near codeLine: JisiluOCRTextLine,
        at index: Int,
        in lines: [JisiluOCRTextLine]
    ) -> String? {
        if let sameLineName = nameBeforeCode(in: codeLine.text) {
            return sameLineName
        }

        let candidates = lines
            .prefix(index)
            .reversed()
            .filter {
                isAbove($0, codeLine)
                    && $0.boundingBox.minX < 0.45
                    && !looksLikeHeader($0.text)
                    && firstStockCode(in: $0.text) == nil
            }

        for candidate in candidates.prefix(6) {
            if let name = cleanedHoldingName(candidate.text), !name.isEmpty {
                return name
            }
        }
        return nil
    }

    private static func marketValue(
        near codeLine: JisiluOCRTextLine,
        at index: Int,
        in lines: [JisiluOCRTextLine]
    ) -> Double? {
        let nearbyBelow = lines
            .dropFirst(index + 1)
            .filter {
                isBelow($0, codeLine)
                    && $0.boundingBox.minX < 0.55
                    && verticalDistance($0, codeLine) < 0.06
            }
            .prefix(6)

        for candidate in nearbyBelow {
            if let value = firstMarketValue(in: candidate.text) {
                return value
            }
        }

        for candidate in lines.dropFirst(index + 1).prefix(4) {
            if let value = firstMarketValue(in: candidate.text) {
                return value
            }
        }
        return nil
    }

    private static func firstMarketValue(in text: String) -> Double? {
        decimalMatches(in: text)
            .first { match in
                !match.text.contains("%") && match.value >= 100
            }?
            .value
    }

    private static func cleanedHoldingName(_ text: String) -> String? {
        let normalized = text
            .replacingOccurrences(of: "●", with: " ")
            .replacingOccurrences(of: "·", with: " ")
            .replacingOccurrences(of: "•", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = normalized.split(whereSeparator: { $0.isWhitespace })
        guard let first = parts.first else { return nil }

        let name = String(first)
            .trimmingCharacters(in: CharacterSet(charactersIn: ".,;:，。；："))
        guard
            !name.isEmpty,
            firstStockCode(in: name) == nil,
            decimalValues(in: name).isEmpty,
            !looksLikeHeader(name)
        else {
            return nil
        }
        return name
    }

    private static func nameBeforeCode(in text: String) -> String? {
        guard let range = text.range(
            of: #"(?<!\d)\d{6}(?!\d)"#,
            options: .regularExpression
        ) else {
            return nil
        }
        return cleanedHoldingName(String(text[..<range.lowerBound]))
    }

    private static func firstStockCode(in text: String) -> String? {
        guard let range = text.range(
            of: #"(?<!\d)\d{6}(?!\d)"#,
            options: .regularExpression
        ) else {
            return nil
        }
        return String(text[range])
    }

    private static func decimalValues(in text: String) -> [Double] {
        decimalMatches(in: text).map(\.value)
    }

    private static func decimalMatches(in text: String) -> [(text: String, value: Double)] {
        let pattern = #"-?\d{1,3}(?:,\d{3})+(?:\.\d+)?|-?\d+(?:\.\d+)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: text) else {
                return nil
            }
            let raw = String(text[matchRange])
            guard let value = Double(raw.replacingOccurrences(of: ",", with: "")) else {
                return nil
            }
            return (raw, value)
        }
    }

    private static func normalizeOCRText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "（", with: "(")
            .replacingOccurrences(of: "）", with: ")")
            .replacingOccurrences(of: "，", with: ",")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func compactText(_ text: String) -> String {
        text.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
    }

    private static func looksLikeHeader(_ text: String) -> Bool {
        let compacted = compactText(text)
        return compacted.contains("名称")
            || compacted.contains("市值")
            || compacted.contains("持仓")
            || compacted.contains("涨幅")
            || compacted.contains("盈亏")
            || compacted.contains("股票")
            || compacted.contains("总资产")
    }

    private static func isAbove(_ line: JisiluOCRTextLine, _ target: JisiluOCRTextLine) -> Bool {
        line.boundingBox.midY > target.boundingBox.midY || target.boundingBox == .zero
    }

    private static func isBelow(_ line: JisiluOCRTextLine, _ target: JisiluOCRTextLine) -> Bool {
        line.boundingBox.midY < target.boundingBox.midY || target.boundingBox == .zero
    }

    private static func verticalDistance(
        _ line: JisiluOCRTextLine,
        _ target: JisiluOCRTextLine
    ) -> CGFloat {
        guard line.boundingBox != .zero, target.boundingBox != .zero else {
            return 0
        }
        return abs(line.boundingBox.midY - target.boundingBox.midY)
    }

    private static func horizontalDistance(
        _ line: JisiluOCRTextLine,
        _ target: JisiluOCRTextLine
    ) -> CGFloat {
        guard line.boundingBox != .zero, target.boundingBox != .zero else {
            return 0
        }
        return abs(line.boundingBox.midX - target.boundingBox.midX)
    }

    private static func uniqueOutputURL(
        in folderURL: URL,
        exportedAt: Date,
        ownerName: String?
    ) -> URL {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyyMMdd_HHmmss"

        let ownerPart = sanitizedFileName(ownerName).map { "_\($0)" } ?? ""
        let stem = "集思录\(ownerPart)_\(formatter.string(from: exportedAt))"
        var candidate = folderURL.appendingPathComponent("\(stem).xls")
        var suffix = 1
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = folderURL.appendingPathComponent("\(stem)_\(suffix).xls")
            suffix += 1
        }
        return candidate
    }

    private static func jisiluHTML(
        metadata: JisiluMetadata,
        records: [JisiluHoldingRecord],
        ownerName: String?
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.dateFormat = "yyyy/M/d HH:mm:ss"

        let rows = records.map { record in
            """
              <tr><td>\(paddedCode(record.code))</td><td>\(escapeHTML(record.name))</td><td>\(formatDecimal(record.marketValue))</td></tr>
            """
        }.joined(separator: "\n")

        let ownerRow = ownerName.map {
            "  <tr><td>账户名称</td><td>\(escapeHTML($0))</td></tr>\n"
        } ?? ""

        return """
        <html>
        <head><meta charset="utf-8"></head>
        <body>
        <table>
        \(ownerRow)  <tr><td>当前总资产</td><td>\(formatDecimal(metadata.currentTotalAssets))</td></tr>
          <tr><td>导出时间</td><td>\(dateFormatter.string(from: metadata.exportedAt))</td></tr>
          <tr><th>代码</th><th>名称</th><th>参考市值</th></tr>
        \(rows)
        </table>
        </body>
        </html>
        """
    }

    private static func sanitizedFileName(_ name: String?) -> String? {
        guard let name else { return nil }
        let sanitized = name
            .map { "/:\\".contains($0) ? "_" : String($0) }
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return sanitized.isEmpty ? nil : sanitized
    }

    private static func paddedCode(_ code: Int) -> String {
        String(format: "%06d", code)
    }

    private static func formatDecimal(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private static func escapeHTML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
