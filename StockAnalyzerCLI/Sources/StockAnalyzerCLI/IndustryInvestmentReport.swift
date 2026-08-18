import Foundation

struct IndustryInvestmentRecommendation {
    let industry: String
    let isNewIndustry: Bool
    let currentValue: Double
    let investmentAmount: Double
    let candidates: [StockScoreModel]
}

func isEligibleInvestmentCandidate(
    _ model: StockScoreModel,
    minimumScore: Double
) -> Bool {
    guard !model.name.hasPrefix("ST"), !model.name.hasPrefix("*ST") else {
        return false
    }
    guard model.total_score >= minimumScore else { return false }
    if let ratio = model.intangibleAssetRatio, ratio > 0.20 {
        return false
    }
    return true
}

func makeIndustryInvestmentRecommendations(
    scoredStocks: [StockScoreModel],
    holdings: [JisiluHoldingRecord],
    totalAssets: Double,
    targetIndustryRatio: Double = 0.03,
    minimumScore: Double = 270
) -> [IndustryInvestmentRecommendation] {
    guard totalAssets > 0, targetIndustryRatio > 0 else { return [] }

    let currentValues = Dictionary(grouping: holdings) {
        StockScoreModel.industry(for: $0.code)
    }.mapValues { records in
        records.reduce(0) { $0 + $1.marketValue }
    }

    let candidatesByIndustry = Dictionary(
        grouping: scoredStocks.filter {
            isEligibleInvestmentCandidate($0, minimumScore: minimumScore)
        },
        by: \.industry
    )
    let targetValue = totalAssets * targetIndustryRatio

    return candidatesByIndustry.compactMap { industry, candidates in
        let currentValue = currentValues[industry] ?? 0
        let investmentAmount = targetValue - currentValue
        guard investmentAmount > 0 else { return nil }

        let sortedCandidates = candidates.sorted {
            if $0.total_score != $1.total_score {
                return $0.total_score > $1.total_score
            }
            return $0.code < $1.code
        }
        return IndustryInvestmentRecommendation(
            industry: industry,
            isNewIndustry: currentValues[industry] == nil,
            currentValue: currentValue,
            investmentAmount: investmentAmount,
            candidates: sortedCandidates
        )
    }.sorted {
        if $0.isNewIndustry != $1.isNewIndustry {
            return $0.isNewIndustry && !$1.isNewIndustry
        }
        if $0.investmentAmount != $1.investmentAmount {
            return $0.investmentAmount > $1.investmentAmount
        }
        let lhsScore = $0.candidates.first?.total_score ?? 0
        let rhsScore = $1.candidates.first?.total_score ?? 0
        if lhsScore != rhsScore { return lhsScore > rhsScore }
        return $0.industry < $1.industry
    }
}

func printIndustryInvestmentRecommendations(
    scoredStocks: [StockScoreModel],
    holdings: [JisiluHoldingRecord],
    totalAssets: Double,
    title: String = "行业加投建议"
) {
    let recommendations = makeIndustryInvestmentRecommendations(
        scoredStocks: scoredStocks,
        holdings: holdings,
        totalAssets: totalAssets
    )

    print("\n\(title)")
    print("单个行业补足到账户总资产的 3%；列出行业内全部总分 >= 270 的合格股票供选择。")

    guard !recommendations.isEmpty else {
        print("当前没有同时满足行业可加投且股票总分 >= 270 的建议。")
        return
    }

    let widths = [12, 10, 14, 14, 56]
    let header = ["优先级", "行业", "可加投金额", "当前市值", "候选股票（总分TTM/PE动）"]
    print(zip(header, widths).map { pad($0, to: $1) }.joined(separator: " | "))
    let lineWidth = widths.reduce(0, +) + (widths.count - 1) * displayWidth(" | ")
    print(String(repeating: "-", count: lineWidth))

    for item in recommendations {
        let candidates = item.candidates.map {
            candidateScoreSummary($0)
        }.joined(separator: "；")
        let row = [
            item.isNewIndustry ? "无持仓行业" : "可加仓行业",
            item.industry,
            "¥\(String(format: "%.0f", item.investmentAmount))",
            "¥\(String(format: "%.0f", item.currentValue))",
            candidates
        ]
        print(zip(row, widths).map { pad($0, to: $1) }.joined(separator: " | "))
    }
}

func candidateScoreSummary(_ model: StockScoreModel) -> String {
    "\(model.name)(\(model.code), TTM \(formatDecimal(model.total_score)) / PE动 \(formatOptional(model.dynamic_total_score)))"
}
