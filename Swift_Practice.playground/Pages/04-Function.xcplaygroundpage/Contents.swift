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


//: 3. 参数 ：可改  默认 省略 可变参数 输入输出参数
    // 3.1 每个参数默认 argument label）以及一个参数名称（parameter name）通常情况下默认两个相等，如果指定 argument label 可以增加可读性，使用_ 可以ignore
func parameter1(at time:String,_ doA:String){
    print("\(time) + \(doA)")
}

parameter1(at: "10:30 PM", "weak up")


//: 4. 函数重载
//: 5. 内联函数
//: 6. 函数类型
//: 7. 函数嵌套

//: [Next](@next)
