import Foundation
import Testing
@testable import StockAnalyzerCLI

struct WebReportTests {
    @Test func excludesTerminalOnlyContentFromWebReport() {
        let output = ReportOutput()

        output.write("我的投资内容")
        output.withoutWebCapture {
            output.write("关联账户的投资内容")
        }

        #expect(output.text == "我的投资内容\n")
    }

    @Test func rendersEscapedReportWithSearchAndHTMLTable() throws {
        let generatedAt = try #require(fixedDate())
        let report = """
        股票 <测试> & 数据
        名称 | 总分TTM | 总分PE动
        -------------------------
        示例 | 280.00 | 275.00

        我的行业加投建议
        关联账户（集思录 Excel，最新）
        关联账户（最新截图：王烨）
        """

        let html = WebReport.renderHTML(
            report: report,
            command: "score",
            generatedAt: generatedAt
        )

        #expect(html.contains("股票 &lt;测试&gt; &amp; 数据"))
        #expect(html.contains("<th>总分TTM</th>"))
        #expect(html.contains("<td>275.00</td>"))
        #expect(html.contains("class=\"table-top-scroll\""))
        #expect(html.contains("enableDragScroll(report)"))
        #expect(!html.contains("top: 65px"))
        #expect(html.contains("class=\"line heading\">我的行业加投建议"))
        #expect(html.contains("关联账户（集思录 Excel，最新）"))
        #expect(html.contains("关联账户（最新截图：王烨）"))
        #expect(html.contains("搜索股票、代码、行业或数值"))
        #expect(html.contains("2026-08-18 09:30:00"))
    }

    @Test func writesTimestampedReportFile() throws {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("WebReportTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let generatedAt = try #require(fixedDate())

        let fileURL = try WebReport.create(
            report: "测试报告",
            command: "all",
            generatedAt: generatedAt,
            outputFolder: folder
        )

        #expect(fileURL.lastPathComponent == "20260818_093000_000_all.html")
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }

    private func fixedDate() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: "2026-08-18 09:30:00")
    }
}
