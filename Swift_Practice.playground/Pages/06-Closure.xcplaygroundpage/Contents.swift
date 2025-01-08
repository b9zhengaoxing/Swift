//: [Previous](@previous)

import Foundation

//一： 标准闭包
//Clousure Expression 定义一个函数
func sum(_ v1:Int, _ v2 :Int) -> Int{
    v1 + v2
}

var fn = {
    (v1:Int , v2:Int) -> Int in
    return v1 + v2
}

print(fn(1,2))

print(
    {//Closure 完整的
        (v1:Int,v2:Int) -> Int in
        v1 + v2
    }(10,20)
)

//二 闭包的缩写
func exec(v1:Int , v2:Int , fnc:(Int,Int)->Int){
    print(fnc(v1 , v2))
}

//0. 完整的闭包, 定义了一个函数
exec(v1: 10, v2: 20, fnc: {
    (a1:Int , a2:Int) in
    return a1 + a2
})

//1. 参数 类型 返回值 类型  1.1 一个表达式，return
exec(v1: 1, v2: 2, fnc: {
    a1, a2 in
    a1 + a2
})

//2. 参数名缩写
exec(v1: 22, v2: 17, fnc: {
    $0 + $1
})

//3. 完全Omit
exec(v1: 2, v2: 2, fnc: - )


//尾随闭包： Trailing closure
//1. 书写在调用 省略   参数标签   () 外面    的闭包表达式
exec(v1: 10, v2: 15) { a1, a2 in
    a1 + a2
}

//2. 唯一实参 Omni （）
func exec2(fn:(Int,Int)->Int){
    print(fn(1,2))
}

exec2(fn: {
//    a1:Int ,a2:Int in  缺少（）
    (a1:Int , a2:Int) in
    return a1 + a2
})

//exec2 { a1 + a2} can not find a1 in scope
exec2{$0 + $1}

//Omit 参数
exec2 { _, _ in
    15
}

//exec2{+} 尾随闭包 不能按照这样圣罗
exec2(fn:+)


//数组排序
var nums = [11,2,18,7,39,72,1,3,4]

func sortNum(a1:Int,a2:Int)->Bool{
    a1 > a2  //大的排前面
}

nums.sort(by:sortNum)
nums.sort(by:<) //极致省略  不能省略By
nums.sort{$0 < $1} //Omit （） 标签


//哪些是闭包？
// 1. global fun is closure can't capture values
// 2. nested fun is closure capture can capture values ,reference type
typealias Fn = (Int)->(Int)
//var num = 0//全局变量全局累积
func getFun() -> Fn{
    var num = 0 //局部变量，局部累积
    func tmpFun(a:Int) -> Int {
        num += a
        return num
    }
    return tmpFun
}

var Fn1 = getFun()
var Fn2 = getFun()

Fn1(1)
Fn2(2)
Fn1(3)
Fn2(4)
Fn1(5)
Fn2(6)

//var num = 0//全局变量全局累积
func getFun1() -> Fn{
    var num = 0 //局部变量，局部累积
    return {
//        num += $0 cannot convert value of type '()' to closure result type 'Int' 无法判断有返回值？
        num += $0
        return num
    }
}

Fn1 = getFun1()
Fn2 = getFun1()

Fn1(1)
Fn2(2)
Fn1(3)
Fn2(4)
Fn1(5)
Fn2(6)

//对于这个练习的理解：closure capture 基本算是想象成一个类的实例
typealias FnNew = (Int)->(Int,Int)
func getFuns() -> (FnNew,FnNew){
    var num1 = 0
    var num2 = 0
    func plus(_ i:Int) ->(Int,Int){
        num1 += i
        num2 += i << 1
        return (num1,num2)
    }
    
    func mins(_ i:Int) -> (Int,Int){
        num1 -= i
        num2 -= i << 1
        return (num1,num2)
    }
    
    return (plus,mins)
}

let (p,m) = getFuns()
p(5)
m(4)
p(3)
m(2)

// escape closure VS non - escape closures can escape 调用，  asynchronous as an completion handle

var completionHanders:[()->Void] = []

func someFunctionWithEscapingClosureHander(completionHandler:@escaping ()->Void){
    completionHanders.append (completionHandler)
}

func somFuntionWithNoneEscapingClosure(closure: ()-> Void){
//    completionHanders.append(closure)  converting non-escaping parameter 'closure' to generic parameter 'Element' may allow it to escape
    closure()
}


class SomeClass {
    var x = 0
    func doSomething(){
        somFuntionWithNoneEscapingClosure {
            x = 20 //显示调用 小心循环引用问题
        }
        someFunctionWithEscapingClosureHander {
            x = 30
        }
    }
}

var instance = SomeClass()
instance.doSomething()
print(instance.x)

completionHanders.first?()
print(instance.x)





