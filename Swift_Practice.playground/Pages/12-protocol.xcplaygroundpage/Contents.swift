//: [Previous](@previous)

import Foundation

//What is protocol
protocol PersonRule{
    var name:String{set get}////initial value is not allowed here
    subscript(index:Int)->Int {set get}//subscript in protocol must have explicit { get } or { get set } specifier
    func eat(food:String)
}

class Chinese:PersonRule{
    var name:String = "中国人"
    private var _age:Int = 0
    var index:Int = 1
    init(name: String,age:Int) {
        self.name = name
    }
    func eat(food:String) {print("Today eat \(food)")}
    
    subscript(index:Int)->Int{
        set{
            self.index = newValue
        }
        get{
            return self.index
        }
    }
}
let person = Chinese(name: "Chenglong" , age:12)


//property 与属性
protocol propertyDemo{
    var name:String{set get}
    var age:Int{set get}
    static var count:Int{get}
}

struct propertyDemoStructure:propertyDemo{
    var name: String = "小李"
    private var _age:Int = 0
    var age:Int{
        set{
            _age = newValue
        }get{
            return _age
        }
    }
    static var count:Int{
        return 100
    }
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

var proDemo = propertyDemoStructure(name:"成龙",age:25)
print("\(proDemo.age) \(propertyDemoStructure.count)")


//inharitance and func mutate static
protocol Draw{
    static func draw()
}

protocol ArtDraw:Draw{
    mutating func change()
}

struct Art:ArtDraw{
    var age = 0
    static func draw() {
        print("hello hi")
    }
    
    mutating func change() {
        age = 111
    }
}

Art.draw()

var art = Art()
art.change()


//init 非finil 需要增加 required
protocol DrawAble{
    init()
    init?(x:Int,y:Int)
}

class DrawAbleImpliment:DrawAble{
    required init(){}
    required init?(x:Int,y:Int){}
}

//inheritance 与 组合
protocol liveable{}
protocol runable:liveable{}
class RunningMan:liveable,runable{}
typealias realRunman = RunningMan & liveable & runable

func run0(obj:RunningMan){}
func run1(obj:liveable){}
func run2(obj:liveable & runable){}
func run3(obj:RunningMan & liveable & runable){}
func run4(obj:realRunman){}

//协议的应用
class Person:CustomStringConvertible,CustomDebugStringConvertible{
    var description: String{"person"}
    var debugDescription: String{"person_debug"}
}

var person1 = Person()
print(person1)

//遍历枚举
enum Season:CaseIterable{
    case sprint,summer,fall,winter
}

let seasons = Season.allCases
print(seasons.count)

for season in seasons {
    print(season)
}


//常见 ？ 方法总结

