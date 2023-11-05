//: [Previous](@previous)

import Foundation

//: 1. 函数定义  func 封装，输入，输出  形参默认是let
func work1(x:Int,y:Int)->Int{
    return x + y
}
print(work1(x:1,y:2))

//: 2. 返回 无返回 隐式返回 元组返回
//func work() {
//func work() -> Void{
func work2() -> (){
    print("hello world")
}

func work3(x:Int,y:Int)->Int{
    return x + y
}

func work4(x:Int,y:Int,z:Int) -> (x:Int,y:Int,z:Int){
    (x,y,z)
}

let coordnate = work4(x: 10, y: -1, z: 13)
coordnate.x
coordnate.y
coordnate.z


//: 3. 参数 ：参数变迁  默认  可变参数 输入输出参数
    // 3.1 每个参数默认  argument label）以及一个参数名称（parameter name）通常情况下默认两个相等，如果指定 argument label 可以增加可读性，使用_ 可以ignore
func parameter1(at time:String,_ doA:String){
    print("\(time) + \(doA)")
}

parameter1(at: "10:30 PM", "weak up")

    // 3.2 默认参数
func parameter2(at time:String = "7:00 AM",doA:String = "Game"){
    print("\(time) + \(doA)")
}

parameter2()
parameter2(doA: "work")

    // 3.3 可变参数，每个函数只有一个，可变参数后面标签不能省略
func parameter3(numbers:Int...,what:String = "people") -> (num:Int,what:String){
    var ret:Int = 0;
    for num in numbers{
        ret += num;
    }
    return (ret,what);
}

var para3 = parameter3(numbers:1,2,3,4,5,what:"dog")
para3.num;
para3.what;

    //print 可变参数
print(1,2,3,4,5, separator: "-")

var value_34:Int = 10;
    // 3.4 输入输出参数
func parameter34(numberA:inout Int, numberB:inout Int ){
    var tmp:Int = 0;
    tmp = numberA;
    numberA = numberB
    numberB = tmp;
}

var tmpA:Int = 10
var tmpB:Int = 20
parameter34(numberA: &tmpA, numberB: &tmpB)
print("\(tmpA) + \(tmpB)")

//: 每天至少写一行代码，写一行日记
//: 旧伤结束，每次新伤
//: 早睡开心
//: 每天投简历，每天开心
//: 意见不同了，可以察言观色
//: 找到适合专注的地方
//：打开门 走出去
//: 去图书馆，写代码
//: 函数重载，参数问题
//: 整理思维，整体过一遍
//: 100% 提高效率
//: 处理，和进行，不是一回事情
//: 高效休息，提高效率
//：今日早睡
//: open thedoor
//: 每天一顿约会
//: 分析社交类型
//: 避免浪费多余精力
//: 加油💪🏻
//: 岁月不待人，睡前回顾，晚间计划，不用追赶
//: 间隔重复，努力向前
//: 做好预习
//: 注重过程，用好B站，不依赖录音笔
//: 不要同时又考虑未来，又考虑现在，just Do it
//: 4. 函数重载 parameter 数量，命名，是
//: 人生很多好事会发生
//: 知行合一，不要为了减肥而运动，运动远大于减肥

func overload1(v1:Int,v2:Int)-> Int{
    v1 + v2
}

// num dif
func overload1(v1:Int,v2:Int,v3:Int)->Int{
    v1 + v2 + v3
}

// 标签 dif
func overload1(a1:Int,v2:Int)->Int{
    a1 + v2
}

func overload1(v1:Int,v2:Double)->Int {
    v1
}

//: 5. 内联函数
//: 是一种优化，可以设置

//: 6. 函数类型
//6.1 作为变量
func funType1(v1:Int)->Int{
    return 10 * v1;
}

func funType11(v1:Int)->Int{
    return 10 / v1;
}

var funType2:(Int)->Int = funType1

funType2(1);

//6.2 作为参数
func funType2(mathFn:(Int)->Int,v1:Int)->(Int){
    return mathFn(v1);
}

funType2(mathFn: funType1, v1: 10);

func foreFun(a:Int)->Int{a*a}
func backFun(a:Int)->Int{2*a}
backFun
//6.3 作为返回值
func funType3(_ fore:Bool)->(Int)->Int{
    if(fore){
        return foreFun;
    }else{
        return backFun;
    }
}

var funType4:(Int)->Int = funType3(true)
funType4(15)

//: 7. 函数嵌套
//: 8.

// 洗澡，很开心，早起 更开心
// 享受当下每一天
// 很多时候是缺少勇气面对，面对就好了，不怕难就怕占着
// 睡眠不足这个事情: 睡眠不足，影响精神
// 固定时间投简历，哪怕只是打开，有个心理暗示也是好的，计划也是努力的一部分
// 打破思维里面的墙，不要让任何事情拖后腿，一直做，去做，加油，不要有内耗消耗精力
// 享受现在！！相信上帝，相信自己！
// 你的人生就是每个当下，你的人生和昨天没有关系，和明天也没有关系
// 去远行，加油
// 早点睡觉！
// 戴上眼罩，早点睡觉
// 主动睡觉
// 今天在看小说
// 作对的事情，状态好
// 体验Helloween 要糖果
// 运动前吃糖，效果好
// 少盛点，少吃点

//: [Next](@next)
