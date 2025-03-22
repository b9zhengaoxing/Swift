//: [Previous](@previous)

import Foundation

//背包问题 二维

var firstLine = [6,8]
var spaces = [2,2,3,1,5,2]
var values = [2,3,1,5,4,3]



func oneOpackage(_ firstLine:[Int],_ spaces:[Int], _ values:[Int]){
    let m = firstLine[0]
    let n = firstLine[1]

    // 初始化二维数组，dp[i][j]表示前i个物品在容量j时的最大价值
    var dp = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
    
    for j in spaces[0] ... n {
        dp[0][j] = values[0]
    }
    
    for i in 0 ..< m {
        let space = spaces[i]
        let value = values[i]
        for j in 0...n {
            if j < space {
                // 容量不足，无法选择当前物品
                dp[i+1][j] = dp[i][j]
            } else {
                // 可以选择或不选择当前物品，取较大值
                //
                dp[i+1][j] = max(dp[i][j]/*不放物品i */, dp[i][j - space] + value /*放物品 i */)
            }
        }
    }
    print(dp[m][n])
}


func oneOpackage1(_ firstLine:[Int],_ spaces:[Int], _ values:[Int]){

    let m = firstLine[0]
    let n = firstLine[1]
    var dp = [Int](repeating: 0, count: n + 1)//初始化为1
    for i in 0 ..< m {//先递归价值
        let space = spaces[i]
        let value = values[i]
        for j in (space...n).reversed() {//再递归空间
            if j >= space {
                dp[j] = max(dp[j], dp[j - space] + value)
            }
        }
    }

    print(dp[n])
}




oneOpackage(firstLine, spaces, values)
oneOpackage1(firstLine, spaces, values)



//背包问题 一维数组

