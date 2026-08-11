import Darwin
import Foundation

private enum Command: String {
    case score
    case portfolio
    case all
}

private struct CLIOptions {
    var command: Command = .all
    var stockFolder: URL?
    var jisiluFolder: URL?
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
}

private enum CLIError: LocalizedError {
    case missingValue(String)
    case unknownArgument(String)

    var errorDescription: String? {
        switch self {
        case .missingValue(let option):
            return "参数 \(option) 后面需要提供目录路径"
        case .unknownArgument(let argument):
            return "无法识别的参数：\(argument)"
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

    不传目录时，会依次检查环境变量 STOCK_FOLDER/JISILU_FOLDER、当前目录、
    当前目录的上级目录，以及项目所在仓库。程序会打印最终读取文件的绝对路径。
    """)
}

do {
    let options = try CLIOptions.parse(Array(CommandLine.arguments.dropFirst()))
    if options.showHelp {
        printHelp()
        exit(EXIT_SUCCESS)
    }

    switch options.command {
    case .score:
        try runStockScoreReport(folderURL: options.stockFolder)
    case .portfolio:
        try runPortfolioReport(folderURL: options.jisiluFolder)
    case .all:
        try runStockScoreReport(folderURL: options.stockFolder)
        print("\n" + String(repeating: "=", count: 100) + "\n")
        try runPortfolioReport(folderURL: options.jisiluFolder)
    }
} catch {
    FileHandle.standardError.write(Data("错误：\(error.localizedDescription)\n".utf8))
    exit(EXIT_FAILURE)
}
