//: [Previous](@previous)

import Foundation

//值类型 不持之 Inheritance
//继承 属性 方法

class animal{
    var age = 0
    func type() -> String {
        return "animal"
    }
}

class Dog:animal{
    var height = 0
    
    override func type() -> String {
        return "Dog"
    }
}

var dog1 = Dog()
print("\(dog1.age)")
