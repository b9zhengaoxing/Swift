//: [Previous](@previous)

import Foundation

//值类型
//1. Struct Bool，Int，Double，String，Array，Dictionary，set 常见类型都是结构
struct Date {
    var year:Int
    var month:Int
    var day:Int
}
//2. initializer 自动初始化器,有严格的先后顺序
var date = Date(year: 2024, month: 12, day: 26)
print(date)


//值类型赋值
struct ValueType{

}

class RefType{
    deinit {
        print("RefType deinit")
    }
}

var valueType0:ValueType = ValueType()
var valueType1:ValueType = valueType0
var refType = RefType()
refType = RefType()

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

//nested type
struct Poker {
    enum Suit: Character {
        case spades = "♠" , hearts = "♥"
    }
    enum Rank:Int {
        case two = 2, three,four
    }
}

print(Poker.Suit.hearts)


//method
class Animal{
    class func count(){}
    static func name(){}
}

class dog:Animal{
    override class func count(){}
//    override static func name(){} //cannot override static method
}

struct Animal2{
    var name:String = "狂言"
    mutating func changeName(name:String){
        self.name = name
    }
}

var animal = Animal2()
animal.changeName(name: "12")
