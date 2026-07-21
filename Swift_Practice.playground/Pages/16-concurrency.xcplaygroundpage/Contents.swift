//: [Previous](@previous)

import Foundation
import UIKit
import SwiftUI

//DispatchQueue.main.sync{ //deadlock
//    print("dead lock")
//}

//[main thread ]
// sync
// wait block
// wait main

//DispatchQueue.main.async {//update in MainUI async
//    print("not dead lock")
//}
//
//DispatchQueue.global().async{
//    print("Run heavy work in background thread") //background thread
//    DispatchQueue.main.async { //mainThread UI
//        print("update UI")
//    }
//}

@MainActor
func updateUI(data:String){
    print("update UI")
    print(data)
}

func fetchData() async -> String{
    try? await Task.sleep(nanoseconds: 1_000_000_0000)
    return "fetch Data"
}

Task{
    let data = await fetchData()
    await updateUI(data: data)
}

Task{
    async let a = fetchData()
    async let b = fetchData()
    //上面是异步
    
    let (data1,data2) = await(a,b) //下面不阻塞
    await updateUI(data: data1 + data2)
    
}

//Tast 约等于  CGD async 范围
// async 异步函数
// await 执行 等待不阻塞
// mainActor main


//Task group

func fetchOne(index:Int) async -> String{
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    return "data\(index)"
}

func fetchAll() async -> [String]{//Not in order
    await withTaskGroup(of: String.self) { group in
        for i in 0..<5{
            group .addTask {
                await fetchOne(index: i)
            }
        }
        
        var result:[String] = []
        for await value in group{
            result.append(value)
        }
        return result
    }
}

Task{
    var result = await fetchAll()
}



//带Throw的
func fetchData2(index:Int) async throws -> String{
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return "fetchData\(index)"
}

func fetchDataAll2() async throws -> [String]{
    try await withThrowingTaskGroup(of: String.self) { group in
        for i in 0..<5 {
            group.addTask {
                try await fetchData2(index: i)
            }
        }
        
        var result:[String] = []
        for try await value in group{
            result.append(value)
        }
        return result
    }
}

Task{
    do{
        let result = try await fetchDataAll2()
        print(result)
    }catch{
        print("error\(error)")
    }
}


func fetchData3(index:Int) async throws -> String{
    try await Task.sleep(nanoseconds: 1_000_000_000)
    return ("fetchData3:\(index)")
}

func fetchDataAll3() async throws -> [String]{
    try await withThrowingTaskGroup(of: (Int,String).self) { group in
        
        for i in 0..<5 {
            group.addTask {
                var value = try await fetchData3(index:i)
                return(i,value)
            }
        }
        var result:[String] = Array(repeating: "", count: 5)
        for try await (index,value) in group{
            result[index] = value
        }
        return result
        
    }
}

//Task{
//    do{
//        let result = try await fetchDataAll3()
//        print(result)
//    }catch{
//        print(error)
//    }
//}

//counter
actor Counter{
    private var value = 0
    
    func add(){
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}

var counter = Counter()

Task{
    await counter.add()
}

Task{
    await counter.add()
}

Task{
    var value = await counter.getValue()
    print("counter:",value)
}

//imageCache
actor ImageCache{
    var cache:[String:UIImage] = [:]
    
    func save(key:String,image:UIImage) {
        cache[key] = image
    }
    
    func get(key:String) -> UIImage? { //为什么问号？ —— 可能不存在，所以解包
        return cache[key]
    }
}

var imgCache = ImageCache()

func download(url:String)async -> UIImage?{
    return nil
}

func loadImage(url:String) async -> UIImage?{
    if let image = await imgCache.get(key:url) {
        return image
    }
    
    let img = await download(url:url)
    
    if let img = img{
        await imgCache.save(key: url, image: img)
    }
    
    return img
}

//Token
actor AuthManager{
    private var token = ""
    private var isrefreshing = false
    
    func getAuth()  async -> String {
        if token.isEmpty{
            await updateToken()
        }
        return token
    }
    
    func updateToken() async  {
        if isrefreshing == true{
            return
        }
        
        defer {
            isrefreshing = false
        }
        
        isrefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        token = "new token"
    }
}

let auth = AuthManager()

Task{
    let token = await auth.getAuth()
    print(token)
}

Task{
    let token = await auth.getAuth()
    print(token)
}

Task{
    let token = await auth.getAuth()
    print(token)
}






