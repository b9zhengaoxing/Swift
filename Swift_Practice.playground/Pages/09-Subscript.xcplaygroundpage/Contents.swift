//: [Previous](@previous)

import Foundation

//Subscripts Access the elements of a collection

class Piont{
    var x = 0.0 , y = 0.0
    subscript (index:Int) -> Double{
        set{
            print("hello \(newValue)")
            if newValue == 0{
                print("hello 0 \(newValue)")
                x = newValue
            }else{
                print("hello 1 \(newValue)")
                y = newValue
            }
        }
        get{
            if index == 0{
                return x
            }else{
                return y
            }
        }
    }
}

var point = Piont()
print("\(point.x) \(point.y)")
point[0] = 10
point[1] = 12
print("\(point[0]) \(point[1])")
