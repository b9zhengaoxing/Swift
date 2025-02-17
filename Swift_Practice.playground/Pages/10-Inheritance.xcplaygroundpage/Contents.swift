//: [Previous](@previous)

import Foundation

class animal{
    var age = 0
    var leg = 4
    final var type:String = "动物"
    static var number:Int = 0
    class var number1:Int{//重写
        set{
            number = newValue
        }
        get{
            number
        }
    }
    subscript(Index:Int) -> Int{
        return Index
    }
}

class Dog:animal{
    override var age:Int{//override cumpute
        set{
            super.age = newValue
        }
        get{
            return super.age
        }
    }
    override var leg: Int{
        willSet{
            print("willSet \(newValue)")
        }
        didSet{
            print("didSet \(oldValue)")
        }
    }
    override class var number1:Int {
        set{
            number = newValue * 2
        }
        get{
            number
        }
    }
    override subscript(Index: Int) -> Int {
        return super[Index] + 1
    }
}

