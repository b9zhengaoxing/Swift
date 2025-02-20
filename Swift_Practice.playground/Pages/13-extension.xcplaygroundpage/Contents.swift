//: [Previous](@previous)

import Foundation

class Person{
    private var _location:[[Int]] = [[0,1,2],[0,1,2],[0,1,2]]
    private var _name:String = "person"
}

extension Person{
    var name:String{//computed property
        set{
            _name = newValue
        }get{
            return _name
        }
    }
    
    convenience init(age:Int) {//convenience init
        self.init()
    }
    
    subscript (row:Int,column:Int) -> Int{
        set{
            if row >= 0 && row <= 2 && column >= 0 && column <= 2{
                self._location[row][column] = newValue
            }
        }get{
            if row >= 0 && row <= 2 && column >= 0 && column <= 2{
                return self._location[row][column]
            }
            return 0
        }
    }
}

var person = Person()
person[1,1] = 15
print(person[1,1])


extension Double{
    var km:Double{self/1000}
    var m:Double{self}
    var dm:Double{self*10}
}
var distance:Double  = 100
print(distance.dm)

extension Int{
    mutating func square()->Int{
        self = self * self
        return self
    }
    
    enum Kind{case negative,zero,positive}
    var kind:Kind{//这个地方不会写了
        switch self { //rang 写法 ..<0  或者 1...  没有 <..
        case ..<0:
            return Kind.negative
        case 1...:
            return Kind.positive
        default:
            return Kind.zero
        }
    }
    
    var kind2:Kind{
        switch self { //rang 写法 ..<0  或者 1...  没有 <..
        case let x where x < 0:
            return Kind.negative
        case let x where x > 0:
            return Kind.positive
        default:
            return Kind.zero
        }
    }
}

print(1.kind)
print(1.kind2)
//2.square() literals are not mutable
var value = 2
print(value.square())

