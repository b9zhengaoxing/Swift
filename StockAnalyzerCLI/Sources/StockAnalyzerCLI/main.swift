import Darwin
import Foundation

private enum Command: String {
    case repositories
    case importLatestJisiluImage = "import-latest-jisilu-image"
    case score
    case portfolio
    case all
    case importJisiluImage = "import-jisilu-image"
}

private struct CLIOptions {
    var command: Command = .repositories
    var stockFolder: URL?
    var jisiluFolder: URL?
    var jisiluImageFolder: URL?
    var jisiluImage: URL?
    var showHelp = false

    static func parse(_ arguments: [String]) throws -> CLIOptions {
        var options = CLIOptions()
        var index = 0

        if let first = arguments.first, let command = Command(rawValue: first) {
            options.command = command
            index = 1
        }

        while index < arguments.count {
            switch arguments[index] {
            case "-h", "--help":
                options.showHelp = true
                index += 1
            case "--stock-dir":
                guard arguments.indices.contains(index + 1) else {
                    throw CLIError.missingValue("--stock-dir")
                }
                options.stockFolder = folderURL(arguments[index + 1])
                index += 2
            case "--jisilu-dir":
                guard arguments.indices.contains(index + 1) else {
                    throw CLIError.missingValue("--jisilu-dir")
                }
                options.jisiluFolder = folderURL(arguments[index + 1])
                index += 2
            case "--image-dir":
                guard arguments.indices.contains(index + 1) else {
                    throw CLIError.missingValue("--image-dir")
                }
                options.jisiluImageFolder = folderURL(arguments[index + 1])
                index += 2
            case "--image":
                guard arguments.indices.contains(index + 1) else {
                    throw CLIError.missingValue("--image")
                }
                options.jisiluImage = fileURL(arguments[index + 1])
                index += 2
            default:
                throw CLIError.unknownArgument(arguments[index])
            }
        }
        return options
    }

    private static func folderURL(_ path: String) -> URL {
        let base = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        return URL(fileURLWithPath: path, relativeTo: base).standardizedFileURL
    }

    private static func fileURL(_ path: String) -> URL {
        let base = URL(
            fileURLWithPath: FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        return URL(fileURLWithPath: path, relativeTo: base).standardizedFileURL
    }
}

private enum CLIError: LocalizedError {
    case missingValue(String)
    case unknownArgument(String)
    case missingImagePath

    var errorDescription: String? {
        switch self {
        case .missingValue(let option):
            return "参数 \(option) 后面需要提供目录路径"
        case .unknownArgument(let argument):
            return "无法识别的参数：\(argument)"
        case .missingImagePath:
            return "import-jisilu-image 需要提供 --image PATH"
        }
    }
}

private func printHelp() {
    print("""
    StockAnalyzerCLI - 从真实目录读取最新文件并运行 100/101 的分析逻辑

    用法：
      stock-analyzer score [--stock-dir PATH]
      stock-analyzer portfolio [--jisilu-dir PATH]
      stock-analyzer all [--stock-dir PATH] [--jisilu-dir PATH]
      stock-analyzer repositories [--stock-dir PATH]
      stock-analyzer import-latest-jisilu-image [--image-dir PATH] [--jisilu-dir PATH]
      stock-analyzer import-jisilu-image --image PATH [--jisilu-dir PATH]

    直接从工程运行、不传任何参数时，默认执行 repositories：
    先运行原有股票分析，再读取 repositories/mine/Jisilu 最新 XLS 并打印投资预测；
    最后读取 repositories/others/image 最新截图，生成到 repositories/others/Jisilu，
    只打印别人的持仓报告，不对别人的资产做投资预测。
    portfolio/all 不传 --jisilu-dir 时，默认读取 repositories/mine/Jisilu。
    import-latest-jisilu-image 不传目录时，默认读取 repositories/others/image，
    并生成到 repositories/others/Jisilu。
    """)
}

do {
    let options = try CLIOptions.parse(Array(CommandLine.arguments.dropFirst()))
    if options.showHelp {
        printHelp()
        exit(EXIT_SUCCESS)
    }

    switch options.command {
    case .repositories:
        let layout = RepositoryLayout.default
        try runTwoRepositoryPortfolioReports(
            layout: layout,
            stockFolder: options.stockFolder
        )
    case .importLatestJisiluImage:
        let layout = RepositoryLayout.default
        let result = try JisiluImageImporter.importLatestImage(
            in: [options.jisiluImageFolder ?? layout.imageFolder(for: .others)],
            outputFolder: options.jisiluFolder ?? layout.jisiluFolder(for: .others)
        )
        print(
            "已从最新截图生成 Jisilu XLS：" +
            "对方：\(result.ownerName)，" +
            "数据日期：\(formattedSourceDate(result.sourceModifiedAt))，" +
            "图片：\(result.sourceImageURL.path)，" +
            "输出：\(result.fileURL.path)，" +
            "当前总资产：¥\(String(format: "%.2f", result.metadata.currentTotalAssets))，" +
            "持仓：\(result.records.count) 只"
        )
    case .score:
        try runStockScoreReport(folderURL: options.stockFolder)
    case .portfolio:
        let layout = RepositoryLayout.default
        try runPortfolioReport(
            folderURL: resolvedMineJisiluFolder(options.jisiluFolder, layout: layout),
            title: PortfolioRepository.mine.title
        )
    case .all:
        let layout = RepositoryLayout.default
        let scoredStocks = try runStockScoreReport(folderURL: options.stockFolder)
        print("\n" + String(repeating: "=", count: 100) + "\n")
        let portfolio = try runPortfolioReport(
            folderURL: resolvedMineJisiluFolder(options.jisiluFolder, layout: layout),
            title: PortfolioRepository.mine.title
        )
        printIndustryInvestmentRecommendations(
            scoredStocks: scoredStocks,
            holdings: portfolio.holdings,
            totalAssets: portfolio.totalAssets
        )
    case .importJisiluImage:
        guard let imageURL = options.jisiluImage else {
            throw CLIError.missingImagePath
        }
        let layout = RepositoryLayout.default
        let result = try JisiluImageImporter.importImage(
            at: imageURL,
            outputFolder: options.jisiluFolder ?? layout.jisiluFolder(for: .others)
        )
        print(
            "已生成 Jisilu XLS：对方：\(result.ownerName)，" +
            "数据日期：\(formattedSourceDate(result.sourceModifiedAt))，" +
            "输出：\(result.fileURL.path)，" +
            "当前总资产：¥\(String(format: "%.2f", result.metadata.currentTotalAssets))，" +
            "持仓：\(result.records.count) 只"
        )
    }
} catch {
    FileHandle.standardError.write(Data("错误：\(error.localizedDescription)\n".utf8))
    exit(EXIT_FAILURE)
}

private func runTwoRepositoryPortfolioReports(
    layout: RepositoryLayout,
    stockFolder: URL?
) throws {
    let scoredStocks = try runStockScoreReport(folderURL: stockFolder)
    print("\n" + String(repeating: "=", count: 100) + "\n")

    let mineFolder = layout.jisiluFolder(for: .mine)
    let minePortfolio = try runPortfolioReport(
        folderURL: mineFolder,
        title: PortfolioRepository.mine.title,
        sourceNote: "仓库：\(mineFolder.path)",
        printsInvestmentPlans: true
    )
    printIndustryInvestmentRecommendations(
        scoredStocks: scoredStocks,
        holdings: minePortfolio.holdings,
        totalAssets: minePortfolio.totalAssets,
        title: "我的行业加投建议"
    )

    print("\n" + String(repeating: "=", count: 100) + "\n")

    let othersImageFolder = layout.imageFolder(for: .others)
    let othersJisiluFolder = layout.jisiluFolder(for: .others)
    let imported = try JisiluImageImporter.importLatestImage(
        in: [othersImageFolder],
        outputFolder: othersJisiluFolder
    )
    let loadedOthers = LoadedJisiluXLS(
        fileURL: imported.fileURL,
        fileDate: imported.metadata.exportedAt,
        metadata: imported.metadata,
        records: imported.records
    )
    let othersPortfolio = printPortfolioReport(
        source: loadedOthers,
        title: "\(PortfolioRepository.others.title)（\(imported.ownerName)）",
        sourceNote: "对方：\(imported.ownerName)\n" +
            "数据日期：\(formattedSourceDate(imported.sourceModifiedAt))（图片修改时间）\n" +
            "图片源：\(imported.sourceImageURL.path)\n" +
            "生成XLS：\(imported.fileURL.path)",
        printsInvestmentPlans: false
    )
    printIndustryInvestmentRecommendations(
        scoredStocks: scoredStocks,
        holdings: othersPortfolio.holdings,
        totalAssets: othersPortfolio.totalAssets,
        title: "别人的行业加投建议"
    )
}

private func resolvedMineJisiluFolder(_ optionURL: URL?, layout: RepositoryLayout) -> URL {
    guard let optionURL else {
        return layout.jisiluFolder(for: .mine)
    }

    if folderExists(optionURL) {
        return optionURL
    }

    let fallbackURL = layout.jisiluFolder(for: .mine)
    if folderExists(fallbackURL) {
        FileHandle.standardError.write(
            Data(
                "提示：--jisilu-dir 指向的目录不存在：\(optionURL.path)，已改用：\(fallbackURL.path)\n".utf8
            )
        )
        return fallbackURL
    }

    return optionURL
}

private func folderExists(_ folderURL: URL) -> Bool {
    var isDirectory: ObjCBool = false
    return FileManager.default.fileExists(
        atPath: folderURL.path,
        isDirectory: &isDirectory
    ) && isDirectory.boolValue
}

private func formattedSourceDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: date)
}
