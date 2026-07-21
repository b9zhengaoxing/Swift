//: [Previous](@previous)

import Foundation

struct AssertResponse:Codable {
    let data:[AssertModel]
}

struct AssertModel:Codable{
    let id:String
    let name:String
    let symbol:String
    let volumeUsd24Hr:String
    let vwap24Hr:String
}
//
//"id": "bitcoin",
//"rank": "1",
//"symbol": "BTC",
//"name": "Bitcoin",
//"supply": "20025221.000000000000000000",
//"maxSupply": "21000000.000000000000000000",
//"marketCapUsd": "1628212070833.470214843750000000",
//"volumeUsd24Hr": "33686113863.892955780029296875",
//"priceUsd": "81308.070000000006984919",
//"changePercent24Hr": "1.2833746513124193",
//"vwap24Hr": "81090.00069182446",
//"explorer": "https://blockchain.info/",
//"tokens": {}


let urlStr = "https://rest.coincap.io/v3/assets"

func fetchDataGCD(){
    guard let url = URL(string: urlStr) else { return }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer dab8eaa473dda1974abc998916f00e5a41387558762a0034dc82a12d4de369e7", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        //handle error
        if let error = error {
            print("error:\(error)")
            return
        }
        
        //处理错误码
        guard let http = response as? HTTPURLResponse , http.statusCode == 200 else{
            print("bad reponse")
            return
        }
        
        //处理数据
        guard let data = data else {
            return
        }
        
        do{
            let result = try JSONDecoder().decode(AssertResponse.self, from: data)
            DispatchQueue.main.async {
                print(result)
            }
        }catch{
            print("decode error")
        }
    }.resume()
}

//fetchDataGCD()

//: [Next](@next)

func fetchDataConcurrency() async throws ->[AssertModel]{
    let url = URL(string:urlStr)!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer dab8eaa473dda1974abc998916f00e5a41387558762a0034dc82a12d4de369e7", forHTTPHeaderField: "Authorization")
    
    let (data,response) = try await URLSession.shared.data(for: request)
    
    guard let http = response as? HTTPURLResponse , http.statusCode == 200 else{
//        print("fetchDataConcurrency bad access")
        
        throw URLError(.badServerResponse)
//        return
    }
    
    let result = try JSONDecoder().decode(AssertResponse.self, from: data)
    return result.data
}

Task{
    do{
        let data = try await fetchDataConcurrency()
        print(data)
    }catch{
        print(error)
    }
}
