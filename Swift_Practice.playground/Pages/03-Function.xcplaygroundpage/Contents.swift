import Foundation
//默认是let 也只能是
func add(a:Int,b:Int) -> Int{
//    a = a + b 'a' is a 'let' constant
    var c = a + b
    return c
}

print(add(a: 10, b: 20))

//_ 一定要用空格
//Argument Label
func exchange(_ a:Int,_ b:Int)->(Int,Int){
    (b,a)  // implicit return
}

print(exchange(10,1))

//Default Parameter
func check(_ name:String = "hello world") -> (String,String){
    (name,"!")
}
print(check("你好"))

//variadic Parameter
func sum(_ numbers: Int...) -> Int {
    var value:Int = 1
    for i in numbers {
        value += i
    }
    return value
}

print(sum(1,2,3,4,5,6))

//public func print(_ items: Any..., separator: String = " ", terminator: String = "\n")
print(1,2,3,4,5,6 , separator: " - " , terminator: "")

//overload
func sum(_ a:Int , _ b:Int , _ c:Int) -> Int{
    a + b + c
}
print("\n\(sum(1,2,3))")

//Function Type
//var fn(String) -> String = check
//var fn:(String)->String = check()
var fn:(String)->(String,String) = check
print(fn("在不在"))

//func function

//高阶函数 higher - order - function
