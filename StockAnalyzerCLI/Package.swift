// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StockAnalyzerCLI",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "stock-analyzer", targets: ["StockAnalyzerCLI"])
    ],
    targets: [
        .executableTarget(name: "StockAnalyzerCLI"),
        .testTarget(
            name: "StockAnalyzerCLITests",
            dependencies: ["StockAnalyzerCLI"]
        )
    ]
)
