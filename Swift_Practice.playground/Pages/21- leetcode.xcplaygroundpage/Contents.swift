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


//杨辉三角
class Solution {
    func generate(_ numRows: Int) -> [[Int]] {
        if numRows == 0 {
            return []
        }
            
        var result:[[Int]] = [[Int]]()
        result.append([1]) //add first 行

        for i in 1..<numRows{
            var currentRow = [1] // 每行起始为1
            let preRow = result[i - 1] //前一行

            for j in 1..<i{//上面生出下一行
                currentRow.append(preRow[j] + preRow[j-1])
            }
            currentRow.append(1)//以1结尾
            result.append(currentRow)
        }
        return result
    }
}

//14最长公共前串

func longestCommonPrefix(_ strs: [String]) -> String {
    if strs.count == 0{
        return ""
    }//特殊情况

    if strs.count == 1{
        return strs[0]
    }

    let arrays = strs.map{Array($0)}//问题转化为数组，处理Array
    let firstArray = arrays[0]
    var resultArr = [Character]()
    for i in 0 ..< firstArray.count
    {
        for j in 1 ..< arrays.count
        {
            if arrays[j].count < i || arrays[j][i] !=  firstArray[i]{//跳出
                return String(resultArr)
            }
        }
        resultArr.append(firstArray[i])//套在里面了  ————
    }
    return String(resultArr)
}


//7 字符串翻转

func reverse(_ x: Int) -> Int {
    //符号处理
    var sign = x > 0 ? 1 : -1
    
    var num = abs(x)//正整数
    
    var reversed:Int = 0

    while num > 0 {
        //翻转处理
        let digit = num % 10
        num = num / 10
        reversed = reversed * 10 + digit
        //越界处理
        if reversed > Int32.max {
            return 0
        }
    }

    return reversed * sign
}

//14 赎金信问题
//1. 处理越界
//2. repeating:, count:
//unicodeScalar

func canConstruct(_ ransomNote: String, _ magazine: String) -> Bool {
    //越界监测
    if ransomNote.count > magazine.count{
        return false
    }
    
    //统计赎金数组
    var checkArray = Array(repeating:0,count:26)
    let aUnicode = UnicodeScalar("a").value
    
    //统计赎金
    for scalar in magazine.unicodeScalars{
        let index = Int(scalar.value - aUnicode)
        checkArray[index] += 1
    }
    
    //对照赎金
    for scalar in  ransomNote.unicodeScalars{
        
        let index = Int(scalar.value - aUnicode)
        checkArray[index] -= 1
        
        if checkArray[index] < 0 {
            return false
        }
    }
    return true
}

