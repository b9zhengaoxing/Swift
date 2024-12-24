
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


