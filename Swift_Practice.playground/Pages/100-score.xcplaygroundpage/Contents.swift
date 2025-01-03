//: [Previous](@previous)

import Foundation

func newPePbScore(industry:String) -> (peScore: Double, pbScore:Double) {
    switch industry {
    case "煤炭":
        return  (5,   0.5)
    case "电力":
        return  (8,   0.8)
    case "石油":
        return  (6,   0.6)
    case "钢铁-普银":
        return   (4,   0.4)
    case "钢铁":
        return   (5,   0.5)
    case "钢铁-钢力":
        return   (7,   0.6)
    case "有色":
        return  (8,   0.8)
    case "化纤":
        return  (8,   0.8)
    case "化工":
        return  (7,   0.7)
    case "建材":
        return  (5,   0.5)
    case "造纸":
        return  (8,   0.6)
    case "矿物制品":
        return    (10,  1)
    case "日用化工":
        return    (10,  1)
    case "农林牧渔":
        return    (10,  1)
    case "纺织服饰":
        return    (8,   0.8)
    case "服饰":
        return  (6,   0.7)
    case "食品饮料":
        return    (10,  1)
    case "酿酒":
        return  (10,  1)
    case "家用电器":
        return    (6,   0.6)
    case "汽车类":
        return (8,   0.8)
    case "医疗保健":
        return    (10,  1)
    case "家居用品":
        return    (8,   0.9)
    case "医药":
        return  (10,  1)
    case "商业连锁":
        return    (8,   0.8)
    case "商贸代理":
        return    (7,   0.7)
    case "传媒娱乐":
        return    (7,   0.7)
    case "广告包装":
        return    (10,  1)
    case "文教休闲":
        return    (10,  1)
    case "酒店餐饮":
        return    (10,  1)
    case "旅游":
        return  (10,  1)
    case "航空":
        return  (10,  1)
    case "船舶":
        return  (10,  1)
    case "运输设备":
        return    (9,   0.7)
    case "通用机械":
        return    (10,  1)
    case "工业机械":
        return    (9,   0.8)
    case "电气设备":
        return    (10,  1)
    case "工程机械":
        return    (8,   0.8)
    case "电器仪表":
        return    (8,   0.8)
    case "电信运营":
        return    (10,  1)
    case "公共交通":
        return    (8,   0.8)
    case "水务":
        return  (8,   0.7)
    case "供气供热":
        return    (10,  1)
    case "环境保护":
        return    (10,  0.8)
    case "运输服务":
        return    (7,   0.7)
    case "仓储物流":
        return    (6,   0.5)
    case "交通设施":
        return    (6,   0.6)
    case "银行":
        return  (4,   0.4)
    case "证券":
        return  (10,  0.9)
    case "保险":
        return  (8,   0.8)
    case "多元金融":
        return    (5,   0.5)
    case "建筑":
        return  (4,   0.4)
    case "房地产":
        return (5,   0.5)
    case "IT设备":
        return    (10,  1)
    case "通信设备":
        return    (10,  1)
    case "半导体":
        return (10,  1)
    case "元器件":
        return (10,  1)
    case "软件服务":
        return    (10,  1)
    case "互联网":
        return (10,  1)
    case "综合类":
        return (10,  1)
    default:
        return (10, 1)
    }
}

//func caculateNewScore(value:[]) -> void{
func caculateNewScore(_ excel:[[String:String]]){
    print("名称,PETTM,PB,百分位,代码,行业,PE分数,PB分数,百分位分数,总分,当前标尺")
    for dic in excel {
        
        if let name = dic["名称"],let pe = dic["PETTM"],let pb = dic["PB"],let score = dic["(([1]-[2])/[2])"],let code = dic["代码"],let ind = dic["行业"] {
            let newScore = newPePbScore(industry: ind)
            
            //PE
            let peScore:Double
            let pe_unwrap = Double(pe) ?? 10
            if pe_unwrap < newScore.peScore{
                peScore = 100
            }else{
                peScore = (1 - (pe_unwrap - newScore.peScore)/newScore.peScore)*100
            }
            
            //PB
            let pbScore:Double
            let pb_unwrap = Double(pb) ?? 1
            if pb_unwrap < newScore.pbScore{
                pbScore = 100
            }else{
                pbScore = (1 - (pb_unwrap - newScore.pbScore)/newScore.pbScore)*100
            }
            
            //%
            let scoreScore:Double
            let score_unwrap = Double(score) ?? 0
            scoreScore = 100 * (1-score_unwrap)
            
            print("\(name),\(pe),\(pb),\(score),\(code),\(ind),\(peScore),\(pbScore),\(scoreScore),\(peScore+pbScore+scoreScore),\(newScore.peScore) \(newScore.pbScore)")
        }else{
            print("解析失败 \(dic)")
        }
    }
}

let data: [[String: String]] = [
    ["名称": "洲际油气", "PETTM": "6.953", "PB": "1.152", "(([1]-[2])/[2])": "0.162436548", "代码": "600759", "行业": "石油"],
    ["名称": "华菱钢铁", "PETTM": "10.547", "PB": "0.542", "(([1]-[2])/[2])": "0.262048193", "代码": "932", "行业": "钢铁"],
    ["名称": "九安医疗", "PETTM": "11.632", "PB": "1.04", "(([1]-[2])/[2])": "0.266584005", "代码": "2432", "行业": "医疗保健"],
    ["名称": "航民股份", "PETTM": "10.01", "PB": "1.166", "(([1]-[2])/[2])": "0.256781193", "代码": "600987", "行业": "纺织服饰"],
    ["名称": "冀中能源", "PETTM": "9.921", "PB": "1.022", "(([1]-[2])/[2])": "0.294845361", "代码": "937", "行业": "煤炭"],
    ["名称": "同德化工", "PETTM": "5.992", "PB": "0.921", "(([1]-[2])/[2])": "0.235443038", "代码": "2360", "行业": "化工"],
    ["名称": "津滨发展", "PETTM": "9.51", "PB": "1.238", "(([1]-[2])/[2])": "0.284153005", "代码": "897", "行业": "房地产"],
    ["名称": "中文传媒", "PETTM": "12.097", "PB": "0.943", "(([1]-[2])/[2])": "0.072413793", "代码": "600373", "行业": "传媒娱乐"],
    ["名称": "天健集团", "PETTM": "9.289", "PB": "0.679", "(([1]-[2])/[2])": "0.271875", "代码": "90", "行业": "建筑"],
    ["名称": "华光环能", "PETTM": "12.056", "PB": "0.997", "(([1]-[2])/[2])": "0.183023873", "代码": "600475", "行业": "环境保护"],
    ["名称": "武进不锈", "PETTM": "12.741", "PB": "1.2", "(([1]-[2])/[2])": "0.209401709", "代码": "603878", "行业": "钢铁"],
    ["名称": "双箭股份", "PETTM": "12.355", "PB": "1.269", "(([1]-[2])/[2])": "0.255238095", "代码": "2381", "行业": "化工"],
    ["名称": "旗滨集团", "PETTM": "12.342", "PB": "1.125", "(([1]-[2])/[2])": "0.206521739", "代码": "601636", "行业": "建材"],
    ["名称": "河钢资源", "PETTM": "10.902", "PB": "0.935", "(([1]-[2])/[2])": "0.154492024", "代码": "923", "行业": "钢铁"],
    ["名称": "嘉化能源", "PETTM": "10.327", "PB": "1.099", "(([1]-[2])/[2])": "0.231974922", "代码": "600273", "行业": "化工"],
    ["名称": "常熟汽饰", "PETTM": "9.845", "PB": "1.026", "(([1]-[2])/[2])": "0.254867257", "代码": "603035", "行业": "汽车类"],
    ["名称": "江苏金租", "PETTM": "10.461", "PB": "1.272", "(([1]-[2])/[2])": "0.269135802", "代码": "600901", "行业": "多元金融"],
    ["名称": "郑煤机", "PETTM": "5.899", "PB": "1.036", "(([1]-[2])/[2])": "0.202448211", "代码": "601717", "行业": "工业机械"],
    ["名称": "鄂尔多斯", "PETTM": "12.753", "PB": "1.286", "(([1]-[2])/[2])": "0.204516939", "代码": "600295", "行业": "钢铁"],
    ["名称": "精工钢构", "PETTM": "12.246", "PB": "0.685", "(([1]-[2])/[2])": "0.296943231", "代码": "600496", "行业": "钢铁"],
    ["名称": "江河集团", "PETTM": "8.523", "PB": "0.847", "(([1]-[2])/[2])": "0.288834951", "代码": "601886", "行业": "建筑"],
    ["名称": "中孚实业", "PETTM": "10.2", "PB": "0.767", "(([1]-[2])/[2])": "0.241071429", "代码": "600595", "行业": "有色"],
    ["名称": "新疆众和", "PETTM": "7.485", "PB": "0.909", "(([1]-[2])/[2])": "0.173400673", "代码": "600888", "行业": "有色"],
    ["名称": "中国外运", "PETTM": "9.836", "PB": "0.995", "(([1]-[2])/[2])": "0.25748503", "代码": "601598", "行业": "仓储物流"],
    ["名称": "常宝股份", "PETTM": "8.167", "PB": "0.863", "(([1]-[2])/[2])": "0.253623188", "代码": "2478", "行业": "钢铁"],
    ["名称": "江西铜业", "PETTM": "10.706", "PB": "0.923", "(([1]-[2])/[2])": "0.272955975", "代码": "600362", "行业": "有色"],
    ["名称": "华新水泥", "PETTM": "12.169", "PB": "0.853", "(([1]-[2])/[2])": "0.196770938", "代码": "600801", "行业": "建材"],
    ["名称": "海油工程", "PETTM": "11.894", "PB": "0.915", "(([1]-[2])/[2])": "0.128421053", "代码": "600583", "行业": "石油"],
    ["名称": "中煤能源", "PETTM": "9.059", "PB": "1.058", "(([1]-[2])/[2])": "0.251311097", "代码": "601898", "行业": "煤炭"],
    ["名称": "浙商银行", "PETTM": "5.15", "PB": "0.46", "(([1]-[2])/[2])": "0.199494949", "代码": "601916", "行业": "银行"],
    ["名称": "华阳股份", "PETTM": "9.182", "PB": "0.909", "(([1]-[2])/[2])": "0.084375", "代码": "600348", "行业": "煤炭"],
    ["名称": "晋控煤业", "PETTM": "6.812", "PB": "1.239", "(([1]-[2])/[2])": "0.294003868", "代码": "601001", "行业": "煤炭"],
    ["名称": "中交设计", "PETTM": "11.099", "PB": "1.254", "(([1]-[2])/[2])": "0.150997", "代码": "600720", "行业": "建材"],
    ["名称": "玲珑轮胎", "PETTM": "12.047", "PB": "1.189", "(([1]-[2])/[2])": "0.176941553", "代码": "601966", "行业": "汽车类"],
    ["名称": "上港集团", "PETTM": "10.196", "PB": "1.064", "(([1]-[2])/[2])": "0.246352647", "代码": "600018", "行业": "交通设施"],
    ["名称": "山东路桥", "PETTM": "3.879", "PB": "0.643", "(([1]-[2])/[2])": "0.260303606", "代码": "498", "行业": "建筑"],
    ["名称": "贵州轮胎", "PETTM": "9.981", "PB": "0.877", "(([1]-[2])/[2])": "0.177458034", "代码": "589", "行业": "汽车类"],
    ["名称": "上海电力", "PETTM": "9.789", "PB": "1.262", "(([1]-[2])/[2])": "0.276747504", "代码": "600021", "行业": "电力"],
    ["名称": "中材国际", "PETTM": "8.218", "PB": "1.207", "(([1]-[2])/[2])": "0.075581395", "代码": "600970", "行业": "建筑"],
    ["名称": "广东建工", "PETTM": "10.899", "PB": "1.022", "(([1]-[2])/[2])": "0.182119205", "代码": "2060", "行业": "建筑"],
    ["名称": "通宝能源", "PETTM": "11.994", "PB": "0.833", "(([1]-[2])/[2])": "0.134297521", "代码": "600780", "行业": "电力"],
    ["名称": "甘肃能化", "PETTM": "11.854", "PB": "0.859", "(([1]-[2])/[2])": "0.207207207", "代码": "552", "行业": "煤炭"],
    ["名称": "云图控股", "PETTM": "10.873", "PB": "1.059", "(([1]-[2])/[2])": "0.280672269", "代码": "2539", "行业": "化工"],
    ["名称": "柳药集团", "PETTM": "7.793", "PB": "0.909", "(([1]-[2])/[2])": "0.198347107", "代码": "603368", "行业": "商业连锁"],
    ["名称": "三角轮胎", "PETTM": "9.601", "PB": "0.887", "(([1]-[2])/[2])": "0.267934313", "代码": "601163", "行业": "汽车类"],
    ["名称": "大秦铁路", "PETTM": "12.807", "PB": "0.783", "(([1]-[2])/[2])": "0.155713075", "代码": "601006", "行业": "运输服务"],
    ["名称": "嘉泽新能", "PETTM": "11.159", "PB": "1.162", "(([1]-[2])/[2])": "0.228136882", "代码": "601619", "行业": "电力"],
    ["名称": "潞安环能", "PETTM": "12.111", "PB": "0.891", "(([1]-[2])/[2])": "0.084627329", "代码": "601699", "行业": "煤炭"],
    ["名称": "天地科技", "PETTM": "9.708", "PB": "1.036", "(([1]-[2])/[2])": "0.209255533", "代码": "600582", "行业": "工程机械"],
    ["名称": "北方国际", "PETTM": "9.676", "PB": "1.071", "(([1]-[2])/[2])": "0.178438662", "代码": "65", "行业": "建筑"],
    ["名称": "辰欣药业", "PETTM": "11.434", "PB": "1.036", "(([1]-[2])/[2])": "0.25046799", "代码": "603367", "行业": "医药"],
    ["名称": "皖能电力", "PETTM": "10.21", "PB": "1.131", "(([1]-[2])/[2])": "0.273389634", "代码": "543", "行业": "电力"],
    ["名称": "兰州银行", "PETTM": "7.249", "PB": "0.463", "(([1]-[2])/[2])": "0.154589372", "代码": "1227", "行业": "银行"],
    ["名称": "民生银行", "PETTM": "5.364", "PB": "0.321", "(([1]-[2])/[2])": "0.28525641", "代码": "600016", "行业": "银行"],
    ["名称": "九州通", "PETTM": "12.246", "PB": "1.016", "(([1]-[2])/[2])": "0.142528736", "代码": "600998", "行业": "商业连锁"],
    ["名称": "特变电工", "PETTM": "11.105", "PB": "0.968", "(([1]-[2])/[2])": "0.054607509", "代码": "600089", "行业": "电气设备"],
    ["名称": "秦港股份", "PETTM": "11.511", "PB": "0.943", "(([1]-[2])/[2])": "0.276010993", "代码": "601326", "行业": "交通设施"],
    ["名称": "山东海化", "PETTM": "8.96", "PB": "0.936", "(([1]-[2])/[2])": "0.203056769", "代码": "822", "行业": "化工"],
    ["名称": "贵阳银行", "PETTM": "4.037", "PB": "0.355", "(([1]-[2])/[2])": "0.257019438", "代码": "601997", "行业": "银行"],
    ["名称": "湖北能源", "PETTM": "12.601", "PB": "0.916", "(([1]-[2])/[2])": "0.251295337", "代码": "883", "行业": "电力"],
    ["名称": "浦东建设", "PETTM": "10.949", "PB": "0.759", "(([1]-[2])/[2])": "0.290048801", "代码": "600284", "行业": "建筑"],
    ["名称": "三峰环境", "PETTM": "11.678", "PB": "1.262", "(([1]-[2])/[2])": "0.288923315", "代码": "601827", "行业": "环境保护"],
    ["名称": "西安银行", "PETTM": "6.263", "PB": "0.477", "(([1]-[2])/[2])": "0.211072664", "代码": "600928", "行业": "银行"],
    ["名称": "中国能建", "PETTM": "10.867", "PB": "0.897", "(([1]-[2])/[2])": "0.118951613", "代码": "601868", "行业": "建筑"],
    ["名称": "恒源煤电", "PETTM": "8.122", "PB": "0.868", "(([1]-[2])/[2])": "0.087008343", "代码": "600971", "行业": "煤炭"],
    ["名称": "宝新能源", "PETTM": "11.3", "PB": "0.782", "(([1]-[2])/[2])": "0.151193634", "代码": "690", "行业": "电力"],
    ["名称": "安徽建工", "PETTM": "5.474", "PB": "0.762", "(([1]-[2])/[2])": "0.218421053", "代码": "600502", "行业": "建筑"],
    ["名称": "太阳能", "PETTM": "12.717", "PB": "0.761", "(([1]-[2])/[2])": "0.161209068", "代码": "591", "行业": "电力"],
    ["名称": "国药一致", "PETTM": "10.685", "PB": "0.871", "(([1]-[2])/[2])": "0.187919463", "代码": "28", "行业": "商业连锁"],
    ["名称": "浙能电力", "PETTM": "10.125", "PB": "1.02", "(([1]-[2])/[2])": "0.212389381", "代码": "600023", "行业": "电力"],
    ["名称": "张家港行", "PETTM": "5.515", "PB": "0.57", "(([1]-[2])/[2])": "0.212034384", "代码": "2839", "行业": "银行"],
    ["名称": "无锡银行", "PETTM": "5.481", "PB": "0.608", "(([1]-[2])/[2])": "0.257142857", "代码": "600908", "行业": "银行"],
    ["名称": "江阴银行", "PETTM": "5.288", "PB": "0.588", "(([1]-[2])/[2])": "0.279635258", "代码": "2807", "行业": "银行"],
    ["名称": "江苏国信", "PETTM": "9.927", "PB": "0.876", "(([1]-[2])/[2])": "0.23255814", "代码": "2608", "行业": "电力"],
    ["名称": "淮北矿业", "PETTM": "6.909", "PB": "0.877", "(([1]-[2])/[2])": "0.053405573", "代码": "600985", "行业": "煤炭"],
    ["名称": "青农商行", "PETTM": "5.994", "PB": "0.457", "(([1]-[2])/[2])": "0.267241379", "代码": "2958", "行业": "银行"],
    ["名称": "中钢国际", "PETTM": "9.705", "PB": "1.077", "(([1]-[2])/[2])": "0.293031066", "代码": "928", "行业": "建筑"],
    ["名称": "厦门银行", "PETTM": "5.675", "PB": "0.573", "(([1]-[2])/[2])": "0.27039627", "代码": "601187", "行业": "银行"],
    ["名称": "瑞丰银行", "PETTM": "5.587", "PB": "0.597", "(([1]-[2])/[2])": "0.256351039", "代码": "601528", "行业": "银行"],
    ["名称": "中新集团", "PETTM": "11.052", "PB": "0.766", "(([1]-[2])/[2])": "0.196056247", "代码": "601512", "行业": "房地产"],
    ["名称": "兰花科创", "PETTM": "12.068", "PB": "0.754", "(([1]-[2])/[2])": "0.104557641", "代码": "600123", "行业": "煤炭"],
    ["名称": "平煤股份", "PETTM": "8.211", "PB": "0.972", "(([1]-[2])/[2])": "0.229591837", "代码": "601666", "行业": "煤炭"],
    ["名称": "福能股份", "PETTM": "9.658", "PB": "1.086", "(([1]-[2])/[2])": "0.285522788", "代码": "600483", "行业": "电力"],
    ["名称": "紫金银行", "PETTM": "6.189", "PB": "0.52", "(([1]-[2])/[2])": "0.191304348", "代码": "601860", "行业": "银行"],
    ["名称": "山西焦煤", "PETTM": "11.285", "PB": "1.223", "(([1]-[2])/[2])": "0.118811881", "代码": "983", "行业": "煤炭"],
    ["名称": "中铁工业", "PETTM": "10.892", "PB": "0.725", "(([1]-[2])/[2])": "0.217572101", "代码": "600528", "行业": "运输设备"],
    ["名称": "中国中冶", "PETTM": "8.95", "PB": "0.642", "(([1]-[2])/[2])": "0.244094488", "代码": "601618", "行业": "建筑"],
    ["名称": "中国中铁", "PETTM": "5.024", "PB": "0.509", "(([1]-[2])/[2])": "0.232323232", "代码": "601390", "行业": "建筑"],
    ["名称": "中国电建", "PETTM": "7.266", "PB": "0.656", "(([1]-[2])/[2])": "0.203196469", "代码": "601669", "行业": "建筑"]
]

caculateNewScore(data)

