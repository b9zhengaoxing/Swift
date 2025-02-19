//: [Previous](@previous)

import Foundation

class Person{
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
    
    subscript (index:Int) -> String{
        set{
            
        }get{
            if index == 0{
                return _name
            }else{
                return _name
            }
        }
    }
}

