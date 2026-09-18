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

    @Test func stockLoaderAcceptsClosingPriceWhenCurrentPriceIsMissing() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        try stockCSV(
            name: "新表头数据",
            code: "000003",
            priceHeader: "收盘价:前复权(元) 2026.09.17"
        ).write(
            to: root.appendingPathComponent("问财选股_2026-09-17_1条.csv"),
            atomically: true,
            encoding: .utf8
        )

        let loaded = try StockCSVLoader.loadLatest(in: [root])

        #expect(loaded.records.first?.name == "新表头数据")
        #expect(loaded.records.first?.price == 10)
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

    @Test func optionalJisiluLoaderReturnsNilForEmptyReceivedFolder() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let loaded = try JisiluXLSLoader.loadLatestIfPresent(in: [root])

        #expect(loaded == nil)
    }

    @Test func repositoryLayoutSeparatesReceivedAndScreenshotGeneratedJisilu() {
        let root = URL(fileURLWithPath: "/tmp/portfolio-test", isDirectory: true)
        let layout = RepositoryLayout(root: root)

        #expect(layout.receivedJisiluFolder().path == "/tmp/portfolio-test/others/关联账户jisilu")
        #expect(
            layout.receivedJisiluFolder().path !=
                layout.jisiluFolder(for: .others).path
        )
    }

    @Test func jisiluImageImporterParsesScreenshotStyleOCRLines() throws {
        let exportedAt = try #require(date("2026/8/14 17:22:00"))
        let parsed = try JisiluImageImporter.parseOCRLines(
            screenshotStyleLines(),
            exportedAt: exportedAt
        )

        #expect(parsed.metadata.currentTotalAssets == 100_855.29)
        #expect(parsed.metadata.exportedAt == exportedAt)
        #expect(parsed.records.map(\.name) == ["海容冷链", "吉林敖东", "华域汽车"])
        #expect(parsed.records.map(\.code) == [603187, 000623, 600741])
        #expect(parsed.records.map(\.marketValue) == [3_774, 3_660, 3_384])
    }

    @Test func jisiluImageImporterWritesLoadableJisiluXLS() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let exportedAt = try #require(date("2026/8/14 17:22:00"))
        let parsed = try JisiluImageImporter.parseOCRLines(
            screenshotStyleLines(),
            exportedAt: exportedAt
        )

        let fileURL = try JisiluImageImporter.writeXLS(
            metadata: parsed.metadata,
            records: parsed.records,
            to: root,
            exportedAt: exportedAt,
            ownerName: "王烨"
        )
        let loaded = try JisiluXLSLoader.loadLatest(in: [root])
        let html = try String(contentsOf: fileURL, encoding: .utf8)

        #expect(fileURL.lastPathComponent == "集思录_王烨_20260814_172200.xls")
        #expect(html.contains("<td>账户名称</td><td>王烨</td>"))
        #expect(loaded.metadata.currentTotalAssets == 100_855.29)
        #expect(loaded.records.count == 3)
        #expect(loaded.records.first?.name == "海容冷链")
    }

    @Test func jisiluImageImporterChoosesLatestModifiedImage() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let oldImage = root.appendingPathComponent("old.jpg")
        let newImage = root.appendingPathComponent("new.png")
        let ignoredFile = root.appendingPathComponent("newer.txt")

        try Data("old".utf8).write(to: oldImage)
        try Data("new".utf8).write(to: newImage)
        try Data("ignored".utf8).write(to: ignoredFile)

        try setModificationDate("2026/8/12 10:00:00", for: oldImage)
        try setModificationDate("2026/8/14 10:00:00", for: newImage)
        try setModificationDate("2026/8/15 10:00:00", for: ignoredFile)

        let latest = try JisiluImageImporter.latestImageURL(in: [root])
        let modifiedAt = try JisiluImageImporter.imageModificationDate(at: latest)
        #expect(latest.lastPathComponent == "new.png")
        #expect(JisiluImageImporter.ownerName(from: latest) == "new")
        #expect(modifiedAt == date("2026/8/14 10:00:00"))
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("StockAnalyzerCLI-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func stockCSV(
        name: String,
        code: String,
        priceHeader: String = "现价(元)"
    ) -> String {
        """
        股票代码,股票简称,\(priceHeader),市盈率(pe),市盈率(TTM),市净率,((收盘价:不复权-区间最低价:前复权)/区间最低价:前复权),(无形资产/资产总计),资产负债率(%)
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

    private func screenshotStyleLines() -> [JisiluOCRTextLine] {
        [
            line("总资产 (元)", x: 0.55, y: 0.94),
            line("100,855.29", x: 0.56, y: 0.92),
            line("名称", x: 0.05, y: 0.78),
            line("市值", x: 0.05, y: 0.765),
            line("海容冷链", x: 0.05, y: 0.73),
            line("603187", x: 0.05, y: 0.715),
            line("3,774.00", x: 0.05, y: 0.695),
            line("吉林敖东", x: 0.05, y: 0.66),
            line("000623", x: 0.05, y: 0.645),
            line("3,660.00", x: 0.05, y: 0.625),
            line("华域汽车", x: 0.05, y: 0.59),
            line("600741", x: 0.05, y: 0.575),
            line("3,384.00", x: 0.05, y: 0.555)
        ]
    }

    private func line(_ text: String, x: Double, y: Double) -> JisiluOCRTextLine {
        JisiluOCRTextLine(
            text: text,
            boundingBox: CGRect(x: x, y: y, width: 0.15, height: 0.01)
        )
    }

    private func date(_ text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyy/M/d HH:mm:ss"
        return formatter.date(from: text)
    }

    private func setModificationDate(_ text: String, for fileURL: URL) throws {
        let value = try #require(date(text))
        try FileManager.default.setAttributes(
            [.modificationDate: value],
            ofItemAtPath: fileURL.path
        )
    }
}
