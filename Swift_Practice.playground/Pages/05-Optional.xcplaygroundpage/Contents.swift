
import Foundation

//optional value
var name:String? = "Jack"
//var str = name!
print(name!)
print(name)
name = nil

//default nil
var age:Int?
// forced Unwrapping error: Execution was interrupted, reason: EXC_BREAKPOINT (code=1, subcode=0x194c6c7a8).
//age!
age = 10
print(age)
print(age!)

var array = [1,15,40,20]
func get(_ index:Int) -> Int? {
    if index<0 || index > array.count{
        return nil
    }
    return array[index]
}

print(get(1))
var number = get(10)
if number != nil{
    print("解包出来\(number!)")
}else{
    print("这是nil");
}


//if let value = number!{Initializer for conditional binding must have Optional type, not 'Int'
//Optional Binding 包含，自动解包，Optional nil 跳过条件
if var value = number{
    print(value)
}else{
    print("binding 失败")
}

enum Season:Int{
    case spring,summer,autumn,winter
}

//rawValue 返回了？
if var value = Season(rawValue:1){
    print(value)
}else{
    print("binding nil")
}

if let value = Int("10"){//return ？
    print(value)
}else{
    print("binding nil")
}


var a:Int? = 1
print(a)
var b:Int? = 2
//Cannot use optional chaining on non-optional value of type 'Int'
//let c = a??b
let c = a ?? b //至少要有两个空格
print(c)

a = nil
let d = a ?? c
print(d)

let e = d ?? 10 //非可选项，自动解包
print(e)

let f = a ?? b ?? 10
print(f)

if let value = a ?? b{ // !nil || !nil
    print(value)
}else{
    print("nil")
}

a = Int(12)
print(a)
if let value = a,let value2 = b{
    print("\(value) + \(value2)")
}

func login(_ info:[String:String]) -> String{
    let userName:String

    let a1 = info["userName"] //字典 按键值 读取 返回Optional
    print(a1)
    guard a1 != nil else{
        return ""
    }
    
    if let value = info["userName"]{
        userName = value
    }else{
        userName = "default"
    }
    return userName
}

let infoDic = ["userName":"刘宝宝","password":"123456"]
print(login(infoDic))

//implicitly unwrapped Optional 隐解
let implictInt:Int! = 10
let 哈哈哈 = implictInt
print(implictInt)

//消除编译器警告
print(implictInt!)
print(String(describing: implictInt))
print(implictInt ?? 0)

//let implictInt1:Int! = nil
//let 哈哈哈1:Int = implictInt  Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value

//关于 Optional Binding 并不返回 Boolen 但是成功失败决定了进入哪个分支
//guard 条件 else {continue break return }


//多重可选项
var num1:Int? = 10 //Int? 10
var num2:Int?? = num1 //Int?? Int? 10
var num3:Int?? = 10 //Int?? Int? 10
print("多重可选项目\(num2 == num3)")


var num11:Int? = nil  //Int? nil
var num12:Int?? = num11  //Int?? Int? nil
var num13:Int?? = nil  //Int?? nil
print("多重可选项nil \(num11 == num13)")


struct User {
    var profile:profile?
    func doSomething() {
        print("hello optional Chain")
    }
}

struct profile {
    var name:String?
}

let user:User? = User(profile: profile(name: "孙悟空"))
let name1 = user?.profile?.name

if let use = user ,let profile = use.profile,let name2 = profile.name{
    print(name2)
}else{
    print("解包失败")
}

if let _ = user?.doSomething(){
    print("执行成功")
}else {
    print("也执行成功了")
}
