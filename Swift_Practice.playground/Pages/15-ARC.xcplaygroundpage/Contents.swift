//: [Previous](@previous)

import Foundation

//强引用
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
    person.fn = {//循环引用风险
        [weak person] in
        person?.run()  //可选链条
    }
}
test()

//强引用
class Dog<T>{
    var hate:T?
    deinit {
        print("dog deinit")
    }
}

class Cat{
    weak var hate:AnyObject?
    deinit {
        print("cat deinit")
    }
}

var cat:Cat? = Cat()
var dog:Dog? = Dog<Cat>()
cat?.hate = dog
dog?.hate = cat
cat = nil
//dog = nil




