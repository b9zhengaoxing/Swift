
import Foundation

//, 用法
var a = 10,b = 20
var d,c:Int

//String
    //1. """ 中 "" 不需 转义
    //2. 自动delete 公共空行

let quotation = """
        "Even though there's whitespace to the left,"
        the actual lines aren't indented.
            Except for this line.
        Double quotes (") can appear without being escaped.

        I still have \(a + b) pieces of fruit.
        """
print(quotation)

//let
    //  初始化后不可变 ->'age2' used before being initialized
    let age:Int
    //print(age)
    age = 10


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

//tuple
let http404Error = (404,"Not found")
print("The status code is \(http404Error.0)")


let (statusCode,StatusMessage) = http404Error
print("The status code is \(statusCode)")

let (justTheStatusCode,_) = http404Error

let http200Status = (statusCode:200,description:"OK")
print("The status code is \(http200Status.statusCode)")


//TypeAlias
typealias AudioABC = UInt8
let audio = AudioABC.max
