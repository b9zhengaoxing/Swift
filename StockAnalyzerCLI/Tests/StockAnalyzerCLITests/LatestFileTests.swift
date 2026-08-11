import Foundation
import Testing
@testable import StockAnalyzerCLI

struct LatestFileTests {
    @Test func stockLoaderChoosesNewestFileAcrossFolders() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let oldFolder = root.appendingPathComponent("old", isDirectory: true)
        let newFolder = root.appendingPathComponent("new", isDirectory: true)
        try FileManager.default.createDirectory(at: oldFolder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: newFolder, withIntermediateDirectories: true)

        try stockCSV(name: "旧数据", code: "000001").write(
            to: oldFolder.appendingPathComponent("问财选股_2026-08-10_1条.csv"),
            atomically: true,
            encoding: .utf8
        )
        try stockCSV(name: "新数据", code: "000002").write(
            to: newFolder.appendingPathComponent("问财选股_2026-08-11_1条.csv"),
            atomically: true,
            encoding: .utf8
        )

        let loaded = try StockCSVLoader.loadLatest(in: [oldFolder, newFolder])
        #expect(loaded.fileURL.lastPathComponent.contains("2026-08-11"))
        #expect(loaded.records.first?.name == "新数据")
    }

    @Test func jisiluLoaderChoosesNewestFileAcrossFolders() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let oldFolder = root.appendingPathComponent("old", isDirectory: true)
        let newFolder = root.appendingPathComponent("new", isDirectory: true)
        try FileManager.default.createDirectory(at: oldFolder, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: newFolder, withIntermediateDirectories: true)

        try jisiluXLS(name: "旧持仓", code: "000001").write(
            to: oldFolder.appendingPathComponent("集思录_20260810_120000.xls"),
            atomically: true,
            encoding: .utf8
        )
        try jisiluXLS(name: "新持仓", code: "000002").write(
            to: newFolder.appendingPathComponent("集思录_20260811_120000.xls"),
            atomically: true,
            encoding: .utf8
        )

        let loaded = try JisiluXLSLoader.loadLatest(in: [oldFolder, newFolder])
        #expect(loaded.fileURL.lastPathComponent.contains("20260811"))
        #expect(loaded.records.first?.name == "新持仓")
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("StockAnalyzerCLI-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func stockCSV(name: String, code: String) -> String {
        """
        股票代码,股票简称,现价(元),市盈率(pe),市盈率(TTM),市净率,((收盘价:不复权-区间最低价:前复权)/区间最低价:前复权),(无形资产/资产总计),资产负债率(%)
        \(code),\(name),10,8,7,0.8,0.1,0.05,20
        """
    }

    private func jisiluXLS(name: String, code: String) -> String {
        """
        <table>
          <tr><td>当前总资产</td><td>1000000</td></tr>
          <tr><td>导出时间</td><td>2026/8/11 12:00:00</td></tr>
          <tr><th>代码</th><th>名称</th><th>参考市值</th></tr>
          <tr><td>\(code)</td><td>\(name)</td><td>10000</td></tr>
        </table>
        """
    }
}
