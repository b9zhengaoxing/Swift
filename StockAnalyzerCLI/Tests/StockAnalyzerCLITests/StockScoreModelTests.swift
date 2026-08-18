import Testing
@testable import StockAnalyzerCLI

struct StockScoreModelTests {
    @Test func calculatesDynamicPeScoreAndDynamicTotalScore() {
        let stock = StockScoreModel(
            name: "测试股票",
            code: 999999,
            pe: 5,
            dynamicPE: 15,
            pb: 0.5,
            percent: 0.25,
            price: 10,
            intangibleAssetRatio: 0.05,
            debtAssetRatio: 20
        )

        #expect(stock.pe_score == 100)
        #expect(stock.dynamic_pe_score == 50)
        #expect(stock.total_score == 275)
        #expect(stock.dynamic_total_score == 225)
    }

    @Test func keepsDynamicScoresEmptyWhenDynamicPeIsMissing() {
        let stock = StockScoreModel(
            name: "测试股票",
            code: 999999,
            pe: 5,
            dynamicPE: nil,
            pb: 0.5,
            percent: 0.25,
            price: 10,
            intangibleAssetRatio: 0.05,
            debtAssetRatio: 20
        )

        #expect(stock.dynamic_pe_score == nil)
        #expect(stock.dynamic_total_score == nil)
    }
}
