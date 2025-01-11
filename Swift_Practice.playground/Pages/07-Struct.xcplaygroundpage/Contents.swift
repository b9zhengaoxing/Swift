//: [Previous](@previous)

import Foundation

//Struct Bool，Int，Double，String，Array，Dictionary 常见类型都是结构

struct Date {
    var year:Int
    var month:Int
    var day:Int
}

//initializer 自动初始化器
var date = Date(year: 2024, month: 12, day: 26)
print(date)
