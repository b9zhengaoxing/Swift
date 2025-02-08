//: [Previous](@previous)

import Foundation

protocol PersonRule{
    var name:String{set get}////initial value is not allowed here
    var age:Int{set get}
    subscript(index:Int)->Int {set get}//subscript in protocol must have explicit { get } or { get set } specifier
    func eat(food:String)
}

class Chinese:PersonRule{
    var name:String = "中国人"
    private var _age:Int = 0
    var age:Int{
        set{
            _age = newValue
        }
        get{
            return _age
        }
    }
    var index:Int = 1
    init(name: String,age:Int) {
        self.name = name
        self.age = age
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
print(person.age)


protocol Draw{
    static func draw()
    mutating func change()
}

struct Art:Draw{
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


