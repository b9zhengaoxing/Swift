# AGENTS.md

## Project Context

This is a Swift learning workspace. The main runnable harness is `StockAnalyzerCLI`, a SwiftPM command line project that migrates stock scoring, portfolio reporting, and investment planning logic from `Swift_Practice.playground` pages 100/101.

The user is studying the harness project while learning. Prefer small, readable, incremental changes, and explain non-obvious Swift or business-rule decisions when useful.

## Repository Layout

- `Swift_Practice.playground/`: learning playground and original reference code.
- `StockAnalyzerCLI/`: SwiftPM executable package.
- `StockAnalyzerCLI/Sources/StockAnalyzerCLI/main.swift`: CLI argument parsing and command orchestration.
- `StockAnalyzerCLI/Sources/StockAnalyzerCLI/*Loader.swift`: file discovery and parsing.
- `StockAnalyzerCLI/Sources/StockAnalyzerCLI/StockScoring.swift`: stock scoring model and industry mapping.
- `StockAnalyzerCLI/Sources/StockAnalyzerCLI/PortfolioReport.swift`: Jisilu portfolio output and long-term target plans.
- `StockAnalyzerCLI/Sources/StockAnalyzerCLI/IndustryInvestmentReport.swift`: industry add-investment recommendations.
- `repositories/`: local portfolio data. Keep `mine` and `others` data separate.

## Commands

Run from `StockAnalyzerCLI/` unless there is a clear reason not to.

```bash
swift run stock-analyzer
swift run stock-analyzer score --stock-dir ../Stock
swift run stock-analyzer portfolio --jisilu-dir ../repositories/mine/Jisilu
swift run stock-analyzer all
swift test
```

The default `stock-analyzer` command runs the two-repository flow: stock scoring, my Jisilu portfolio, my industry add-investment recommendations, latest other-person image import, other-person Jisilu report, and other-person industry recommendations.

## Important Business Rules

- Do not mix `repositories/mine` and `repositories/others`.
- Do not upload, commit, or expose local portfolio data, exported spreadsheets, screenshots, or generated data files.
- My Jisilu data is used for asset target planning.
- Other-person Jisilu data is only used for portfolio and industry recommendation reports, not 500万/1000万 target planning.
- Industry add-investment target is currently 3% of total assets per industry.
- Qualified add-investment candidates require total score >= 260, exclude `ST` / `*ST`, and exclude intangible asset ratio above 20%.
- Stock score output currently prints candidates with minimum score 260.
- The large industry mapping in `StockScoring.swift` is business data. Avoid casual cleanup or reformatting unless the task is explicitly about that mapping.

## File Discovery Rules

- Stock CSV files are selected by `yyyy-MM-dd` in the filename.
- Jisilu `.xls` files are selected by `yyyyMMdd_HHmmss` in the filename.
- If dates tie, modification time and then path/name are used as tiebreakers.
- Jisilu `.xls` files are UTF-8 HTML table files, not binary Excel workbooks.
- Required Jisilu metadata: `当前总资产`, `导出时间`.
- Required Jisilu columns: `代码`, `名称`, `参考市值`.
- Supported image import extensions: `jpg`, `jpeg`, `png`, `heic`, `heif`, `tif`, `tiff`, `bmp`.
- Other-person screenshots should be named with the person's name, for example `王烨.jpg`; that basename becomes `ownerName`.

## Environment Variables

Respect these existing overrides:

- `STOCK_FOLDER`
- `JISILU_FOLDER`
- `JISILU_IMAGE_FOLDER`
- `PORTFOLIO_REPOSITORIES_ROOT`

## Coding Style

- Use Foundation-first Swift; avoid adding dependencies unless clearly needed.
- Keep CLI behavior explicit and simple.
- Keep parsing tolerant of real exported files, but fail with useful Chinese error messages.
- Preserve Chinese output text and table formatting unless the task asks to change UX.
- Use `DateFormatter` with explicit locale/timezone when parsing or printing dates.
- Use Swift Testing (`import Testing`, `@Test`, `#expect`) for tests.

## Change Discipline

Before editing, check `git status --short`; this repo may contain user changes. Do not revert unrelated changes.

Keep all data-related folders ignored. If data files appear in Git status, remove them from the index with `git rm --cached` while preserving local files.

For behavior changes, add or update focused tests in `StockAnalyzerCLI/Tests/StockAnalyzerCLITests`.

Avoid touching playground files unless the task explicitly asks to update the learning/reference version.
