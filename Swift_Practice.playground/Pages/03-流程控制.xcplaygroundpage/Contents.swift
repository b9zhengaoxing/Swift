//: [Previous](@previous)

import Foundation

var str = "Hello, playground"

//: # 3流程控制
//: ## 1. 条件

//: 1.条件（可省略）{不可省略} 只能Bool
//if 1 {print("Yeap")}

let a = "baobao"
if a == "baobao"
{
    print("I love you");
}else {
    print("How are u")
}

//: 3. while 条件 Bool
var a1:Int = 0
while a1 < 10{
    a1 = a1 + 1
//    print(a1)
}


//repeat while
var b1:Int = -1
repeat {
    b1 = b1 + 1
//    print(b1)
}while b1 < 10;



//: 4. for 与range
let array = ["乔峰","段誉","虚竹","王语嫣"]

//range access array
for i in 0...1{
//    print(array[i])
}

//half open range
for i in 0..<2 {
//    print(array[i])
}

//one side range
let rangeA = ...3

//Character range
let rangeCharacter:ClosedRange<Character> = "\0"..."~"
rangeCharacter.contains("G")

//i 默认是 let
for var i in 0...3 {
    i = i + 5;
//    print(i)
}

//间隔区间
let hours = 22
let inter = 2
for i in stride(from: 4, to: hours, by: inter){
//    print(i)
}

//搬新家，加油
//: 5. Swich

//数字、字符串
var sw_int = 10
switch sw_int{
case 1:
    print("Num is 1")
    break;
default:
    break
}


// 5.1 字符，字符串，符合条件
var name = "Liubaobao"
switch name{
case "Liubaobao","小宝宝":
    print("wife");
    fallthrough     //贯穿下一层,并且跳过判断
//    break;
case "nic":
//    print("roommates")
//    break;
    fallthrough     //贯穿下一层
default :
    break
}


// 5.2 元组匹配
var tuple_a = (10,12)
switch tuple_a{
case (10,_):
    print("include 10")
    fallthrough
case (_,13):
    print("include 12")
default:
    break;
}

// 5.3 区间匹配
let num_5_3 = 9
switch num_5_3{
case 10...100:
    print("两位数");
case 0...9:
    print("个位数")
default:
    break;
}


//我要每天关心老婆！！！

//value - bonding ： 分配数值
//print \()

let tuple_e = (10,15)
switch tuple_e{
case (let x,0):
    print("\(x) + 0")
case (0,let y):
    print("0 + \(y)")
case let(x,y):
    print("\(x) + \(y)");
default:
    break;
}
//Where ： 给控制加条件

let tuple_f = (7,15)
switch tuple_f{
case let(x,y) where x != y:
    print("\(x) + \(y)");
default:
    break;
}

//标签语句： 断开谁
out1: for i in 0...5{
    for j in 0...5{
        if j == i{
            continue out1; //可以用break 也可以用 continue
        }
        print("(\(i),\(j))")
    }
}

//: [Next](@next)

