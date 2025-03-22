//: [Previous](@previous)

import Foundation

func eraseOverlapIntervals(_ intervals: [[Int]]) -> Int {
    //count 1
    if intervals.count == 1 {
        return 0
    }

    //贪心算法 找最大公共区间数
    var sortedIntervals = intervals.sorted{$0[0] < $1[0] || ($0[0] == $1[0] && $0[1] < $1[1])}
    var res = 0

    //大于1
    for i in 1 ..< sortedIntervals.count{
        if sortedIntervals[i - 1][1] > sortedIntervals[i][0]{
            res += 1
            sortedIntervals[i][1] = min(sortedIntervals[i - 1][1],sortedIntervals[i][1])
        }
    }
    return res
}

var test = [[1,2],[2,3],[3,4],[1,3]]
print(eraseOverlapIntervals(test))

