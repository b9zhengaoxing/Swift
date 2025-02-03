//: [Previous](@previous)

import Foundation

//designated 和 convenience 在 inheritance 演示
class parent{
    var name:String
    var home:String
    
    init(name: String, home: String) {
        self.name = name
        self.home = home
    }
    
    convenience init(name:String) {
        self.init(name: name, home: "四海为家")
    }
}

class child: parent {
    //子类没有指定初始化器，自动继承父类指定初始化器
    convenience init(name:String) {
        self.init(name: name, home: "桑梓之地")
    }
}

var kid = child(name: "黄晓明")
print("name:\(kid.name) home:\(kid.home)")


//两步初始化 Demo
// 子类到父类，先子类所有store Value  父类初始化方法
// 父类到子类，可以修改参数，执行方法
class Person{
    var name:String
    var age:Int{
        //本类初始化修改不触发，子类修改会触发
        willSet{
            print("willSet \(newValue)")
        }
        didSet{
            print("didSet \(oldValue)")
        }
    }
    required init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    deinit{
        print("Person 对象已经销毁")
    }
}

class Chinese:Person{
    var animal:String
 
    init(animal: String,name: String, age: Int) {
        self.animal = animal
        super.init(name: name, age: age)
        self.age = 11
        self.animal = "蛇"
        self.doSth()
    }
    
    required init(name: String, age: Int) {//reqired 要求必须实现
        self.animal = "蛇"
        super.init(name: name, age: age)
        self.doSth()
    }
    
    func doSth() {
        print(self.name + String(self.age) + self.animal)
    }
    
    deinit{
        print("Chinese 对象已经销毁")
        //先执行子类，在执行父类，不接收参数，不能自行调用
    }
}

let person = Person(name: "Jack", age: 67)
var chinese_person = Chinese(name: "Jack", age: 67)
var chinese_person1:Chinese? = Chinese(animal: "龙", name: "神拳", age: 11)
chinese_person1 = nil



struct Phone{
    var name:String
    init?(name: String) {
        if name.isEmpty {
            return nil
        }
        self.name = name
    }
}

if let value = Phone(name: "") {
    print(value)
}else{
    print("phone 初始化失败")
}


