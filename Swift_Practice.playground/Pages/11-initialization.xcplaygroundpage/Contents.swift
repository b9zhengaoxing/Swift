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



