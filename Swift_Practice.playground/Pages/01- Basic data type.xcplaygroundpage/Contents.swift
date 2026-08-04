
import UIKit
import SwiftUI
import PlaygroundSupport// 支持异步运行，显示实时试图


let a = 10
let b = 20
var c = a + b
c += c

//1. 不需要转义
//2. 自动删除公共空行
//3. 方便计算
let quotation = """
        "Even though there's whitespace to the left,"
        the actual lines aren't indented.
            Except for this line.
        Double quotes (") can appear without being escaped.

        I still have \(a + b) pieces of fruit.
        """
print(quotation)

let view = UIView()
view.frame = CGRect(x:0, y:0, width:100, height: 100)
view.backgroundColor = UIColor.blue

//显示实时视图
PlaygroundPage.current.liveView = view

//不要求编译时期确定变量 常量 要求在使用前确定数值

//常量
let age1 = 10
let age2:Float

//Constant 'age2' used before being initialized
//print(age2)

age2 = 10

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


