import Foundation

private struct PortfolioStock {
    let name: String
    let code: Int
    let marketValue: Double

    var industry: String {
        StockScoreModel.industry(for: code)
    }
}

struct PortfolioReportResult {
    let holdings: [JisiluHoldingRecord]
    let totalAssets: Double
}

private struct IndustryPosition {
    let name: String
    let stocks: [PortfolioStock]

    var totalValue: Double {
        stocks.reduce(0) { $0 + $1.marketValue }
    }
}

@discardableResult
func runPortfolioReport(
    folderURL: URL?,
    title: String? = nil,
    sourceNote: String? = nil,
    printsInvestmentPlans: Bool = true
) throws -> PortfolioReportResult {
    let source = try JisiluXLSLoader.loadLatest(
        in: folderURL.map { [$0] }
    )
    return printPortfolioReport(
        source: source,
        title: title,
        sourceNote: sourceNote,
        printsInvestmentPlans: printsInvestmentPlans
    )
}

@discardableResult
func printPortfolioReport(
    source: LoadedJisiluXLS,
    title: String? = nil,
    sourceNote: String? = nil,
    printsInvestmentPlans: Bool = true
) -> PortfolioReportResult {
    let exportedAtFormatter = DateFormatter()
    exportedAtFormatter.locale = Locale(identifier: "zh_CN")
    exportedAtFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    exportedAtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    if let title {
        reportPrint("\n" + String(repeating: "=", count: 20) + " \(title) " + String(repeating: "=", count: 20))
    }
    if let sourceNote {
        reportPrint(sourceNote)
    }
    reportPrint(
        "Jisilu 数据源：\(source.fileURL.path)，" +
        "导出时间：\(exportedAtFormatter.string(from: source.metadata.exportedAt))，" +
        "当前总资产：¥\(String(format: "%.2f", source.metadata.currentTotalAssets))，" +
        "持仓：\(source.records.count) 只"
    )

    let stocks = source.records.map {
        PortfolioStock(name: $0.name, code: $0.code, marketValue: $0.marketValue)
    }
    let industries = Dictionary(grouping: stocks, by: \.industry)
        .map { IndustryPosition(name: $0.key, stocks: $0.value) }

    printIndustryReport(
        industries: industries,
        totalAssets: source.metadata.currentTotalAssets
    )
    if printsInvestmentPlans {
        printInvestmentPlans(currentValue: source.metadata.currentTotalAssets)
    }
    return PortfolioReportResult(
        holdings: source.records,
        totalAssets: source.metadata.currentTotalAssets
    )
}

private func printIndustryReport(
    industries: [IndustryPosition],
    totalAssets: Double
) {
    let sorted = industries.sorted { $0.totalValue > $1.totalValue }
    var grandTotal = 0.0
    let industryWidths = [10, 8, 12, 12, 80]

    func printIndustryRow(_ row: [String]) {
        reportPrint(zip(row, industryWidths).map { pad($0, to: $1) }.joined(separator: " | "))
    }

    reportPrint("")
    printIndustryRow(["行业", "占比", "需投入", "总价", "股票明细"])
    let industryLineWidth = industryWidths.reduce(0, +) +
        (industryWidths.count - 1) * displayWidth(" | ")
    reportPrint(String(repeating: "-", count: industryLineWidth))

    for industry in sorted {
        let ratio = industry.totalValue / totalAssets * 100
        let needInvest = totalAssets * 0.03 - industry.totalValue
        let details = industry.stocks.map {
            "\($0.name)(\($0.code)) ¥\(String(format: "%.0f", $0.marketValue))"
        }.joined(separator: "；")

        printIndustryRow([
            industry.name,
            String(format: "%.2f%%", ratio),
            String(format: "%.0f", needInvest),
            String(format: "%.0f", industry.totalValue),
            details
        ])
        grandTotal += industry.totalValue
    }

    let stockCount = sorted.reduce(0) { $0 + $1.stocks.count }
    let summaryWidths = [10, 10, 16, 16, 12]
    func printSummaryRow(_ row: [String]) {
        reportPrint(zip(row, summaryWidths).map { pad($0, to: $1) }.joined(separator: " | "))
    }
    reportPrint("")
    printSummaryRow(["行业数量", "股票数量", "总市值", "账户总值", "仓位比例"])
    let summaryLineWidth = summaryWidths.reduce(0, +) +
        (summaryWidths.count - 1) * displayWidth(" | ")
    reportPrint(String(repeating: "-", count: summaryLineWidth))
    printSummaryRow([
        "\(sorted.count) 个",
        "\(stockCount) 只",
        "¥\(String(format: "%.2f", grandTotal))",
        "¥\(String(format: "%.2f", totalAssets))",
        String(format: "%.2f%%", grandTotal / totalAssets * 100)
    ])
}

private func printInvestmentPlans(currentValue: Double) {
    let annualRates = [0.10, 0.125, 0.15]
    let monthlyInvestments = [0.0, 20_000, 30_000, 40_000, 45_000]

    func requiredMonths(
        initialValue: Double,
        targetValue: Double,
        annualRate: Double,
        monthlyInvestment: Double
    ) -> Int {
        var totalValue = initialValue
        var months = 0
        while totalValue < targetValue {
            totalValue *= 1 + annualRate / 12
            totalValue += monthlyInvestment
            months += 1
        }
        return months
    }

    func duration(_ months: Int) -> String {
        "\(months / 12)年\(months % 12)个月"
    }

    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = .decimal
    currencyFormatter.minimumFractionDigits = 2
    currencyFormatter.maximumFractionDigits = 2

    func currency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    func printPlan(title: String, initial: Double, target: Double, description: String) {
        reportPrint("\n\(title)")
        reportPrint(description)
        let widths = [12, 12, 12, 12, 12, 12]
        func printRow(_ row: [String]) {
            reportPrint(zip(row, widths).map { pad($0, to: $1) }.joined(separator: " | "))
        }

        reportPrint("")
        printRow(["年化收益率", "月投0万", "月投2万", "月投3万", "月投4万", "月投4.5万"])
        let lineWidth = widths.reduce(0, +) + (widths.count - 1) * displayWidth(" | ")
        reportPrint(String(repeating: "-", count: lineWidth))
        for rate in annualRates {
            let durations = monthlyInvestments.map {
                duration(requiredMonths(
                    initialValue: initial,
                    targetValue: target,
                    annualRate: rate,
                    monthlyInvestment: $0
                ))
            }
            printRow([String(format: "%.1f%%", rate * 100)] + durations)
        }
    }

    printPlan(
        title: "500万 - 目标测算",
        initial: currentValue,
        target: 5_000_000,
        description: "当前股权：¥\(currency(currentValue))  目标股权：¥500W"
    )

    let propertyInvestment = 2_000_000.0
    let propertyInitial = currentValue + propertyInvestment
    printPlan(
        title: "房产出售200万 - 目标测算",
        initial: propertyInitial,
        target: 5_000_000,
        description: "当前股权：¥\(currency(currentValue))  房产投入：¥200W  投入后本金：¥\(currency(propertyInitial))  目标股权：¥500W"
    )
    printPlan(
        title: "1000万 - 目标测算",
        initial: currentValue,
        target: 10_000_000,
        description: "当前股权：¥\(currency(currentValue))  目标股权：¥1000W"
    )
    printPlan(
        title: "房产出售200万 - 1000万目标测算",
        initial: propertyInitial,
        target: 10_000_000,
        description: "当前股权：¥\(currency(currentValue))  房产投入：¥200W  投入后本金：¥\(currency(propertyInitial))  目标股权：¥1000W"
    )
}
