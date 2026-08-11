import Foundation

private struct PortfolioStock {
    let name: String
    let code: Int
    let marketValue: Double

    var industry: String {
        StockScoreModel.industry(for: code)
    }
}

private struct IndustryPosition {
    let name: String
    let stocks: [PortfolioStock]

    var totalValue: Double {
        stocks.reduce(0) { $0 + $1.marketValue }
    }
}

func runPortfolioReport(folderURL: URL?) throws {
    let source = try JisiluXLSLoader.loadLatest(
        in: folderURL.map { [$0] }
    )
    let exportedAtFormatter = DateFormatter()
    exportedAtFormatter.locale = Locale(identifier: "zh_CN")
    exportedAtFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    exportedAtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    print(
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
    printInvestmentPlans(currentValue: source.metadata.currentTotalAssets)
}

private func printIndustryReport(
    industries: [IndustryPosition],
    totalAssets: Double
) {
    let sorted = industries.sorted { $0.totalValue > $1.totalValue }
    var grandTotal = 0.0

    print("\n行业      占比     需投入       总价        股票明细")
    print("------------------------------------------------------------")

    for industry in sorted {
        let paddedName = industry.name.count < 4
            ? industry.name + String(repeating: "　", count: 4 - industry.name.count)
            : industry.name
        let ratio = industry.totalValue / totalAssets * 100
        let needInvest = totalAssets * 0.03 - industry.totalValue
        let details = industry.stocks.map {
            "\($0.name)(\($0.code)) ¥\(String(format: "%.0f", $0.marketValue))"
        }.joined(separator: "；")

        print(
            "\(paddedName)  " +
            "\(String(format: "%5.2f%%", ratio)) " +
            "\(String(format: "%10.0f", needInvest)) " +
            "\(String(format: "%10.0f", industry.totalValue))  " +
            details
        )
        grandTotal += industry.totalValue
    }

    print("------------------------------------------------------------")
    let stockCount = sorted.reduce(0) { $0 + $1.stocks.count }
    print(
        "行业：\(sorted.count) 个  股票：\(stockCount)  " +
        "总市值：¥\(String(format: "%.2f", grandTotal))  " +
        "账户总值：¥\(String(format: "%.2f", totalAssets))  " +
        "仓位比例：\(String(format: "%.2f%%", grandTotal / totalAssets * 100))"
    )
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
        print("\n\(title)")
        print(description)
        print("\n年化收益率  月投0万     月投2万     月投3万     月投4万     月投4.5万")
        print("-------------------------------------------------------------------")
        for rate in annualRates {
            let durations = monthlyInvestments.map {
                duration(requiredMonths(
                    initialValue: initial,
                    targetValue: target,
                    annualRate: rate,
                    monthlyInvestment: $0
                ))
            }
            print("\(String(format: "%5.1f%%", rate * 100))      " + durations.joined(separator: "    "))
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
