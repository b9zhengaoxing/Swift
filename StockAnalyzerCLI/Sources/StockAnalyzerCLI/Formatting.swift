import Foundation

private let decimalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.minimumIntegerDigits = 1
    return formatter
}()

func displayWidth(_ text: String) -> Int {
    (displayUnits(text) + 1) / 2
}

func displayUnits(_ text: String) -> Int {
    text.unicodeScalars.reduce(0) { result, scalar in
        result + (scalar.isASCII ? 2 : 3)
    }
}

func pad(_ text: String, to width: Int) -> String {
    let missingUnits = max(0, width * 2 - displayUnits(text))
    return text + String(repeating: " ", count: (missingUnits + 1) / 2)
}

func formatDecimal(_ value: Double) -> String {
    decimalFormatter.string(from: NSNumber(value: value)) ?? "--"
}

func formatOptional(_ value: Double?) -> String {
    value.map(formatDecimal) ?? "--"
}
