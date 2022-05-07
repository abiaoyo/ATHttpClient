import UIKit
import ATHttpClient
import HandyJSON

struct WeatherInfo : HandyJSON{
    var AP:String?
    var Radar:String?
    var SD:String?
    var city:String?
    var cityid:Int = 0
}

class WeatherResponse : ATHttpHandyJsonResponse<WeatherInfo> {
    override func mapping(mapper: HelpingMapper) {
        mapper <<<
                    self.data <-- "weatherinfo"
    }
}

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("baseUrls: \(ATHttpClient.client.baseUrlsPool.urls)")
        
        ATHttpClient.networkListening { status in
            
        }
        
        let request = ATHttpRequest.get
        request.baseUrl = "http://www.weather.com.cn"
        request.api = "/data/sk/101190408.html"
        request.headers = ["time":"1234","age":"23"]
        request.params = ["age":"230","sex":0]
        
        ATHttpClient.client.sendRequest(request) { (handyJsonResponse:WeatherResponse?) in

            print("resp: .status:\(handyJsonResponse?.status)  .message:\(handyJsonResponse?.message)   .data:\(handyJsonResponse?.data)")
            print("jsonResponse: \(handyJsonResponse)")
        } failure: { error in
            print("error: \(error)")
        }
        
//        ATHttpClient.client.upload(request, data: Data.init(), fileName: "", type: .image) { progress in
//
//        } success: { response in
//
//        } failure: { error in
//
//        }
//
//        ATHttpClient.client.download(request, cachePath: "") { progress in
//
//        } success: { url in
//
//        } failure: { error in
//
//        }
    }

}
