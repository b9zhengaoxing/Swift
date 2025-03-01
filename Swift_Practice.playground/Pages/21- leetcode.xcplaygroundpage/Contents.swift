//: [Previous](@previous)

import Foundation
// Two numbers
func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var ret:[Int] = [Int]()
    if nums.isEmpty{
        return ret
    }
    
    for i in 0...nums.count{
        for j in 0...nums.count{
            if i == j{
                print("i \(i) j \(j)")
                continue
            }
            if target == nums[i] + nums[j]{
                print("i \(i) j \(j)")
                ret.append(i)
                ret.append(j)
                return ret
            }
        }
    }
    return ret
}


//暴力解法
//1. 暴力突破
//2. 先排除越界情况
//3. count 和 range 越界问题
func twoSum1(_ nums: [Int], _ target: Int) -> [Int] {
    var ret:[Int] = [Int]()
    if nums.isEmpty || nums.count < 2{//为空或者小于2 退出
        return ret
    }
    
    for i in 0..<nums.count{
        for j in i+1..<nums.count{
            if target == nums[i] + nums[j]{
                print("i \(i) j \(j)")
                ret.append(i)
                ret.append(j)
                return ret
            }
        }
    }
    return ret
}

