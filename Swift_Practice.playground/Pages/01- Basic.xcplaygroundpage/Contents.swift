
import UIKit
import SwiftUI
import PlaygroundSupport// 支持异步运行，显示实时试图

print("hello, world")

let a = 10
let b = 20
var c = a + b
c += c

let view = UIView()
view.frame = CGRect(x:0, y:0, width:100, height: 100)
view.backgroundColor = UIColor.blue

//显示实时视图
PlaygroundPage.current.liveView = view

//不要求编译时期确定变量 常量 要求在使用前确定数值，

//常量
let age1 = 10
let age2:Int

//Constant 'age2' used before being initialized
//print(age2)

age2 = 100

func getAge() -> Int{
    return 30
}

//Immutable value 'age2' may only be initialized once
//age2 = getAge()

// literal
let bool = true
let string = "hello world"
let character:Character = "🐶" //Character 也使用单引号

//为了对齐可以补0 _
// 整数
let intDecimal = 000_17
let intBinary = 0b10001//二进制了
let intOctal = 0o21
let inthexadecimal = 0x11

// 浮点数
let doubleDecimal = 000_125.00
let doubleHexadecimail1 = 0xFp4

let array = [1,3,4,5,6,7]
let dictionary = ["age":1,"name":12,"height":120]

// 整数相互转换
let int1:UInt16 = 2_000
let int2:UInt8 = 1
//Binary operator '+' cannot be applied to operands of type 'UInt16' and 'UInt8'
//let int3 = int1 + int2
let int3 = int1 + UInt16(int2)

//整数 浮点数转换
let int12 = 3
let double12 = 0.14
//Binary operator '+' cannot be applied to operands of type 'Int' and 'Double'
//let pi = int12 + double12

let pi = Double(int12) + double12

//字面量可以直接叠加
let pi2 = 3 + 000_0.14

//元组
let http404Error = (404,"Not found")
print("The status code is \(http404Error.0)")


let (statusCode,StatusMessage) = http404Error
print("The status code is \(statusCode)")

let (justTheStatusCode,_) = http404Error

let http200Status = (statusCode:200,description:"OK")
print("The status code is \(http200Status.statusCode)")

//Cannot convert value of type 'Int' to expected condition type 'Bool'
//if 15{}

//流程控制
//Cannot find 'age' in scope
//int age = 25
var age = 25
if age > 25 {}

//没有++ --
while age>25 {
//    Expected expression after operator
//    age --
    age -= 1
}

var num = -2
repeat{
    print("num is \(num)")
    num += 1
}while num<0

let names = ["lucy","John","william","max"]

//i 模式是let
for i in 0...2{
//    i += 1  'i' is a 'let' constant
    print(names[i])
}

//可以声明 是var
for var i in 0..<2{
    i += 1
    print("第 \(i) 是 \(names[i])")
}

//循环三次
var rage = 0...2
for _ in rage{
    print(72)
}

//区间运算法用在数组上
for name in names{
    print(name)
}

for name in names[...2] {
    print("range in array \(name)")
}

//区间类型
let range1:ClosedRange<Int> = 1...3
let range2:Range<Int> = 1..<3
let range3:PartialRangeThrough<Int> = ...5

//带间隔的区间值
let hours = 11
let hourInterval = 2
for tickMark in stride(from:4,through:hours,by:hourInterval){
    print(tickMark)
}


    
    
