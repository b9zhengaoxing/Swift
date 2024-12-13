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


