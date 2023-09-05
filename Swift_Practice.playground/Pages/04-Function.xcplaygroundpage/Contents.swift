//: [Previous](@previous)

import Foundation

//: 1. 函数定义  func 封装，输入，输出  形参默认是let
func work1(x:Int,y:Int)->Int{
    return x + y
}
print(work1(x:1,y:2))

//: 2. 返回 无返回 隐式返回 元组返回
//func work() {
//func work() -> Void{
func work2() -> (){
    print("hello world")
}

func work3(x:Int,y:Int)->Int{
    return x + y
}

func work4(x:Int,y:Int,z:Int) -> (x:Int,y:Int,z:Int){
    (x,y,z)
}

let coordnate = work4(x: 10, y: -1, z: 13)
coordnate.x
coordnate.y
coordnate.z


//: 3. 参数 ：参数变迁  默认  可变参数 输入输出参数
    // 3.1 每个参数默认  argument label）以及一个参数名称（parameter name）通常情况下默认两个相等，如果指定 argument label 可以增加可读性，使用_ 可以ignore
func parameter1(at time:String,_ doA:String){
    print("\(time) + \(doA)")
}

parameter1(at: "10:30 PM", "weak up")

    // 3.2 默认参数
func parameter2(at time:String = "7:00 AM",doA:String = "Game"){
    print("\(time) + \(doA)")
}

parameter2()
parameter2(doA: "work")

    // 3.3 可变参数，每个函数只有一个，可变参数后面标签不能圣罗
func parameter3(numbers:Int...,what:String = "people") -> (num:Int,what:String){
    var ret:Int = 0;
    for num in numbers{
        ret += num;
    }
    return (ret,what);
}

var para3 = parameter3(numbers:1,2,3,4,5,what:"dog")


//：今日早睡
//:open thedoor
//: 4. 函数重载
//: 5. 内联函数
//: 6. 函数类型
//: 7. 函数嵌套

//: [Next](@next)
