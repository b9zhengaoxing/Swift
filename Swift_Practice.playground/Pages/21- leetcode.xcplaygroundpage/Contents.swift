//: [Previous](@previous)

import Foundation
//题目，把每个数字换成 num

//a1b2c3


func exchangeNum(_ string:String) -> String {
    
    var arr = Array(string)
    var result = ""
    for i in 0 ..< arr.count{
        if arr[i].isNumber {
            result.append("Number")
        }else{
            result.append(arr[i])
        }
    }
            
    return  result
}

print(exchangeNum("12a34"))
