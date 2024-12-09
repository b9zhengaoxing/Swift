//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"

enum firstEnumeration{
    case number(data:Int)
    case code(Int,Int,String)
}

let aValue = firstEnumeration.code(12, 12, "100")

print(aValue);
//: [Next](@next)
