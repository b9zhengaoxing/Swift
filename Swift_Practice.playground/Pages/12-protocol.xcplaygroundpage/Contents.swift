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

class Person:CustomStringConvertible,CustomDebugStringConvertible{
    var description: String{"person"}
    var debugDescription: String{"person_debug"}
}

var person1 = Person()
print(person1)
