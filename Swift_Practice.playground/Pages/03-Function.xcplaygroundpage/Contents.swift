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
typealias funType1 = (String)->(String,String)
var fn:funType1 = check
print(fn("在不在"))

//Expected '=' in type alias declaration
//typealias funType1:(Int)->(Int)



//func function

//高阶函数 higher - order - function
//function type
func functionFun(fun:(Int,Int)->(Int),a:Int,b:Int) -> Int {
    fun(a,b)
}

//function type as parameter
print(functionFun(fun: add, a: 10, b: 11))


//nest function
func functionRet(_ forward:Bool) -> (Int,Int)->(Int) {
    func funAdd(a:Int,b:Int)->(Int){
        a + b
    }
    
    func funDelete(a:Int,b:Int)->(Int){
        a - b
    }
    
    return forward ? funAdd : funDelete
}

var fn1 = functionRet(false)
print("函数作为返回值\(fn1(1,2))")


