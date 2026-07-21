//: [Previous](@previous)

import Foundation

func findAllPaths(_ n: Int, _ edges: [(Int, Int)]) {
    var graph = [Int: [Int]]()
    
    // 构建邻接表
    for (s, t) in edges {
        graph[s, default: []].append(t)
    }
    
    var result = [[Int]]()
    var path = [Int]()
    
    func dfs(_ node: Int) {
        path.append(node)
        
        if node == n {
            result.append(path)
        } else if let neighbors = graph[node] {
            for next in neighbors {
                dfs(next)
            }
        }
        
        path.removeLast()
    }
    
    dfs(1)
    
    if result.isEmpty {
        print(-1)
    } else {
        for p in result {
            print(p.map { String($0) }.joined(separator: " ") + " ")
        }
    }
}

// 读取输入数据
if let firstLine = readLine()?.split(separator: " ").compactMap({ Int($0) }),
   firstLine.count == 2 {
    let (n, m) = (firstLine[0], firstLine[1])
    var edges = [(Int, Int)]()
    
    for _ in 0..<m {
        if let line = readLine()?.split(separator: " ").compactMap({ Int($0) }),
           line.count == 2 {
            edges.append((line[0], line[1]))
        }
    }
    
    findAllPaths(n, edges)
}

