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
    print(i)
}

//: [Next](@next)

