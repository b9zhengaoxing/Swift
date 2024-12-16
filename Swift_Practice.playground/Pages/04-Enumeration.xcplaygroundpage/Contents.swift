//: [Previous](@previous)

import Foundation

enum Direction {
    case north
    case west
}

var dirct = Direction.north
print (dirct)


//Associate values
enum Game {
    case team(String)
    case score(Int)
}

var a = Game.team("马刺")

switch a{
case .team("马刺"):
    print("champin")
default:
    break
}


