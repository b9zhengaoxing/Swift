//: [Previous](@previous)

import Foundation

//转换专题

//String  —— Unicoder —— Key
print("a".unicodeScalars.first!)  //a
print("a".unicodeScalars.first!.value) //97
print("b".unicodeScalars.first!.value) //98

//总论： Set Dic Array 都是Struct 定义都是值类型 <Generic>
//需要保证类型 一致
//Set 初始化
var set1:Set = Set<Int>() //给出类型
var set11:Set = [1,1,2,3,4] //推断类型，且由数组转入

//增删
set11.contains(1)
set11.insert(11)
set11.remove(1)
print(set11)
Array(set11)

//数组初始化
var arr = [Int]() //给出类型，初始化，或者赋值
arr.count
//arr.remove(at: <#T##Int#>)
//arr.append(<#T##newElement: Int##Int#>)
//arr.insert(<#T##newElement: Int##Int#>, at: <#T##Int#>)
arr.contains(10)
Set(arr)

//字典
var dic = [Int:Int]()
//dic.contains(where: <#T##((key: Int, value: Int)) throws -> Bool#>)?
//dic.remove(at: <#T##Dictionary<Int, Int>.Index#>)
dic[10] = 100
dic.values
dic.keys

//在 Swift 中，可以通过不同的方法在 Set、Dictionary（哈希表）和 Array 之间进行相互转换。以下是一些常见的转换方法：
//1. 数组（Array）转 Set（Hash）
//
//Set 是无序且不包含重复元素的集合。
//
//let array = [1, 2, 3, 4, 4, 5]
//let set = Set(array) // {1, 2, 3, 4, 5}
//
//2. Set（Hash）转 数组（Array）
//
//可以使用 Array() 初始化，也可以排序后转换。
//
//let set: Set = [3, 1, 4, 2]
//let array = Array(set) // [3, 1, 4, 2] （无序）
//let sortedArray = Array(set).sorted() // [1, 2, 3, 4]
//
//3. 数组（Array）转 Dictionary（HashMap）
//
//可以通过 Dictionary(uniqueKeysWithValues:) 将数组转换为字典，例如创建索引映射：
//
//let array = ["apple", "banana", "cherry"]
//let dictionary = Dictionary(uniqueKeysWithValues: array.enumerated().map { ($0, $1) })
//
//// 结果: [0: "apple", 1: "banana", 2: "cherry"]
//
//如果键可能重复，则可以使用 Dictionary(grouping:by:) 进行分组：
//
//let words = ["apple", "banana", "apricot", "blueberry"]
//let groupedDictionary = Dictionary(grouping: words, by: { $0.first! })
//
//// 结果: ["a": ["apple", "apricot"], "b": ["banana", "blueberry"]]
//
//4. Dictionary（HashMap）转 数组（Array）
//
//可以将 Dictionary 的 keys 或 values 转换为数组：
//
//let dictionary = ["a": 1, "b": 2, "c": 3]
//let keysArray = Array(dictionary.keys)   // ["a", "b", "c"] （无序）
//let valuesArray = Array(dictionary.values) // [1, 2, 3] （无序）
//
//如果需要排序：
//
//let sortedKeys = dictionary.keys.sorted()    // ["a", "b", "c"]
//let sortedValues = dictionary.values.sorted() // [1, 2, 3]
//
//5. Set（Hash）转 Dictionary（HashMap）
//
//可以给 Set 赋予键并转换为 Dictionary：
//
//let set: Set = ["apple", "banana", "cherry"]
//let dictionary = Dictionary(uniqueKeysWithValues: set.map { ($0, $0.count) })
//
//// 结果: ["apple": 5, "banana": 6, "cherry": 6]
//
//这些方法可以高效地进行集合类型之间的转换，在 Swift 的数据处理和算法优化中非常实用。

func getSum(_ n:Int) -> Int {
    var result = 0
    var num = n
    while num > 0 {
        result += (num % 10) * (num % 10)  //错误
        num = num / 10   //错误
    }
    print(result)
    return result
}

func isHappy(_ n: Int) -> Bool {
    var result = n
    var hashSet = Set<Int>() //Set 需要显示声明
    print(11)
    while result == 1{
        result = getSum(result)
        if(hashSet.contains(result)){
            return false
        }else{
            hashSet.insert(result)
        }
        print(hashSet)

    }
    return true
}
isHappy(2)
