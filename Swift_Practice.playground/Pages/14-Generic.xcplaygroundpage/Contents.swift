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

struct Slack<T>{
    var slack:[T] = []
    
    mutating func push(_ a:T){
        slack.append(a)
    }
    
    mutating func pop()->T? {
        var tmp:T? = slack.last
        slack.removeLast()
        return tmp
    }
}

var slack = Slack<Int>()
for i in 0...10 {
    print(i)
    slack.push(10)
}

for i in 0...10 {
    if let value = slack.pop(){
        print(value)
    }
}

