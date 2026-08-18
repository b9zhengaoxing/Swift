import Testing
@testable import StockAnalyzerCLI

struct IndustryInvestmentReportTests {
    @Test func recommendsEveryQualifiedStockAndPrioritizesMissingIndustries() {
        let scoredStocks = [
            stock(name: "保险甲", code: 601601, percent: 0.10),
            stock(name: "保险乙", code: 601318, percent: 0.30),
            stock(name: "银行甲", code: 601997, percent: 0.15),
            stock(name: "不足270", code: 601319, percent: 0.31),
            stock(name: "电力甲", code: 2608, percent: 0.15)
        ]
        let holdings = [
            JisiluHoldingRecord(name: "华夏银行", code: 600015, marketValue: 10_000),
            JisiluHoldingRecord(name: "江苏国信", code: 2608, marketValue: 40_000)
        ]

        let recommendations = makeIndustryInvestmentRecommendations(
            scoredStocks: scoredStocks,
            holdings: holdings,
            totalAssets: 1_000_000
        )

        #expect(recommendations.count == 2)
        #expect(recommendations[0].industry == "保险")
        #expect(recommendations[0].isNewIndustry)
        #expect(recommendations[0].investmentAmount == 30_000)
        #expect(recommendations[0].candidates.map(\.name) == ["保险甲", "保险乙"])
        #expect(recommendations[0].candidates.map(\.total_score) == [290, 270])

        #expect(recommendations[1].industry == "银行")
        #expect(!recommendations[1].isNewIndustry)
        #expect(recommendations[1].investmentAmount == 20_000)
        #expect(recommendations[1].candidates.map(\.name) == ["银行甲"])
    }

    @Test func excludesRiskFilteredStocks() {
        let scoredStocks = [
            stock(name: "ST风险", code: 601601, percent: 0),
            stock(name: "*ST风险", code: 601318, percent: 0),
            stock(name: "无形资产过高", code: 601319, percent: 0, intangibleAssetRatio: 0.21)
        ]

        let recommendations = makeIndustryInvestmentRecommendations(
            scoredStocks: scoredStocks,
            holdings: [],
            totalAssets: 1_000_000
        )

        #expect(recommendations.isEmpty)
    }

    private func stock(
        name: String,
        code: Int,
        percent: Double,
        intangibleAssetRatio: Double? = 0.05
    ) -> StockScoreModel {
        StockScoreModel(
            name: name,
            code: code,
            pe: 1,
            dynamicPE: 1,
            pb: 0.1,
            percent: percent,
            price: 10,
            intangibleAssetRatio: intangibleAssetRatio,
            debtAssetRatio: 20
        )
    }
}
