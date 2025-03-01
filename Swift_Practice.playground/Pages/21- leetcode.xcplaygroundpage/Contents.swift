//: [Previous](@previous)

import Foundation
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

//hash 解法
func twoSum4(_ nums: [Int], _ target: Int) -> [Int] {
    
    //使用字典 哈希表
    var dict:[Int:Int] = [Int:Int]()

    //循环数组，一遍循环一边比较
    for (index,value) in nums.enumerated(){
        var num = target - value
        
        //检查配对，如果存在，存下来
        if let j = dict[num] {
            return [index,j].sorted()
        }
        dict[value] = index
    }
    return []
}

