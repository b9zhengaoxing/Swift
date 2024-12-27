
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

let e = d ?? 10
print(e)
