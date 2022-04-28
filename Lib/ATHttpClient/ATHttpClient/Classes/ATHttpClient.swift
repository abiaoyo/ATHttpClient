import Foundation
import Alamofire
import HandyJSON

@objc public enum ATHttpNetworkStatus: Int {
    case unknown
    case notReachable
    case ethernetOrWiFi
    case cellular
    
    public var isReachable:Bool {
        return self == .ethernetOrWiFi || self == .cellular
    }
}

@objc public enum ATHttpFileType: Int {
    case image
    case video
    
    var value:String {
        get {
            switch self {
            case .image:
                return "image"
            case .video:
                return "video"
            }
        }
    }
}


public typealias ATHttpNetworkStatusListener = (_ status: ATHttpNetworkStatus) -> Void
public typealias ATHttpRetryRequestHandler = (_ request: ATHttpRequest) -> Void
public typealias ATHttpRequestHandler = (_ request: ATHttpRequest) -> Void
public typealias ATHttpResponseSuccessHandler = (_ request: ATHttpRequest, _ response:Dictionary<String,Any>?) -> Bool
public typealias ATHttpResponseFailureHandler = (_ request: ATHttpRequest, _ error:Error) -> Void


@objcMembers
public class ATHttpClient: NSObject{

    public static let client = ATHttpClient.init()
    
    private static var _networkListener:ATHttpNetworkStatusListener?
    
    public static var networkStatus:ATHttpNetworkStatus {
        get {
            switch NetworkReachabilityManager.default!.status {
                
            case .notReachable:
                return .notReachable
                
            case .reachable(.cellular):
                return  .cellular
                
            case .reachable(.ethernetOrWiFi):
                return .ethernetOrWiFi
                
            case .unknown:
                break
            }
            
            return .unknown
        }
    }
    
    public static var isReachable:Bool {
        get {
            return networkStatus.isReachable
        }
    }
    
    public static func networkListening(_ handler:ATHttpNetworkStatusListener?) {
        _networkListener = handler
        
        NetworkReachabilityManager.default!.startListening(onUpdatePerforming: { status in
            _networkListener?(networkStatus)
        })
    }
    
    public var retryRequestInterceptor:ATHttpRetryRequestHandler?
    public var requestInterceptor:ATHttpRequestHandler?
    public var responseSuccessInterceptor:ATHttpResponseSuccessHandler?
    public var responseFailureInterceptor:ATHttpResponseFailureHandler?
    public let baseUrlsPool = ATHttpUrlsPool.init()
    
    private func paramsEncoding(_ paramsEncoding:ATHttpParamsEncoding) -> ParameterEncoding {
        
        switch paramsEncoding {
            
        case .urlDefault:
            return URLEncoding.default
            
        case .urlQueryString:
            return URLEncoding.queryString
            
        case .urlHttpBody:
            return URLEncoding.httpBody
            
        case .jsonDefault:
            return JSONEncoding.default
            
        case .jsonPrettyPrinted:
            return JSONEncoding.prettyPrinted
        }
    }
    
    @discardableResult
    private func _dataRequest(_ request: ATHttpRequest) -> DataRequest? {
        
        if !request.ext.canSendRequest() {
            return nil
        }
        
        if request.baseUrl == nil {
            request.baseUrl = baseUrlsPool.currentUrl
        }
        
        if !request.ext.disableRequestInterceptor {
            requestInterceptor?(request)
        }
        
        request.ext.incrTryTimes()
        
        return AF.request(request.fullUrl,
                          method: HTTPMethod(rawValue: request.method.value),
                          parameters: request.params,
                          encoding: paramsEncoding(request.encoding),
                          headers: HTTPHeaders(request.headers),
                          interceptor: nil,
                          requestModifier: {
            $0.timeoutInterval = request.timeout
            $0.httpShouldHandleCookies = request.shouldHandlefCookies
        })
    }
    
    @discardableResult
    private func _uploadDataRequest(_ request: ATHttpRequest, fileUrl: URL, fileName:String, type:String,_ mimeType:String = "multipart/form-data") -> UploadRequest?{
        
        if !request.ext.canSendRequest() {
            return nil
        }
        
        if request.baseUrl == nil {
            request.baseUrl = baseUrlsPool.currentUrl
        }
        
        if !request.ext.disableRequestInterceptor {
            requestInterceptor?(request)
        }
        
        request.ext.incrTryTimes()
        
        return AF.upload(multipartFormData: { formData in
            
            formData.append(type.data(using: .utf8)!, withName: "type")
            formData.append(fileUrl, withName: "file", fileName: fileName, mimeType: mimeType)
            
        }, to: request.fullUrl, method: HTTPMethod(rawValue: request.method.value), headers: HTTPHeaders(request.headers)) {
            
            $0.timeoutInterval = request.uploadTimeout
            $0.httpShouldHandleCookies = request.shouldHandlefCookies
            
        }
    }
    private func _uploadDataRequest(_ request: ATHttpRequest, data: Data, fileName:String, type:String, mimeType:String = "multipart/form-data") -> UploadRequest? {
        
        if !request.ext.canSendRequest() {
            return nil
        }
        
        if request.baseUrl == nil {
            request.baseUrl = baseUrlsPool.currentUrl
        }
        
        if !request.ext.disableRequestInterceptor {
            requestInterceptor?(request)
        }
        
        request.ext.incrTryTimes()
        
        return AF.upload(multipartFormData: { formData in
            
            formData.append(type.data(using: .utf8)!, withName: "type")
            formData.append(data, withName: "file", fileName: fileName, mimeType: mimeType)
            
        }, to: request.fullUrl, method: HTTPMethod(rawValue: request.method.value), headers: HTTPHeaders(request.headers)) {
            
            $0.timeoutInterval = request.uploadTimeout
            $0.httpShouldHandleCookies = request.shouldHandlefCookies
        }
    }
    
    private func _downloadDataRequest(_ request: ATHttpRequest, cachePath: String? = nil) -> DownloadRequest? {

        if !request.ext.canSendRequest() {
            return nil
        }
        
        if request.baseUrl == nil {
            request.baseUrl = baseUrlsPool.currentUrl
        }
        
        if !request.ext.disableRequestInterceptor {
            requestInterceptor?(request)
        }
        
        request.ext.incrTryTimes()
        
        var destination: DownloadRequest.Destination?
        
        if let cachePath = cachePath {
            destination = { _, _ in
                return (URL(fileURLWithPath: cachePath), [.createIntermediateDirectories, .removePreviousFile])
            }
        }
        return AF.download(request.fullUrl, method: HTTPMethod(rawValue: request.method.value), parameters: request.params, headers: HTTPHeaders(request.headers), requestModifier: {
            $0.timeoutInterval = request.downloadTimeout
            $0.httpShouldHandleCookies = request.shouldHandlefCookies
        }, to: destination)
    }
    
    @discardableResult
    private func _handleAF(_ request: ATHttpRequest, dataRequest:DataRequest?, rsRuccess: ((_ data:Data, _ dataDict:Dictionary<String, Any>?) -> Void)?,rsFailure: ((_ error: Error?) -> Void)?) -> ATHttpTask{
        
        let task = ATHttpTask.init(dataRequest)
        
        dataRequest?.responseData(completionHandler: { resp in
            
            _ = task
            
            request.ext.requestHeaders = resp.request?.allHTTPHeaderFields as? [String : String]
            request.ext.responseHeaders = resp.response?.allHeaderFields as? [String : String]
            
            switch resp.result {
            case .success(let data):
                let dataDict = try?JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
                
                if !request.ext.disableResponseSuccessInterceptor {
                    if let interceptor = self.responseSuccessInterceptor {
                        let canContinue = interceptor(request, dataDict)
                        if !canContinue {
                            return
                        }
                    }
                }
                
                request.success?(request, dataDict)
                
                if let _ = request.ext.jsonModelSuccess {
                    
                    if let jsonModel = try?request.ext.jsonModelClass.init(dictionary: dataDict) {
                        request.ext.jsonModelSuccess?(request, dataDict ,jsonModel)
                    }else{
                        request.ext.jsonModelSuccess?(request, dataDict, nil)
                    }
                }
                rsRuccess?(data,dataDict)
                
                break
            case .failure(let error):
                
                if request.ext.canSendRequest() {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        
                        if !request.ext.disableRetryRequestInterceptor {
                            
                            self.retryRequestInterceptor?(request)
                        }
                        self._handleAF(request, dataRequest: dataRequest, rsRuccess: rsRuccess, rsFailure: rsFailure)
                    }
                }else{
                    
                    if !request.ext.disableResponseFailureInterceptor {
                        
                        self.responseFailureInterceptor?(request, error)
                    }
                    request.failure?(request, error)
                    rsFailure?(error)
                }
                break
            }
        })
        return task
    }
}

extension ATHttpClient {
    
    @discardableResult
    public func sendRequest(_ request: ATHttpRequest, success:((_ response: Dictionary<String,Any>?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> ATHttpTask{
        
        let dataRequest = _dataRequest(request)
        
        return _handleAF(request, dataRequest: dataRequest) { data, dataDict in
            success?(dataDict)
        } rsFailure: { error in
            failure?(error)
        }
    }
    
    @discardableResult
    public func sendRequest(_ request: ATHttpRequest) -> ATHttpTask{
        return sendRequest(request, success: nil, failure: nil)
    }
    
    
    @discardableResult
    public func sendRequest<T:HandyJSON, Response: ATHttpHandyJson<T>>(_ request: ATHttpRequest, success:@escaping ((_ jsonResponse:Response?) -> Void), failure:@escaping (_ error: Error?) -> Void) -> ATHttpTask{
        
        return sendRequest(request) { resp in
            success(Response.deserialize(from: resp))
        } failure: { error in
            failure(error)
        }
    }
}

extension ATHttpClient {
    
    //upload data
    @discardableResult
    public func upload(_ request: ATHttpRequest, data:Data, fileName:String, type:ATHttpFileType, uploadProgress:((_ progress:Progress) -> Void)?, success:((_ response: Dictionary<String,Any>?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> ATHttpTask{
        
        let dataRequest = _uploadDataRequest(request, data: data, fileName: fileName, type: type.value)
        
        dataRequest?.uploadProgress(closure: { p in
            request.uploadProgress?(request, p)
            uploadProgress?(p)
        })
        
        return _handleAF(request, dataRequest: dataRequest) { data, dataDict in
            success?(dataDict)
        } rsFailure: { error in
            failure?(error)
        }
    }
    
    @discardableResult
    public func upload(_ request: ATHttpRequest, data:Data, fileName:String, type:ATHttpFileType) -> ATHttpTask{
        return upload(request, data: data, fileName: fileName, type: type, uploadProgress: nil, success: nil, failure: nil)
    }
    
    @discardableResult
    public func upload<T:HandyJSON, Response: ATHttpHandyJson<T>>(_ request: ATHttpRequest, data:Data, fileName:String, type:ATHttpFileType, uploadProgress:((_ progress:Progress) -> Void)?, success:@escaping ((_ jsonResponse:Response?) -> Void), failure:@escaping (_ error: Error?) -> Void) -> ATHttpTask{
        
        return upload(request, data: data, fileName: fileName, type: type, uploadProgress: uploadProgress) { response in
            success(Response.deserialize(from: response))
        } failure: { error in
            failure(error)
        }
    }
    
    
    // upload fileUrl
    @discardableResult
    public func upload(_ request: ATHttpRequest, fileUrl:URL, fileName:String, type:ATHttpFileType, uploadProgress:((_ progress:Progress) -> Void)?, success:((_ response: Dictionary<String,Any>?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> ATHttpTask{
        
        let dataRequest = _uploadDataRequest(request, fileUrl: fileUrl, fileName: fileName, type: type.value)
        
        dataRequest?.uploadProgress(closure: { p in
            request.uploadProgress?(request, p)
            uploadProgress?(p)
        })
        
        return _handleAF(request, dataRequest: dataRequest) { data, dataDict in
            success?(dataDict)
        } rsFailure: { error in
            failure?(error)
        }
    }
    
    @discardableResult
    public func upload(_ request: ATHttpRequest, fileUrl:URL, fileName:String, type:ATHttpFileType) -> ATHttpTask{
        return upload(request, fileUrl: fileUrl, fileName: fileName, type: type, uploadProgress: nil, success: nil, failure: nil)
    }
    
    @discardableResult
    public func upload<T:HandyJSON, Response: ATHttpHandyJson<T>>(_ request: ATHttpRequest, fileUrl:URL, fileName:String, type:ATHttpFileType, uploadProgress:((_ progress:Progress) -> Void)?, success:@escaping ((_ jsonResponse:Response?) -> Void), failure:@escaping (_ error: Error?) -> Void) -> ATHttpTask{
        
        return upload(request, fileUrl: fileUrl, fileName: fileName, type: type, uploadProgress: uploadProgress) { response in
            success(Response.deserialize(from: response))
        } failure: { error in
            failure(error)
        }
    }
}

extension ATHttpClient {
    
    @discardableResult
    public func download(_ request: ATHttpRequest, cachePath: String, downloadProgress:((_ progress:Progress) -> Void)?, success:((_ url: URL) -> Void)?, failure:((_ error: Error?) -> Void)?) -> ATHttpTask{
        
        let downloadRequest = _downloadDataRequest(request, cachePath: cachePath)
        
        let task = ATHttpTask.init(downloadRequest: downloadRequest)
        
        downloadRequest?.downloadProgress(closure: { p in
            request.downloadProgress?(request, p)
            downloadProgress?(p)
        })
        
        downloadRequest?.response(completionHandler: { response in
            _ = task
            switch response.result {
            case .success(let url):
                guard let url = url else {
                    failure?(nil)
                    return
                }
                success?(url)
            case .failure(let error):
                failure?(error)
            }
        })
        
        return task
    }

}
