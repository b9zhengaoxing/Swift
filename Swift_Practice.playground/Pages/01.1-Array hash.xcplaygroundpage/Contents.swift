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

//Array 初始化
var arr = [Int]() //给出类型，初始化，或者赋值
arr = [1,2,3,4,5,6,7,8,9]
arr += [10,11]
arr.count
//arr.remove(at: <#T##Int#>)
//arr.append(<#T##newElement: Int##Int#>)
//arr.insert(<#T##newElement: Int##Int#>, at: T##Int)
arr.contains(10)

//index
print(arr.firstIndex(of:5) ?? 0)

//enumerated
for (index,key) in arr.enumerated(){
    print("index: \(index) value:\(key)")
}
//SubArray
//1. slice 切片  使用原来索引  1.1 使用 Array（）转化为新的
let arraySlice = arr[1...3]
let arraySliceNew = Array(arr[1...3])
//2. prefix()获取前n 个SubArray
let arrayPrefix = Array(arr.prefix(3))
//3. dropFirst() dropLast()
let arrayDrop = Array(arr.dropFirst(3))

Set(arr)

//字典
var dic = [Int:Int]()
//dic.contains(where: <#T##((key: Int, value: Int)) throws -> Bool#>)?
//dic.remove(at: <#T##Dictionary<Int, Int>.Index#>)
dic[10] = 100
dic.values
dic.keys

//1. 没有optional
dic[11,default:0] += 1
print(dic[11])

//dic[i] 是 Optional<Int> 不能直接 += 所以可以使用 dic[11,default:0]

//2.排序
let sortedDic = dic.sorted { $0.value > $value }//按照Value 排序



