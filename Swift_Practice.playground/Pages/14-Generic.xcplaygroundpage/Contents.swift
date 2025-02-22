//: [Previous](@previous)

import Foundation

func swapNum<T>(_ a:inout T,_ b: inout T) {
    var tmp = a
    a = b
    b = tmp
}

class Person{
    var name:String
    init(name: String) {
        self.name = name
    }
}

var a = 10
var b = 20
var jack = Person(name: "Jack")
var adam = Person(name: "Adam")

swapNum(&a, &b)
print("a:\(a) b:\(b)")
swapNum(&jack, &adam)
print(jack.name + adam.name)

struct Stack<T>{
    var stack:[T] = []
    
    mutating func push(_ a:T){
        stack.append(a)
    }
    
    mutating func pop()->T? {
        if stack.isEmpty{
            return nil
        }else{
            return stack.removeLast()
        }
    }
}

var stack = Stack<Int>()
for i in 0...10 {
    stack.push(i)
}

while let x = stack.pop(){
    print(x)
}

