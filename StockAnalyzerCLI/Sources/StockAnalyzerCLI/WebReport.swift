import Foundation

final class ReportOutput: @unchecked Sendable {
    static let shared = ReportOutput()

    private let lock = NSLock()
    private var content = ""
    private var webCaptureSuppressionDepth = 0

    init() {}

    func reset() {
        lock.withLock {
            content = ""
        }
    }

    func write(_ value: String) {
        Swift.print(value)
        lock.withLock {
            guard webCaptureSuppressionDepth == 0 else { return }
            content += value + "\n"
        }
    }

    func withoutWebCapture<T>(_ operation: () throws -> T) rethrows -> T {
        lock.withLock {
            webCaptureSuppressionDepth += 1
        }
        defer {
            lock.withLock {
                webCaptureSuppressionDepth -= 1
            }
        }
        return try operation()
    }

    var text: String {
        lock.withLock { content }
    }
}

func reportPrint(_ value: String = "") {
    ReportOutput.shared.write(value)
}

enum WebReport {
    static func create(
        report: String,
        command: String,
        generatedAt: Date = Date(),
        outputFolder: URL? = nil
    ) throws -> URL {
        let folder = outputFolder ?? defaultOutputFolder()
        try FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )

        let fileURL = folder.appendingPathComponent(
            "\(fileTimestamp(generatedAt))_\(safeFileName(command)).html"
        )
        let html = renderHTML(
            report: report,
            command: command,
            generatedAt: generatedAt
        )
        try html.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    static func openInBrowser(_ fileURL: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [fileURL.path]
        try process.run()
    }

    static func renderHTML(
        report: String,
        command: String,
        generatedAt: Date
    ) -> String {
        let title = "股票分析报告"
        return """
        <!doctype html>
        <html lang="zh-CN">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>\(escapeHTML(title)) - \(escapeHTML(command))</title>
          <style>
            :root {
              color-scheme: light;
              --ink: #18211d;
              --muted: #65706a;
              --paper: #ffffff;
              --canvas: #f3f5f1;
              --line: #d9dfda;
              --green: #176b4d;
              --green-soft: #e8f3ed;
              --shadow: 0 12px 34px rgba(27, 42, 34, 0.10);
            }
            * { box-sizing: border-box; }
            body {
              margin: 0;
              color: var(--ink);
              background: var(--canvas);
              font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", sans-serif;
            }
            .masthead {
              color: #fff;
              background: #17251f;
              border-bottom: 4px solid #d3a041;
            }
            .masthead-inner, main { width: min(1600px, calc(100% - 40px)); margin: 0 auto; }
            .masthead-inner { padding: 30px 0 26px; }
            h1 { margin: 0 0 12px; font-size: 36px; line-height: 1.08; letter-spacing: 0; }
            .meta { display: flex; flex-wrap: wrap; gap: 10px 20px; color: #d7e2dc; font-size: 14px; }
            .command { color: #fff5dc; font-weight: 700; }
            main { padding: 24px 0 48px; }
            .toolbar {
              position: sticky;
              top: 0;
              z-index: 10;
              display: flex;
              gap: 10px;
              align-items: center;
              padding: 12px;
              margin-bottom: 16px;
              background: rgba(243, 245, 241, 0.94);
              border-bottom: 1px solid var(--line);
              backdrop-filter: blur(10px);
            }
            .search {
              flex: 1;
              min-width: 160px;
              height: 40px;
              padding: 0 12px;
              color: var(--ink);
              background: #fff;
              border: 1px solid #aeb8b1;
              border-radius: 6px;
              font: inherit;
            }
            .search:focus { outline: 3px solid rgba(23, 107, 77, 0.18); border-color: var(--green); }
            button {
              height: 40px;
              padding: 0 14px;
              color: #fff;
              background: var(--green);
              border: 0;
              border-radius: 6px;
              font: 600 14px -apple-system, BlinkMacSystemFont, "PingFang SC", sans-serif;
              cursor: pointer;
            }
            button.secondary { color: var(--ink); background: #fff; border: 1px solid #aeb8b1; }
            .result-count { min-width: 74px; color: var(--muted); font-size: 13px; text-align: right; }
            article {
              overflow-x: auto;
              overflow-y: hidden;
              background: var(--paper);
              border: 1px solid var(--line);
              border-radius: 8px;
              box-shadow: var(--shadow);
            }
            .line {
              min-width: max-content;
              min-height: 23px;
              padding: 1px 24px;
              white-space: pre;
              font: 13px/1.65 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "PingFang SC", monospace;
            }
            .line:first-child { padding-top: 22px; }
            .line:last-child { padding-bottom: 22px; }
            .line.heading {
              min-width: 0;
              min-height: auto;
              margin: 22px 0 12px;
              padding: 15px 24px 12px;
              color: #123f30;
              background: var(--green-soft);
              border-top: 1px solid #cfe2d7;
              border-bottom: 1px solid #cfe2d7;
              font: 700 19px/1.4 -apple-system, BlinkMacSystemFont, "PingFang SC", sans-serif;
              white-space: normal;
            }
            .line.meta-line { color: #52625a; background: #fafbf9; }
            .line.summary { color: var(--green); font-weight: 700; }
            .line.divider { min-height: 12px; color: #b7c0ba; overflow: hidden; }
            .table-shell { margin: 18px 0 24px; border-block: 1px solid var(--line); }
            .table-top-scroll {
              height: 14px;
              overflow-x: auto;
              overflow-y: hidden;
              background: #edf1ee;
              border-bottom: 1px solid var(--line);
            }
            .table-top-scroll-content { height: 1px; }
            .table-wrap {
              overflow-x: auto;
              cursor: grab;
              overscroll-behavior-x: contain;
              touch-action: pan-y;
            }
            article { cursor: grab; touch-action: pan-y; }
            article.dragging, .table-wrap.dragging { cursor: grabbing; user-select: none; }
            table { width: max-content; min-width: 100%; border-collapse: collapse; font-size: 12px; }
            th, td { padding: 9px 10px; text-align: left; border-right: 1px solid #edf0ed; border-bottom: 1px solid #e5e9e6; }
            th {
              min-width: 64px;
              color: #fff;
              background: #245b47;
              font-weight: 700;
              line-height: 1.35;
              white-space: normal;
            }
            td { white-space: nowrap; }
            tr:nth-child(even) td { background: #f7f9f7; }
            tr:hover td { background: #fff7df; }
            mark { color: #352300; background: #ffd978; border-radius: 2px; }
            .empty { padding: 64px 24px; color: var(--muted); text-align: center; }
            @media (max-width: 700px) {
              .masthead-inner, main { width: min(100% - 20px, 1600px); }
              .masthead-inner { padding: 22px 4px 20px; }
              h1 { font-size: 30px; }
              .toolbar { flex-wrap: wrap; padding-inline: 0; }
              .search { flex-basis: 100%; }
              .result-count { margin-left: auto; }
              .line { padding-inline: 14px; font-size: 12px; }
              th, td { padding: 8px; }
            }
            @media print {
              body { background: #fff; }
              .masthead { color: #000; background: #fff; border-color: #999; }
              .meta, .command { color: #333; }
              .toolbar { display: none; }
              main { width: 100%; padding: 14px 0; }
              article { border: 0; box-shadow: none; }
              .table-top-scroll { display: none; }
            }
          </style>
        </head>
        <body>
          <header class="masthead">
            <div class="masthead-inner">
              <h1>\(escapeHTML(title))</h1>
              <div class="meta">
                <span>命令：<span class="command">\(escapeHTML(command))</span></span>
                <span>生成时间：\(escapeHTML(displayTimestamp(generatedAt)))</span>
              </div>
            </div>
          </header>
          <main>
            <div class="toolbar">
              <input id="search" class="search" type="search" placeholder="搜索股票、代码、行业或数值" aria-label="搜索报告">
              <span id="resultCount" class="result-count"></span>
              <button id="copy" type="button">复制报告</button>
              <button class="secondary" type="button" onclick="window.print()">打印</button>
            </div>
            <article id="report">\(renderBody(report))</article>
          </main>
          <script>
            const report = document.getElementById('report');
            const searchable = [...report.querySelectorAll('.line, th, td')];
            const originals = searchable.map(element => element.textContent);
            const search = document.getElementById('search');
            const resultCount = document.getElementById('resultCount');
            const rawReport = \(jsonString(report));

            function renderSearch() {
              const query = search.value.trim().toLocaleLowerCase();
              let matches = 0;
              searchable.forEach((element, index) => {
                const original = originals[index];
                element.replaceChildren(document.createTextNode(original || ' '));
                if (!query) return;
                element.replaceChildren();
                const lower = original.toLocaleLowerCase();
                let cursor = 0;
                let position = lower.indexOf(query);
                while (position >= 0) {
                  const before = original.slice(cursor, position);
                  const marked = original.slice(position, position + query.length);
                  element.append(document.createTextNode(before));
                  const mark = document.createElement('mark');
                  mark.textContent = marked;
                  element.append(mark);
                  matches += 1;
                  cursor = position + query.length;
                  position = lower.indexOf(query, cursor);
                }
                if (cursor > 0) element.append(document.createTextNode(original.slice(cursor)));
              });
              resultCount.textContent = query ? `${matches} 处` : '';
            }

            function prepareTableScrolling() {
              document.querySelectorAll('.table-shell').forEach(shell => {
                const topScroll = shell.querySelector('.table-top-scroll');
                const topContent = shell.querySelector('.table-top-scroll-content');
                const tableWrap = shell.querySelector('.table-wrap');
                const table = tableWrap.querySelector('table');
                let isSyncing = false;

                const updateWidth = () => {
                  topContent.style.width = `${table.scrollWidth}px`;
                };
                const sync = (source, target) => {
                  if (isSyncing) return;
                  isSyncing = true;
                  target.scrollLeft = source.scrollLeft;
                  isSyncing = false;
                };

                topScroll.addEventListener('scroll', () => sync(topScroll, tableWrap));
                tableWrap.addEventListener('scroll', () => sync(tableWrap, topScroll));
                updateWidth();
                if (window.ResizeObserver) {
                  new ResizeObserver(updateWidth).observe(table);
                }
              });
            }

            function enableDragScroll(container) {
              let pointerId = null;
              let startX = 0;
              let startScrollLeft = 0;

              container.addEventListener('pointerdown', event => {
                if (event.button !== 0 || container.scrollWidth <= container.clientWidth) return;
                if (container === report && event.target.closest('.table-wrap')) return;
                pointerId = event.pointerId;
                startX = event.clientX;
                startScrollLeft = container.scrollLeft;
                container.setPointerCapture(pointerId);
              });
              container.addEventListener('pointermove', event => {
                if (event.pointerId !== pointerId) return;
                const distance = event.clientX - startX;
                if (Math.abs(distance) > 3) container.classList.add('dragging');
                container.scrollLeft = startScrollLeft - distance;
              });
              const finishDragging = event => {
                if (event.pointerId !== pointerId) return;
                pointerId = null;
                container.classList.remove('dragging');
              };
              container.addEventListener('pointerup', finishDragging);
              container.addEventListener('pointercancel', finishDragging);
            }

            prepareTableScrolling();
            enableDragScroll(report);
            document.querySelectorAll('.table-wrap').forEach(enableDragScroll);
            search.addEventListener('input', renderSearch);
            async function copyReport() {
              if (navigator.clipboard) {
                try {
                  await navigator.clipboard.writeText(rawReport);
                  return;
                } catch (_) {
                  // Local file pages may not receive clipboard permission.
                }
              }
              const helper = document.createElement('textarea');
              helper.value = rawReport;
              helper.style.position = 'fixed';
              helper.style.opacity = '0';
              document.body.append(helper);
              helper.select();
              document.execCommand('copy');
              helper.remove();
            }

            document.getElementById('copy').addEventListener('click', async event => {
              await copyReport();
              const button = event.currentTarget;
              const original = button.textContent;
              button.textContent = '已复制';
              setTimeout(() => button.textContent = original, 1200);
            });
          </script>
        </body>
        </html>
        """
    }

    private static func renderBody(_ report: String) -> String {
        let lines = report.components(separatedBy: .newlines)
        guard lines.contains(where: { !$0.isEmpty }) else {
            return "<div class=\"empty\">本次运行没有输出内容</div>"
        }

        var html: [String] = []
        var index = 0
        while index < lines.count {
            if isPipeTableHeader(lines, at: index) {
                var rows: [[String]] = [pipeCells(lines[index])]
                index += isDivider(lines[index + 1]) ? 2 : 1
                while index < lines.count, lines[index].contains("|") {
                    rows.append(pipeCells(lines[index]))
                    index += 1
                }
                html.append(renderTable(rows))
                continue
            }

            html.append(renderLine(lines[index]))
            index += 1
        }
        return html.joined(separator: "\n")
    }

    private static func isPipeTableHeader(_ lines: [String], at index: Int) -> Bool {
        guard lines.indices.contains(index + 1), lines[index].contains("|") else {
            return false
        }
        return isDivider(lines[index + 1]) || lines[index + 1].contains("|")
    }

    private static func pipeCells(_ line: String) -> [String] {
        line.split(separator: "|", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    private static func renderTable(_ rows: [[String]]) -> String {
        guard let header = rows.first else { return "" }
        let head = header.map { "<th>\(escapeHTML($0))</th>" }.joined()
        let body = rows.dropFirst().map { row in
            "<tr>" + row.map { "<td>\(escapeHTML($0))</td>" }.joined() + "</tr>"
        }.joined(separator: "\n")
        return """
        <div class="table-shell">
          <div class="table-top-scroll" aria-hidden="true">
            <div class="table-top-scroll-content"></div>
          </div>
          <div class="table-wrap">
            <table>
              <thead><tr>\(head)</tr></thead>
              <tbody>\(body)</tbody>
            </table>
          </div>
        </div>
        """
    }

    private static func renderLine(_ line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let classes: String
        if isHeading(trimmed) {
            classes = "line heading"
        } else if isDivider(trimmed) {
            classes = "line divider"
        } else if trimmed.contains("数据源：") || trimmed.hasPrefix("仓库：") ||
                    trimmed.hasPrefix("图片源：") || trimmed.hasPrefix("生成XLS：") ||
                    trimmed.hasPrefix("数据日期：") || trimmed.hasPrefix("对方：") {
            classes = "line meta-line"
        } else if trimmed.hasPrefix("行业：") || trimmed.hasPrefix("已生成") ||
                    trimmed.hasPrefix("已从最新截图生成") {
            classes = "line summary"
        } else {
            classes = "line"
        }
        return "<div class=\"\(classes)\">\(line.isEmpty ? "&nbsp;" : escapeHTML(line))</div>"
    }

    private static func isHeading(_ line: String) -> Bool {
        if line.hasPrefix("=") && line.hasSuffix("=") &&
            line.contains(where: { $0 != "=" && !$0.isWhitespace }) {
            return true
        }
        let exactHeadings: Set<String> = ["仓位配置表", "方案说明", "仓位变化"]
        return exactHeadings.contains(line) || line.hasSuffix("加投建议") ||
            line.hasSuffix("目标测算")
    }

    private static func isDivider(_ line: String) -> Bool {
        guard !line.isEmpty else { return false }
        return line.allSatisfy { $0 == "-" || $0 == "=" }
    }

    private static func escapeHTML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private static func jsonString(_ value: String) -> String {
        let data = try? JSONEncoder().encode(value)
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "\"\""
    }

    private static func defaultOutputFolder() -> URL {
        let sourceFile = URL(fileURLWithPath: #filePath)
        var packageRoot = sourceFile
        for _ in 0..<3 {
            packageRoot.deleteLastPathComponent()
        }
        return packageRoot.appendingPathComponent("reports", isDirectory: true)
    }

    private static func safeFileName(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let characters = value.unicodeScalars.map {
            allowed.contains($0) ? Character(String($0)) : "-"
        }
        let result = String(characters)
        return result.isEmpty ? "report" : result
    }

    private static func fileTimestamp(_ date: Date) -> String {
        dateFormatter("yyyyMMdd_HHmmss_SSS").string(from: date)
    }

    private static func displayTimestamp(_ date: Date) -> String {
        dateFormatter("yyyy-MM-dd HH:mm:ss").string(from: date)
    }

    private static func dateFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.dateFormat = format
        return formatter
    }
}
