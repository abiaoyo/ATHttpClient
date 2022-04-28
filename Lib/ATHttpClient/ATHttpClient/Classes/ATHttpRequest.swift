import Foundation
import HandyJSON
import JSONModel

@objc public enum ATHttpMethod: Int{
    case connect
    case delete
    case get
    case head
    case options
    case patch
    case post
    case put
    case trace
    
    public var value:String {
        get {
            switch self {
            case .connect:
                return "CONNECT"
            case .delete:
                return "DELETE"
            case .get:
                return "GET"
            case .head:
                return "HEAD"
            case .options:
                return "OPTIONS"
            case .patch:
                return "PATCH"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .trace:
                return "TRACE"
            }
        }
    }
}

@objc public enum ATHttpParamsEncoding: Int{
    case urlDefault
    case urlQueryString
    case urlHttpBody
    case jsonDefault
    case jsonPrettyPrinted
}


@objcMembers
public class ATHttpRequestExt: NSObject {
    
    public var name:String = ""
    public var tryIndex:Int = 0
    public var tryCount:Int = 1
    public var respJsonEncoding:String.Encoding = .utf8
    
    public var disableRetryRequestInterceptor = false
    public var disableRequestInterceptor = false
    public var disableResponseSuccessInterceptor = false
    public var disableResponseFailureInterceptor = false
    
    public var jsonModelClass:ATHttpJsonModel.Type = ATHttpJsonModel.self
    public var jsonModelSuccess:((_ request: ATHttpRequest, _ response:Dictionary<String,Any>?, _ jsonModel:ATHttpJsonModel?) -> Void)?
    
    public var requestHeaders: [String : String]?
    public var responseHeaders: [String : String]?
    
    func canSendRequest() -> Bool {
        return tryIndex < tryCount
    }
    
    func incrTryTimes() {
        tryIndex += 1
    }
}

@objcMembers
public class ATHttpRequest: NSObject{
    
    public var baseUrl:String?
    public var api:String = ""
    public var url:String?
    public var method:ATHttpMethod = .get
    public var headers:[String:String] = [:]
    public var params:[String:Any] = [:]
    public var encoding:ATHttpParamsEncoding = .urlDefault
    
    public var timeout:TimeInterval = 20
    public var uploadTimeout:TimeInterval = 60
    public var downloadTimeout:TimeInterval = 20
    public var shouldHandlefCookies = true
    
    public let ext = ATHttpRequestExt.init()
    
    public var success:((_ request: ATHttpRequest, _ response:Dictionary<String,Any>?) -> Void)?
    public var failure:((_ request: ATHttpRequest, _ error:Error?) -> Void)?
    public var uploadProgress:((_ request: ATHttpRequest, _ progress:Progress) -> Void)?
    public var downloadProgress:((_ request: ATHttpRequest, _ progress:Progress) -> Void)?

    
        
    init(_ method: ATHttpMethod = .get) {
        self.method = method
    }
    
    public func setHeader(_ value:String, forKey key: String) {
        headers[key] = value
    }
    public func removeHeader(forKey key:String) {
        headers.removeValue(forKey: key)
    }
    
    public func setParam(_ value:Any, forKey key:String) {
        params[key] = value
    }
    public func removeParam(key:String) {
        params.removeValue(forKey: key)
    }
    
    public var fullUrl:String{
        get {
            if let _url = url {
                return _url
            }
            if baseUrl != nil {
                if api.hasPrefix("/") {
                    return "\(baseUrl!)\(api)"
                }else{
                    return "\(baseUrl!)/\(api)"
                }
            }
            return api
        }
    }
    
    public static var get:ATHttpRequest {
        return ATHttpRequest.init()
    }
    
    public static var post:ATHttpRequest {
        let request = ATHttpRequest.init(.post)
        request.encoding = .jsonDefault
        return request
    }
    
    public static var delete:ATHttpRequest {
        return ATHttpRequest.init(.delete)
    }
    
    public static var put:ATHttpRequest {
        let request = ATHttpRequest.init(.put)
        request.encoding = .jsonDefault
        return request
    }
}

extension ATHttpRequest {
    public func desc1() -> String{
        return """
        ### ATHttpRequest ###
        .name:\(ext.name)
        .url:\(fullUrl)
        .method:\(method.value)
        .params:\(params)
        ###
        """
    }
    
    public func desc2() -> String{
        return """
        ### ATHttpRequest ###
        .name:\(ext.name)
        .tryIndex:\(ext.tryIndex)
        .tryCount:\(ext.tryCount)
        .url:\(fullUrl)
        .method:\(method.value)
        .headers:\(headers)
        .params:\(params)
        ###
        """
    }
}
