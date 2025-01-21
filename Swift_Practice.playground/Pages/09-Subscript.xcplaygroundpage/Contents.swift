//: [Previous](@previous)

import Foundation

//Subscripts Access the elements of a collection  p[] subcript
//本质是方法

class Piont{
    var x = 0.0 , y = 0.0
    subscript (index:Int) -> Double{
        set{
            print("hello \(newValue)")
            if index == 0{
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


//Subscript 必须有set ,只有set omit set
//多个参数，任意类型，可以设置 参数标签，可以是类方法

class Sum{
    static subscript(V1 i:Int,V2 b:Int) -> Int{
        i + b
    }
}

print(Sum[V1:1,V2:2])


class Grid{
    var data = [[0,1,2],[3,4,5],[6,7,8]]
    subscript(row:Int,column:Int)->Int{
        set{
            if row < 0 && row >= 3 && column < 0 && column >= 3{
                return
            }
            else{
                data[row]column] = newValue
            }
                
        }get{
            if row < 0 && row >= 3 && column < 0 && column >= 3{
                return 0
            }else{
                return data[row,column]
            }
        }
    }
}

var grid = Grid()
grid[0,0] = 10
print(grid[0,0])
