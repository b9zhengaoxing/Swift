//: [Previous](@previous)

import Foundation
// Two numbers 数组越界
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


//使用哈希表 - 字典类操作
func twoSum3(_ nums: [Int], _ target: Int) -> [Int] {
    var ret:[Int] = [Int]()
    if nums.isEmpty || nums.count < 2{//为空或者小于2 退出
        return ret
    }
    
    var dic:[Int:Int] = [Int:Int]()
    for i in 0..<nums.count{
        dic[i] = nums[i]
    }
    for (key,value) in dic{
        var tmp = target - nums[key]
        // var keys:[Int] = dic.filter{$0.value == tmp}.map{$0.key)
        var keys: [Int] = dic.filter { $0.value == tmp }.map { $0.key }
        if keys.count == 0{
            continue
        }else if keys[0] == key{
            if keys.count == 1{
                continue
            }else{
                ret.append(key)
                ret.append(keys[1])
                return ret
            }
        }else if keys[0] != key{
            ret.append(key)
            ret.append(keys[0])
            return ret
        }
    }
    return ret
}


