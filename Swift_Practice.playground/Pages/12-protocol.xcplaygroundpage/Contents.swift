//: [Previous](@previous)

import Foundation

protocol PersonRule{
    var name:String{set get}////initial value is not allowed here
    subscript(index:Int)->Int {set get}//subscript in protocol must have explicit { get } or { get set } specifier
    func eat(food:String)
}

class Chinese:PersonRule{
    var name:String = "中国人"
    var index:Int = 1
    init(name: String) {
        self.name = name
    }
    func eat(food:String) {print("Today eat \(food)")}
    
    subscript(index:Int)->Int{
        set{
            self.index = newValue
        }
        get{
            return self.index
        }
    }
}
let person = Chinese(name: "Chenglong")


