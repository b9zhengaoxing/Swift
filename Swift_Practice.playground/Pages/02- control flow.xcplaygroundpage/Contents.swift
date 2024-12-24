
//流程控制  if 后面只跟bool数值
//Cannot find 'age' in scope
//int age = 25
var age = 25
if age > 25 {}

//Swift 取消了 ++ --
while age>25 {
    //    Expected expression after operator
    //    age --
    age -= 1
}

var num = -2
repeat{
    print("num is \(num)")
    num += 1
}while num<0

let names = ["lucy","John","william","max"]

//i 模式是let
for i in 0...2{
    //    i += 1  'i' is a 'let' constant
    print(names[i])
}

//可以声明 是var
for var i in 0..<2{
    i += 1
    print("第 \(i) 是 \(names[i])")
}

//循环三次
var rage = 0...2
for _ in rage{
    print(72)
}

//区间运算法用在数组上
for name in names{
    print(name)
}

for name in names[...2] {
    print("range in array \(name)")
}

//区间类型
let range1:ClosedRange<Int> = 1...3
let range2:Range<Int> = 1..<3
let range3:PartialRangeThrough<Int> = ...5

//带间隔的区间值
let hours = 11
let hourInterval = 2
for tickMark in stride(from:4,through:hours,by:hourInterval){
    print(tickMark)
}

//Switch 覆盖所有情况  区间，Where，binding

//switch names{
//case names[0]: Expression pattern of type 'String' cannot match values of type '[String]'
//case "williom": Expression pattern of type 'String' cannot match values of type '[String]'

switch hours{
case hours:
    fallthrough //只穿一个
    print(1) //不会执行
case 2:
    print(2)
default:
    print("others")
    //    Switch must be exhaustive  需要加 default 非必要不加 break
}

enum Answer{
    case right,wrong }
let answer = Answer.right
switch answer{
case .right:// Swifch 接受类型匹配，才能省略
    break
case .wrong:
    break
}

//多重条件
switch names[1]{
case "lucy","max":
    print("find it")
default:
    print(names[2])
}

//range
switch 100000{
case 0...:
    print("正整数")
case ..<0:
    print("负数")
default:
    print("还有未知数了")
}

//tuple
let point = (0,20)
switch point{
case (0,0):
    print("原点")
case (_,0):
    print("x轴")
case (0,_):
    print("y轴")
default:
    print("没在轴上")
}

//binding
switch point{
case (0,var x):
    print("binding \(x)")
default:
    break;
}

//where
switch point{
case let(x,y) where y - x == 20:
    print("switch:where: x:\(x) y:\(y) ")
default:
    break
}

//Label Statement 本质在于跳出循环 jump out loop
outLooper:for i in 0...100{
    if i == 0 {
        print("LabelStatement \(i)")
        break outLooper
    }
}








