import Foundation

func runStockScoreReport(folderURL: URL?) throws {
    let source = try StockCSVLoader.loadLatest(
        in: folderURL.map { [$0] }
    )

    print("Stock 数据源：\(source.fileURL.path)，共 \(source.records.count) 条")

    let models = source.records.map { record in
        StockScoreModel(
            name: record.name,
            code: record.code,
            pe: record.pe,
            dynamicPE: record.dynamicPE,
            pb: record.pb,
            percent: record.percent,
            price: record.price,
            intangibleAssetRatio: record.intangibleAssetRatio,
            debtAssetRatio: record.debtAssetRatio
        )
    }.sorted { $0.total_score > $1.total_score }

    printScoreTable(models)
    printPositionPlans()
}

private func printScoreTable(_ models: [StockScoreModel]) {
    let columns = [
        "名称", "代码", "总分", "股价", "市盈率TTM", "市盈率动",
        "标尺PE", "PE分数", "PB", "标尺PB", "PB分数", "百分位",
        "百分位分数", "无形资产占比", "资产负债率", "行业"
    ]
    let widths = [10, 8, 8, 8, 10, 10, 8, 8, 6, 8, 8, 8, 12, 14, 12, 10]
    let header = zip(columns, widths)
        .map { pad($0, to: $1) }
        .joined(separator: " | ")

    print(header)
    print(String(repeating: "-", count: displayWidth(header)))

    for model in models {
        guard !model.name.hasPrefix("ST"), !model.name.hasPrefix("*ST") else {
            continue
        }
        guard model.total_score >= 260 else { continue }
        if let ratio = model.intangibleAssetRatio, ratio > 0.20 {
            continue
        }

        let rule = newPePbScore(industry: model.industry)
        let row = [
            model.name,
            String(model.code),
            formatDecimal(model.total_score),
            formatDecimal(model.price),
            formatDecimal(model.pe),
            formatOptional(model.dynamicPE),
            formatDecimal(rule.peScore),
            formatDecimal(model.pe_score),
            formatDecimal(model.pb),
            formatDecimal(rule.pbScore),
            formatDecimal(model.pb_score),
            formatDecimal(model.percent),
            formatDecimal(model.percent_score),
            formatOptional(model.intangibleAssetRatio),
            formatOptional(model.debtAssetRatio),
            model.industry
        ]
        print(zip(row, widths).map { pad($0, to: $1) }.joined(separator: " | "))
    }
}

private struct PositionPlan {
    let startPoint: Int
    let endPoint: Int
    let startPosition: Double
    let positionPerStep: Double
    let finalPosition: Double

    func position(at point: Int) -> Double {
        if point >= startPoint { return startPosition }
        if point <= endPoint { return finalPosition }
        let steps = (startPoint - point) / 100
        return min(startPosition + Double(steps) * positionPerStep, finalPosition)
    }
}

private func printPositionPlans() {
    let plans = [
        PositionPlan(startPoint: 4200, endPoint: 3000, startPosition: 30, positionPerStep: 5, finalPosition: 90),
        PositionPlan(startPoint: 4200, endPoint: 2200, startPosition: 30, positionPerStep: 3, finalPosition: 90),
        PositionPlan(startPoint: 4200, endPoint: 2100, startPosition: 0, positionPerStep: 4.75, finalPosition: 100),
        PositionPlan(startPoint: 4200, endPoint: 3000, startPosition: 0, positionPerStep: 7.5, finalPosition: 90),
        PositionPlan(startPoint: 4200, endPoint: 3000, startPosition: 50, positionPerStep: 40.0 / 12.0, finalPosition: 90)
    ]
    let widths = [12, 16, 16, 16, 16, 16]

    func printRow(_ row: [String]) {
        print(zip(row, widths).map { pad($0, to: $1) }.joined(separator: " | "))
    }

    print("\n仓位配置表")
    print("\n方案说明")
    printRow(["项目", "方案一", "方案二", "方案三", "方案四", "方案五"])
    printRow(["起始仓位", "4200点 30%", "4200点 30%", "4200点 0%", "4200点 0%", "4200点 50%"])
    printRow(["目标仓位", "3000点 90%", "2200点 90%", "2100点 100%", "3000点 90%", "3000点 90%"])
    printRow(["每跌100点", "+5.00%", "+3.00%", "+4.75%", "+7.50%", "+3.33%"])

    print("\n仓位变化")
    printRow(["点位", "方案一", "方案二", "方案三", "方案四", "方案五"])
    let lineWidth = widths.reduce(0, +) + (widths.count - 1) * displayWidth(" | ")
    print(String(repeating: "-", count: lineWidth))

    for point in stride(from: 4200, through: 3000, by: -100) {
        printRow(
            [String(point)] + plans.map {
                formatDecimal($0.position(at: point)) + "%"
            }
        )
    }
}
