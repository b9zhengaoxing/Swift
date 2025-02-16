//: [Previous](@previous)

import Foundation

//存储属性 lazy : 1. store  2. {}() == func()
class LazyDemo{
//    但当前赋值的内容是一个闭包（closure）。如果希望执行这个闭包并将其结果赋值给 image，需要在闭包后面加上 ()
    lazy var laValue:Int = {
        print("lazy is calling")
        return 10
    }() //闭包 作为函数，() 是后面执行了
    
    init() {
        print("hello")
    }
}

let lazy_demo = LazyDemo()
print(lazy_demo.laValue)

//计算属性
struct Circle {
    var radius:Double //store value
    var zhouChang: Double {//cumpute Value
        3.14 * 2 * radius
    }
    var diameter:Double{//计算属性 直径
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



// rawValue 原始值
// 是给每一项分配的Value 本质是 computed property
enum TestEnum:Int{
    case test1 = 1, test2 = 2, test3 = 3
}

enum TestEnum1:Int{
    case test1 = 1, test2 = 2, test3 = 3 //raw value
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

//Observer 父类初始化方法里面赋值，不触发，子类触发
class Person{
    init(name: String) {
        self.name = name
    }
    var name:String{
        willSet{
            print("will set \(newValue)")
        }
        didSet{
            print("did set \(oldValue)")
        }
    }
}

class Chinese:Person{
    override init(name: String) {
        super.init(name: name)
        self.name = name; //子类里面赋值一定会触发
    }
}

var testOb = Person(name: "成龙")
var testOb1 = Chinese(name: "成龙")
testOb.name = "Jack"

//1. Type property
//    1. static  store + cannot override
//    2. class  get set override
class Tool{
    static var count = 0
    static var _name:String = ""
    class var name:String{ // //class stored properties not supported in classes
        set{
            _name = newValue
        }
        get{
            return _name
        }
    }
}

class Car:Tool{
    //    override static var count = 1
    override class var name:String{
        set{
            _name = "I am a Car"
        }
        get{
            return _name
        }
    }
}

//单例模式
// 一次初始化 static let private

class Singleton{
    static let shared = Singleton()
    private init(){}
    func doSomething(){}
}

Singleton.shared.doSomething()

func outer(value:inout Int) -> Int {
    value = value + 115
    return value
}

var tmpValue = 15
outer(value: &tmpValue)
print(tmpValue)



print(Car._name)

//全局变量，局部变量
// 计算属性
var num:Int{
    set{
        print(newValue)
    }
    get{
        return 10
    }
}

num = 100
print(num)

