//: [Previous](@previous)

import Foundation

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

//闭包的缩写
func exec(v1:Int , v2:Int , fnc:(Int,Int)->Int){
    print(fnc(v1 , v2))
}

//完整的闭包
exec(v1: 10, v2: 20, fnc: {
    (a1:Int , a2:Int) in
    return a1 + a2
})

//类型判断
exec(v1: 11, v2: 12, fnc: {
    (a1, a2) in
    a1 + a2
})

exec(v1: 1, v2: 2, fnc: {
    a1, a2 in
    a1 + a2
})

exec(v1: 22, v2: 17, fnc: {
    $0 + $1
})

//极致简化了
exec(v1: 2, v2: 2, fnc: - )


