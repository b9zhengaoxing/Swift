import Foundation

public struct JisiluMetadata {
    public let currentTotalAssets: Double
    public let exportedAt: Date
}

public struct JisiluHoldingRecord {
    public let name: String
    public let code: Int
    public let marketValue: Double
}

public struct LoadedJisiluXLS {
    public let fileURL: URL
    public let fileDate: Date
    public let metadata: JisiluMetadata
    public let records: [JisiluHoldingRecord]
}

private enum JisiluXLSLoaderError: LocalizedError {
    case folderNotFound(String)
    case noDatedXLS(String)
    case invalidXLS(String)
    case missingMetadata(String)
    case missingColumn(String)
    case noValidRows(String)

    var errorDescription: String? {
        switch self {
        case .folderNotFound(let path):
            return "找不到 Jisilu 文件夹：\(path)"
        case .noDatedXLS(let path):
            return "Jisilu 文件夹内没有文件名包含 yyyyMMdd_HHmmss 的 XLS：\(path)"
        case .invalidXLS(let fileName):
            return "集思录 XLS 内容无效：\(fileName)"
        case .missingMetadata(let field):
            return "集思录 XLS 缺少元数据：\(field)"
        case .missingColumn(let column):
            return "集思录 XLS 缺少必要列：\(column)"
        case .noValidRows(let fileName):
            return "集思录 XLS 中没有可用的持仓数据：\(fileName)"
        }
    }
}

public enum JisiluXLSLoader {
    public static func loadLatest(in folders: [URL]? = nil) throws -> LoadedJisiluXLS {
        var lastError: Error?
        var foundFolder = false
        var latestFile: (url: URL, date: Date, modifiedAt: Date)?
        var visitedFolderPaths = Set<String>()
        var attemptedFolderPaths: [String] = []

        for folderURL in folders ?? folderURLs() {
            let folderPath = folderURL.standardizedFileURL.path
            guard visitedFolderPaths.insert(folderPath).inserted else {
                continue
            }
            attemptedFolderPaths.append(folderPath)

            do {
                let candidate = try latestDatedXLS(in: folderURL)
                foundFolder = true

                if let currentLatest = latestFile {
                    if isOlder(currentLatest, than: candidate) {
                        latestFile = candidate
                    }
                } else {
                    latestFile = candidate
                }
            } catch {
                if case JisiluXLSLoaderError.folderNotFound = error {
                    continue
                }

                foundFolder = true
                lastError = error
            }
        }

        if let latestFile {
            let parsed = try parseXLS(at: latestFile.url)
            return LoadedJisiluXLS(
                fileURL: latestFile.url,
                fileDate: latestFile.date,
                metadata: parsed.metadata,
                records: parsed.records
            )
        }

        if let lastError {
            throw lastError
        }

        throw foundFolder
            ? JisiluXLSLoaderError.noDatedXLS(attemptedFolderPaths.joined(separator: "，"))
            : JisiluXLSLoaderError.folderNotFound(attemptedFolderPaths.joined(separator: "，"))
    }

    private static func folderURLs() -> [URL] {
        var folderURLs: [URL] = []

        if let customPath = ProcessInfo.processInfo.environment["JISILU_FOLDER"],
           !customPath.isEmpty {
            folderURLs.append(URL(fileURLWithPath: customPath, isDirectory: true))
        }

        let currentURL = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        ).standardizedFileURL
        folderURLs.append(contentsOf: repositoryJisiluFolders(startingAt: currentURL))
        folderURLs.append(currentURL.appendingPathComponent("Jisilu", isDirectory: true))
        folderURLs.append(
            currentURL.deletingLastPathComponent()
                .appendingPathComponent("Jisilu", isDirectory: true)
        )

        // JisiluXLSLoader.swift -> StockAnalyzerCLI target -> Sources -> package root.
        var packageURL = URL(fileURLWithPath: #filePath)
        for _ in 0..<3 {
            packageURL.deleteLastPathComponent()
        }
        if packageURL.path.hasPrefix("/") {
            folderURLs.append(
                packageURL.deletingLastPathComponent()
                    .appendingPathComponent("repositories", isDirectory: true)
                    .appendingPathComponent("mine", isDirectory: true)
                    .appendingPathComponent("Jisilu", isDirectory: true)
            )
        }
        folderURLs.append(packageURL.appendingPathComponent("Jisilu", isDirectory: true))
        folderURLs.append(
            packageURL.deletingLastPathComponent()
                .appendingPathComponent("Jisilu", isDirectory: true)
        )
        return folderURLs
    }

    private static func repositoryJisiluFolders(startingAt startURL: URL) -> [URL] {
        var folders: [URL] = []
        var currentURL = startURL

        while true {
            folders.append(
                currentURL
                    .appendingPathComponent("repositories", isDirectory: true)
                    .appendingPathComponent("mine", isDirectory: true)
                    .appendingPathComponent("Jisilu", isDirectory: true)
            )

            let parentURL = currentURL.deletingLastPathComponent()
            if parentURL.path == currentURL.path {
                return folders
            }
            currentURL = parentURL
        }
    }

    private static func latestDatedXLS(
        in folderURL: URL
    ) throws -> (url: URL, date: Date, modifiedAt: Date) {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(
            atPath: folderURL.path,
            isDirectory: &isDirectory
        ), isDirectory.boolValue else {
            throw JisiluXLSLoaderError.folderNotFound(folderURL.path)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"

        let datePattern = try NSRegularExpression(pattern: "\\d{8}_\\d{6}")
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        let candidates: [(url: URL, date: Date, modifiedAt: Date)] = fileURLs.compactMap { url in
            guard url.pathExtension.lowercased() == "xls" else { return nil }

            let fileName = url.deletingPathExtension().lastPathComponent
            let fullRange = NSRange(fileName.startIndex..., in: fileName)
            guard
                let match = datePattern.firstMatch(in: fileName, range: fullRange),
                let matchRange = Range(match.range, in: fileName),
                let date = dateFormatter.date(from: String(fileName[matchRange]))
            else {
                return nil
            }

            let modifiedAt = (try? url.resourceValues(
                forKeys: [.contentModificationDateKey]
            ).contentModificationDate) ?? .distantPast
            return (url, date, modifiedAt)
        }

        guard let latest = candidates.max(by: { left, right in
            if left.date != right.date {
                return left.date < right.date
            }
            if left.modifiedAt != right.modifiedAt {
                return left.modifiedAt < right.modifiedAt
            }
            return left.url.lastPathComponent < right.url.lastPathComponent
        }) else {
            throw JisiluXLSLoaderError.noDatedXLS(folderURL.path)
        }

        return latest
    }

    private static func isOlder(
        _ left: (url: URL, date: Date, modifiedAt: Date),
        than right: (url: URL, date: Date, modifiedAt: Date)
    ) -> Bool {
        if left.date != right.date {
            return left.date < right.date
        }
        if left.modifiedAt != right.modifiedAt {
            return left.modifiedAt < right.modifiedAt
        }
        return left.url.path < right.url.path
    }

    private static func parseXLS(
        at fileURL: URL
    ) throws -> (metadata: JisiluMetadata, records: [JisiluHoldingRecord]) {
        let html = try String(contentsOf: fileURL, encoding: .utf8)
        let rows = try htmlRows(html)
        guard !rows.isEmpty else {
            throw JisiluXLSLoaderError.invalidXLS(fileURL.lastPathComponent)
        }

        let metadataRows = rows
            .filter { $0.count == 2 }
            .reduce(into: [String: String]()) { result, row in
                result[row[0]] = row[1]
            }

        guard
            let totalAssetsText = metadataRows["当前总资产"],
            let currentTotalAssets = decimalValue(totalAssetsText),
            currentTotalAssets > 0
        else {
            throw JisiluXLSLoaderError.missingMetadata("当前总资产")
        }

        guard
            let exportedAtText = metadataRows["导出时间"],
            let exportedAt = exportedAtDate(exportedAtText)
        else {
            throw JisiluXLSLoaderError.missingMetadata("导出时间")
        }

        guard let headerRowIndex = rows.firstIndex(where: {
            $0.contains("代码") && $0.contains("名称") && $0.contains("参考市值")
        }) else {
            throw JisiluXLSLoaderError.invalidXLS(fileURL.lastPathComponent)
        }

        let headers = rows[headerRowIndex]
        guard let codeIndex = headers.firstIndex(of: "代码") else {
            throw JisiluXLSLoaderError.missingColumn("代码")
        }
        guard let nameIndex = headers.firstIndex(of: "名称") else {
            throw JisiluXLSLoaderError.missingColumn("名称")
        }
        guard let marketValueIndex = headers.firstIndex(of: "参考市值") else {
            throw JisiluXLSLoaderError.missingColumn("参考市值")
        }

        let requiredLastIndex = [codeIndex, nameIndex, marketValueIndex].max() ?? 0
        let records = rows.dropFirst(headerRowIndex + 1).compactMap { row -> JisiluHoldingRecord? in
            guard row.indices.contains(requiredLastIndex) else { return nil }

            let codeDigits = row[codeIndex].filter(\.isNumber)
            guard
                !codeDigits.isEmpty,
                let code = Int(codeDigits),
                !row[nameIndex].isEmpty,
                let marketValue = decimalValue(row[marketValueIndex])
            else {
                return nil
            }

            return JisiluHoldingRecord(
                name: row[nameIndex],
                code: code,
                marketValue: marketValue
            )
        }

        guard !records.isEmpty else {
            throw JisiluXLSLoaderError.noValidRows(fileURL.lastPathComponent)
        }

        return (
            JisiluMetadata(
                currentTotalAssets: currentTotalAssets,
                exportedAt: exportedAt
            ),
            records
        )
    }

    private static func htmlRows(_ html: String) throws -> [[String]] {
        let rowPattern = try NSRegularExpression(
            pattern: "<tr(?:\\s[^>]*)?>(.*?)</tr>",
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        )
        let cellPattern = try NSRegularExpression(
            pattern: "<t[hd](?:\\s[^>]*)?>(.*?)</t[hd]>",
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        )
        let fullRange = NSRange(html.startIndex..., in: html)

        return rowPattern.matches(in: html, range: fullRange).compactMap { rowMatch -> [String]? in
            guard
                let contentRange = Range(rowMatch.range(at: 1), in: html)
            else {
                return nil
            }

            let rowHTML = String(html[contentRange])
            let rowRange = NSRange(rowHTML.startIndex..., in: rowHTML)
            let cells = cellPattern.matches(in: rowHTML, range: rowRange).compactMap { cellMatch -> String? in
                guard let cellRange = Range(cellMatch.range(at: 1), in: rowHTML) else {
                    return nil
                }
                return normalizedHTMLText(String(rowHTML[cellRange]))
            }
            return cells.isEmpty ? nil : cells
        }
    }

    private static func normalizedHTMLText(_ html: String) -> String {
        let withoutTags = html.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        return withoutTags
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&#160;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func decimalValue(_ text: String) -> Double? {
        let normalized = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "元", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(normalized)
    }

    private static func exportedAtDate(_ text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyy/M/d HH:mm:ss"
        return formatter.date(from: text)
    }
}
