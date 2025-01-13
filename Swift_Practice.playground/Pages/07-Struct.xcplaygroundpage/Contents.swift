//: [Previous](@previous)

import Foundation

//1. Struct Bool，Int，Double，String，Array，Dictionary 常见类型都是结构


struct Date {
    var year:Int
    var month:Int
    var day:Int
}
//2. initializer 自动初始化器
var date = Date(year: 2024, month: 12, day: 26)
print(date)

//initializer  1. 至少要有初始值
struct Point {
    var x:Int?
    var y:Int?
}

Point(x: 10)
Point(x: 10 , y:12)
Point(y:10)

struct Point1 {
    var x:Int
    var y:Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

//类：默认或Initlializers 需要有
//class Point2{ //Class 'Point2' has no initializers
//    var x:Int
//    var y:Int
//}

class Point2{
    var x:Int
    var y:Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

let point_struct = Point1(x: 10, y: 0)
let point_class = Point2(x: 0, y: 10)

point_class.x = 10
//point_struct.x = 10 Cannot assign to property: 'point_struct' is a 'let' constant



// struct enum is value type class referecence type

