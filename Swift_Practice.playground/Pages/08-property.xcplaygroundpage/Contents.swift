//: [Previous](@previous)

import Foundation

//Model 计算属性
struct Circle {
    var radius:Double
    
    var zhouChang: Double {
        3.14 * 2 * radius
    }
    
    var diameter:Double{
        set{
            radius = newValue/2
        }
        get{
            radius * 2
        }
    }
}

var circle = Circle(radius: 10)
print(circle.zhouChang)
circle.diameter = 10
print(circle.zhouChang)

enum TestEnum:Int{
    case test1 = 1, test2 = 2, test3 = 3
    var rawValue:Int{ //本质上是computed property
        switch self {
        case .test1:
            1
        case .test2:
            2
        case .test3:
            3
        }
    }
    
}
print(TestEnum.test1.rawValue)

print(TestEnum(rawValue: 1) ?? 0)
if let value = TestEnum(rawValue: 2){
    print(value)
}

// lazy : 1. store  2. {}() == func()
class Car{
//    lazy var image:Int{print("lazy is calling")}   error: 08-property.xcplaygroundpage:52:9: cannot convert return expression of type '()' to return type 'Int'
//    lazy var image:Int = {
//        print("lazy is calling")
//        return 10
//    }
//    但当前赋值的内容是一个闭包（closure）。如果希望执行这个闭包并将其结果赋值给 image，需要在闭包后面加上 ()
    lazy var image:Int = {
        print("lazy is calling")
        return 10
    }() //闭包 作为函数，() 是后面执行了
    
    init() {
        print("hello")
    }
}

let car = Car()
print(car.image)

struct Piont{
    var x = 0
    lazy var y = 10
}

let p = Piont()
//p.y // - - 
