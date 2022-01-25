#import "ATHttpClient.h"

static ATHttpSessionManagerInterceptor _globalSessionManagerInterceptor = nil;
static ATHttpRequestInterceptor _globalRequestInterceptor = nil;
static ATHttpSuccessInterceptor _globalSuccessInterceptor = nil;
static ATHttpFailureInterceptor _globalFailureInterceptor = nil;

@implementation ATHttpClient

+ (ATHttpSessionManagerInterceptor)globalSessionManagerInterceptor{
    return _globalSessionManagerInterceptor;
}
+ (void)setGlobalSessionManagerInterceptor:(ATHttpSessionManagerInterceptor)globalSessionManagerInterceptor{
    _globalSessionManagerInterceptor = [globalSessionManagerInterceptor copy];
}

+ (ATHttpRequestInterceptor)globalRequestInterceptor{
    return _globalRequestInterceptor;
}
+ (void)setGlobalRequestInterceptor:(ATHttpRequestInterceptor)globalRequestInterceptor{
    _globalRequestInterceptor = [globalRequestInterceptor copy];
}

+ (ATHttpSuccessInterceptor)globalSuccessInterceptor{
    return _globalSuccessInterceptor;
}
+ (void)setGlobalSuccessInterceptor:(ATHttpSuccessInterceptor)globalSuccessInterceptor{
    _globalSuccessInterceptor = [globalSuccessInterceptor copy];
}

+ (ATHttpFailureInterceptor)globalFailureInterceptor{
    return _globalFailureInterceptor;
}
+ (void)setGlobalFailureInterceptor:(ATHttpFailureInterceptor)globalFailureInterceptor{
    _globalFailureInterceptor = [globalFailureInterceptor copy];
}


+ (void)startNetworkMonitoring:(void (^)(AFNetworkReachabilityStatus status))monitoringBlock{
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:monitoringBlock];
}

+ (NSString *)coverterNetworkStatus:(AFNetworkReachabilityStatus)status{
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            return @"无网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return @"移动网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return @"WIFI";
            break;
            
        default:
            return @"未知"; //AFNetworkReachabilityStatusUnknown
            break;
    }
}

+ (AFNetworkReachabilityStatus)networkStatus{
    return AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus;
}

+ (AFHTTPSessionManager *)defaultSessionManager{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/html",
                                                         @"text/xml",
                                                         @"text/plain",
                                                         @"application/json",
                                                         nil];
    
    manager.operationQueue.maxConcurrentOperationCount = 5;
    manager.requestSerializer.timeoutInterval = 20;
    return manager;
}

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)reqeust
                              success:(ATHttpRequestSuccess)success
                              failure:(ATHttpRequestFailure)failure{
    AFHTTPSessionManager * manager = [self defaultSessionManager];
    return [self sendRequest:reqeust
                     manager:manager
              uploadProgress:nil
            downloadProgress:nil
                     success:success
                     failure:failure];
}

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)reqeust
                       uploadProgress:(ATHttpUploadProgress)uploadProgress
                     downloadProgress:(ATHttpDownloadProgress)downloadProgress
                              success:(ATHttpRequestSuccess)success
                              failure:(ATHttpRequestFailure)failure
{
    AFHTTPSessionManager * manager = [self defaultSessionManager];
    return [self sendRequest:reqeust
                     manager:manager
              uploadProgress:uploadProgress
            downloadProgress:downloadProgress
                     success:success
                     failure:failure];
}

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)reqeust
                              manager:(AFHTTPSessionManager *)manager
                       uploadProgress:(ATHttpUploadProgress)uploadProgress
                     downloadProgress:(ATHttpDownloadProgress)downloadProgress
                              success:(ATHttpRequestSuccess)success
                              failure:(ATHttpRequestFailure)failure
{
    //判断是否能请求
    if(![reqeust canSendRequest]){
        return nil;
    }
    //减少重试次数
    [reqeust reduceRetryTimes];
    
    //网络状态拦截
    AFNetworkReachabilityStatus networkStatus = AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus;
    
    if(![@[@(AFNetworkReachabilityStatusReachableViaWWAN),@(AFNetworkReachabilityStatusReachableViaWiFi)] containsObject:@(networkStatus)]){
        if(failure){
            NSError * error = [NSError errorWithDomain:NSLocalizedDescriptionKey
                                                  code:NSURLErrorNetworkConnectionLost
                                              userInfo:@{ NSLocalizedDescriptionKey : @"Network not available."}];
            failure(reqeust,nil,error);
        }
        return nil;
    }
    
    if(reqeust.sessionManagerInterceptor){
        //Session Manager拦截器
        reqeust.sessionManagerInterceptor(manager, reqeust);
    }else if(_globalSessionManagerInterceptor){
        //Session Manager拦截器(全局)
        manager = _globalSessionManagerInterceptor(manager,reqeust);
    }
    
    if(reqeust.requestInterceptor){
        //请求拦截器
        reqeust.requestInterceptor(reqeust);
    }else if(_globalRequestInterceptor){
        //请求拦截器(全局)
        _globalRequestInterceptor(reqeust);
    }
    
    NSString * method = nil;
    switch (reqeust.method) {
        case ATHttpMethodGet:
            method = @"GET";
            break;
        case ATHttpMethodPost:
            method = @"POSt";
            break;
        case ATHttpMethodPut:
            method = @"PUT";
            break;
        case ATHttpMethodDelete:
            method = @"DELETE";
            break;
        case ATHttpMethodHead:
            method = @"HEAD";
            break;
        case ATHttpMethodPatch:
            method = @"PATCH";
            break;
        default:
            break;
    }
    if(method){
        NSURLSessionDataTask *dataTask = [manager dataTaskWithHTTPMethod:method
                                                               URLString:reqeust.requestUrl
                                                              parameters:reqeust.params
                                                                 headers:reqeust.headers
                                                          uploadProgress:uploadProgress
                                                        downloadProgress:downloadProgress
                                                                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [manager.session finishTasksAndInvalidate];
            //请求成功拦截器
            if(reqeust.successInterceptor){
                reqeust.successInterceptor(reqeust, task, responseObject, success, failure);
                return;
            }
            //请求成功拦截器(全局)
            if(_globalSuccessInterceptor){
                _globalSuccessInterceptor(reqeust,task,responseObject,success,failure);
                return;
            }
            //无拦截器
            success(reqeust,task,responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [manager.session finishTasksAndInvalidate];
            //请求成功拦截器
            if(reqeust.failureInterceptor){
                reqeust.failureInterceptor(reqeust, task, error, uploadProgress, downloadProgress, success, failure);
                return;
            }
            //请求失败拦截器(全局)
            if(_globalFailureInterceptor){
                _globalFailureInterceptor(reqeust,task,error,uploadProgress,downloadProgress,success,failure);
                return;
            }
            failure(reqeust,task,error);
        }];
        [dataTask resume];
        return dataTask;
    }
    return nil;
}

@end
