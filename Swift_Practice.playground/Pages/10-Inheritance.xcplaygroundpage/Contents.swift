//: [Previous](@previous)

import Foundation

//值类型 不支持 Inheritance
//继承 属性 方法

class animal{
    var age = 0
    func type() { // 重写实例方法
        print("animal")
    }
    
    static var Name:String = "动物"
    static var classInt:Int = 0
    class var classValue:Int{
        set{
            classInt = newValue * 2
        }
        get{
            return classInt
        }
    }

    
    subscript(Index:Int) -> Int{
        return Index
    }
}

class Dog:animal{
    var height = 0
    
    override var age:Int{
        set{
            super.age = newValue
        }
        get{
            return super.age
        }
    }
    
    override func type() {
        super.type()
        print("Dog")
    }
    
    override subscript(Index: Int) -> Int {
        return super[Index] + 1
    }
}

var dog1 = Dog()
dog1.type()
print(dog1[1])
print(Dog.Name)
print(dog1.age)
