//: [Previous](@previous)

import UIKit

//: # 2. 数据类型
//: ## 1. 变量 var
var a = 10;
a = 12;

//: 1.💡var let  初始化之前 —— 不能使用  @可选类型
//let a1;
//print(a1)

//: ## 2 常量 let
//: 1. 🍅 常量 let 不要求编译时候确定，使用前要求赋值
let b = 10;

//: 2. 💡 常量 声明 类型
let let_b:Int
let_b = 10

//: 3.💡 变量var_num 运行时一直在变 const_a 不要求 const_a
var var_num = 100;
var_num += 1;
let h = var_num;

//💡 函数的值，运行时确定
func Age() -> Int {
    return 30
}
let age3 = Age();


//: ## 3 数据类型
//: 1. value type:
//:    enum （Optional）
//:    struct（String Array Int Bool Float Double Character Dictionary set）
//: 2. referance type: class

//struct，可以操作性增强
var a2:Int8
print(Int8.max)

//: ## 4.字面量

//: 1.character类型也是 双引汉
let character:Character = "😁"

//: 2. 进制 _ 很好间隔 && 前面可以补0

let intDecimal = 000_1_7
let intBinary = 0b1_000_1
let intOctal = 0o21
let intHexadecimal = 0x11

let doubleDecimal = 125.0
let doubleHexadecimal1 = 0xFp2// 15* 2^2

let array = [1,2,3,4,5]
let dictionary = ["age":1,"heigt":2]

print(array[0])
//???
print(dictionary["age"] ?? 1)


//: ## 5 类型转换

let int1:UInt8 = 16
let int2:UInt16 = 24
let int3 = int1 + UInt8(int2)

//: 1. 字面量可以直接相加，因为没有明确的类型
let result = 3 + 3.14

//: ## 6 元组 tuple
//用于返回值很给力

//下标访问
let http404Error = (404,"not Found")
http404Error.0
http404Error.1

//声明可改，限定类型
var firstTuple:(Int,String) = (1,"hello world")
firstTuple.0 = 2
firstTuple.1 = firstTuple.1.appending("!")


typealias httpCode = (code:Int,Desc:String)
var codeRet:httpCode = (401,"???")
print(codeRet)


//name tuple Elements
let (code1,des1) = http404Error
code1
des1
let (code2,_) = http404Error //省略
code2

let error = (code:404,des:"not Found")//just like dic
error.code
error.des

//use google（）

//Add/Remove Elements From Tuple cannot


//dic in a tuple
let missU = ("liubaobao",1,["code":1,"desc":"hello"])
print(missU)


////声明是：
//let apples:Int = 3;
//let oranges:Int = 4;
//
//let quotation = """
//I said "I have \(apples) apples."
//And then I said "I have \(apples + oranges) pieces of fruit."
//"""
//
//let quotation1 = "今天" + String(apples);//显示类型转换
//
//print(quotation1);


//: [Previous](@previous)



