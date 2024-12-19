//: [Previous](@previous)

import Foundation

//什么是枚举，规定类型，
enum Direction {
    case north
    case west
}

var dirct = Direction.north
dirct = .west
print (dirct)

//Associate values
enum Game {
    case team(String)
    case date(Year:Int,Month:Int,Day:Int)
    case score(Int)
}

var a = Game.team("马刺")
var b = Game.date(Year: 2024, Month: 1, Day: 28)
print(b)

switch a{
case .team("马刺"):
    print("champin")
default:
    break
}

//多个let 灵活位置 提取关联值绑定到局部变量
switch b{
case .date(let year,let month,let day):
    print("\(year) \(month) \(day)")
default :
    break
}


enum Response {
    case success(Message:String)
    case error(code:Int,description:String)
}

var result1 = Response.success(Message: "hello world")
var result2 = Response.error(code: 404, description: "未找到网页")

//
switch result1{
case let .success(message):
    print(message)
//case let .error(let code, let description):
//    print("\(code) : \(description)")
default:
    break
}


enum Password {
    case number(Int,Int,Int,Int)
    case gesture(String)
}

var passNum = Password.number(10, 9, 8, 7)

switch passNum{
case let .number(a,b,c,d):
    print("a \(a),b \(b),c \(c),d \(d)")
default:
    break
}


//rawValue
enum PokeSuit:String{
    case spade = "♠"
    case heart = "红心"
}
let poke1 = PokeSuit.spade
print(poke1)
print(poke1.rawValue)

enum Season:Int{
    case spring,summer,autumn,winter
}
print(Season.spring)
print(Season.spring.rawValue)
