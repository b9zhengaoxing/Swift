import Foundation

public struct StockCSVRecord {
    public let name: String
    public let code: Int
    public let pe: Double
    public let dynamicPE: Double?
    public let pb: Double
    public let percent: Double
    public let price: Double
    public let intangibleAssetRatio: Double?
    public let debtAssetRatio: Double?
}

public struct LoadedStockCSV {
    public let fileURL: URL
    public let fileDate: Date
    public let records: [StockCSVRecord]
}

private enum StockCSVLoaderError: LocalizedError {
    case stockFolderNotFound(String)
    case noDatedCSV(String)
    case invalidCSV(String)
    case missingColumn(String)
    case noValidRows(String)

    var errorDescription: String? {
        switch self {
        case .stockFolderNotFound(let path):
            return "找不到 Stock 文件夹：\(path)"
        case .noDatedCSV(let path):
            return "Stock 文件夹内没有文件名包含 yyyy-MM-dd 日期的 CSV：\(path)"
        case .invalidCSV(let fileName):
            return "CSV 内容无效：\(fileName)"
        case .missingColumn(let column):
            return "CSV 缺少必要列：\(column)"
        case .noValidRows(let fileName):
            return "CSV 中没有可用的股票数据：\(fileName)"
        }
    }
}

public enum StockCSVLoader {
    public static func loadLatest(in folders: [URL]? = nil) throws -> LoadedStockCSV {
        var lastError: Error?
        var foundStockFolder = false
        var latestFile: (url: URL, date: Date, modifiedAt: Date)?
        var visitedFolderPaths = Set<String>()

        for folderURL in folders ?? stockFolderURLs() {
            let folderPath = folderURL.standardizedFileURL.path
            guard visitedFolderPaths.insert(folderPath).inserted else {
                continue
            }

            do {
                let candidate = try latestDatedCSV(in: folderURL)
                foundStockFolder = true

                if let currentLatest = latestFile {
                    if isOlder(currentLatest, than: candidate) {
                        latestFile = candidate
                    }
                } else {
                    latestFile = candidate
                }
            } catch {
                if case StockCSVLoaderError.stockFolderNotFound = error {
                    continue
                }

                foundStockFolder = true
                lastError = error
            }
        }

        if let latestFile {
            return LoadedStockCSV(
                fileURL: latestFile.url,
                fileDate: latestFile.date,
                records: try records(fromCSVAt: latestFile.url)
            )
        }

        if let lastError {
            throw lastError
        }

        throw foundStockFolder
            ? StockCSVLoaderError.noDatedCSV("Stock")
            : StockCSVLoaderError.stockFolderNotFound("Stock")
    }

    private static func stockFolderURLs() -> [URL] {
        var folderURLs: [URL] = []

        if let customPath = ProcessInfo.processInfo.environment["STOCK_FOLDER"],
           !customPath.isEmpty {
            folderURLs.append(URL(fileURLWithPath: customPath, isDirectory: true))
        }

        let currentURL = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        folderURLs.append(currentURL.appendingPathComponent("Stock", isDirectory: true))
        folderURLs.append(
            currentURL.deletingLastPathComponent()
                .appendingPathComponent("Stock", isDirectory: true)
        )

        // StockCSVLoader.swift -> StockAnalyzerCLI target -> Sources -> package root.
        var packageURL = URL(fileURLWithPath: #filePath)
        for _ in 0..<3 {
            packageURL.deleteLastPathComponent()
        }
        folderURLs.append(packageURL.appendingPathComponent("Stock", isDirectory: true))
        folderURLs.append(
            packageURL.deletingLastPathComponent()
                .appendingPathComponent("Stock", isDirectory: true)
        )
        return folderURLs
    }

    private static func latestDatedCSV(
        in folderURL: URL
    ) throws -> (url: URL, date: Date, modifiedAt: Date) {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(
            atPath: folderURL.path,
            isDirectory: &isDirectory
        ), isDirectory.boolValue else {
            throw StockCSVLoaderError.stockFolderNotFound(folderURL.path)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let datePattern = try NSRegularExpression(
            pattern: "\\d{4}-\\d{2}-\\d{2}"
        )
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        let candidates: [(url: URL, date: Date, modifiedAt: Date)] = fileURLs.compactMap { url in
            guard url.pathExtension.lowercased() == "csv" else { return nil }

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

        guard let latest = candidates.max(by: { isOlder($0, than: $1) }) else {
            throw StockCSVLoaderError.noDatedCSV(folderURL.path)
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

    private static func parseCSVRows(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var isInsideQuotes = false
        var index = text.startIndex

        func appendRowIfNeeded() {
            row.append(field)
            field = ""
            if row.contains(where: { !$0.isEmpty }) {
                rows.append(row)
            }
            row = []
        }

        while index < text.endIndex {
            let character = text[index]
            let nextIndex = text.index(after: index)

            if character == "\"" {
                if isInsideQuotes,
                   nextIndex < text.endIndex,
                   text[nextIndex] == "\"" {
                    field.append("\"")
                    index = text.index(after: nextIndex)
                    continue
                }
                isInsideQuotes.toggle()
            } else if character == "," && !isInsideQuotes {
                row.append(field)
                field = ""
            } else if (character == "\n" || character == "\r") && !isInsideQuotes {
                appendRowIfNeeded()
                if character == "\r",
                   nextIndex < text.endIndex,
                   text[nextIndex] == "\n" {
                    index = text.index(after: nextIndex)
                    continue
                }
            } else {
                field.append(character)
            }

            index = nextIndex
        }

        if !field.isEmpty || !row.isEmpty {
            appendRowIfNeeded()
        }
        return rows
    }

    private static func normalizedCSVValue(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\u{feff}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func csvColumnIndex(
        in headers: [String],
        startingWith prefix: String
    ) throws -> Int {
        try csvColumnIndex(in: headers, matchingAny: [prefix])
    }

    private static func csvColumnIndex(
        in headers: [String],
        matchingAny prefixes: [String]
    ) throws -> Int {
        let normalizedPrefixes = prefixes.map {
            normalizedCSVValue($0).lowercased()
        }
        guard let index = headers.firstIndex(where: { header in
            let normalizedHeader = normalizedCSVValue(header).lowercased()
            return normalizedPrefixes.contains { normalizedHeader.hasPrefix($0) }
        }) else {
            let prefix = prefixes.joined(separator: " / ")
            throw StockCSVLoaderError.missingColumn(prefix)
        }
        return index
    }

    private static func csvDouble(_ value: String) -> Double? {
        let normalized = normalizedCSVValue(value)
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "%", with: "")
        guard !normalized.isEmpty, normalized != "--" else { return nil }
        return Double(normalized)
    }

    private static func records(fromCSVAt fileURL: URL) throws -> [StockCSVRecord] {
        let text = try String(contentsOf: fileURL, encoding: .utf8)
        let rows = parseCSVRows(text)
        guard let headers = rows.first, rows.count > 1 else {
            throw StockCSVLoaderError.invalidCSV(fileURL.lastPathComponent)
        }

        let codeIndex = try csvColumnIndex(in: headers, startingWith: "股票代码")
        let nameIndex = try csvColumnIndex(in: headers, startingWith: "股票简称")
        let priceIndex = try csvColumnIndex(
            in: headers,
            matchingAny: [
                "现价(元)",
                "收盘价:前复权",
                "收盘价_前复权"
            ]
        )
        let dynamicPEIndex = try csvColumnIndex(
            in: headers,
            matchingAny: ["市盈率(pe)", "最新动态市盈率"]
        )
        let peIndex = try csvColumnIndex(
            in: headers,
            matchingAny: ["市盈率(TTM)", "最新市盈率ttm"]
        )
        let pbIndex = try csvColumnIndex(
            in: headers,
            matchingAny: ["市净率", "最新市净率"]
        )
        let percentIndex = try csvColumnIndex(
            in: headers,
            matchingAny: [
                "((收盘价:不复权-区间最低价:前复权)/区间最低价:前复权)",
                "(收盘价-最低价最小值)/最低价最小值"
            ]
        )
        let intangibleAssetRatioIndex = try csvColumnIndex(
            in: headers,
            matchingAny: ["(无形资产/资产总计)", "无形资产/总资产"]
        )
        let debtAssetRatioIndex = try csvColumnIndex(
            in: headers,
            startingWith: "资产负债率(%)"
        )

        let requiredLastIndex = [
            codeIndex, nameIndex, priceIndex, dynamicPEIndex, peIndex, pbIndex,
            percentIndex, intangibleAssetRatioIndex, debtAssetRatioIndex
        ].max() ?? 0

        let records = rows.dropFirst().compactMap { row -> StockCSVRecord? in
            guard row.indices.contains(requiredLastIndex) else { return nil }

            let codeDigits = normalizedCSVValue(row[codeIndex]).filter(\.isNumber)
            guard
                codeDigits.count >= 6,
                let code = Int(codeDigits.prefix(6)),
                let price = csvDouble(row[priceIndex]),
                let pe = csvDouble(row[peIndex]),
                let pb = csvDouble(row[pbIndex]),
                let percent = csvDouble(row[percentIndex])
            else {
                return nil
            }

            return StockCSVRecord(
                name: normalizedCSVValue(row[nameIndex]),
                code: code,
                pe: pe,
                dynamicPE: csvDouble(row[dynamicPEIndex]),
                pb: pb,
                percent: percent,
                price: price,
                intangibleAssetRatio: csvDouble(row[intangibleAssetRatioIndex]),
                debtAssetRatio: csvDouble(row[debtAssetRatioIndex])
            )
        }

        guard !records.isEmpty else {
            throw StockCSVLoaderError.noValidRows(fileURL.lastPathComponent)
        }
        return records
    }
}
