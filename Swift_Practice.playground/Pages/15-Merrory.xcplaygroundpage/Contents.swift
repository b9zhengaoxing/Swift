//: [Previous](@previous)

import Foundation

class Person {
    var fn:(()->())?
    
    func run() {
        print("run")
    }
    deinit {
        print("deinit")
    }
}

func test(){
    var person:Person = Person()
    person.fn = { [weak person] in
        person?.run() }
}

test()
