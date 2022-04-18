#import "ATHttpClient.h"

static ATHttpSessionManagerInterceptor _globalSessionManagerInterceptor = nil;
static ATHttpRequestRetryInterceptor _globalRequestWillRetryInterceptor = nil;
static ATHttpRequestInterceptor _globalRequestInterceptor = nil;
static ATHttpResponseInterceptor _globalResponseInterceptor = nil;
static ATHttpSuccessInterceptor _globalSuccessInterceptor = nil;
static ATHttpFailureInterceptor _globalFailureInterceptor = nil;


@implementation ATHttpClient

+ (ATHttpSessionManagerInterceptor)globalSessionManagerInterceptor{
    return _globalSessionManagerInterceptor;
}
+ (void)setGlobalSessionManagerInterceptor:(ATHttpSessionManagerInterceptor)globalSessionManagerInterceptor{
    _globalSessionManagerInterceptor = [globalSessionManagerInterceptor copy];
}

+ (ATHttpRequestRetryInterceptor)globalRequestWillRetryInterceptor{
    return _globalRequestWillRetryInterceptor;
}

+ (void)setGlobalRequestWillRetryInterceptor:(ATHttpRequestRetryInterceptor)globalRequestWillRetryInterceptor{
    _globalRequestWillRetryInterceptor = [globalRequestWillRetryInterceptor copy];
}

+ (ATHttpRequestInterceptor)globalRequestInterceptor{
    return _globalRequestInterceptor;
}
+ (void)setGlobalRequestInterceptor:(ATHttpRequestInterceptor)globalRequestInterceptor{
    _globalRequestInterceptor = [globalRequestInterceptor copy];
}

+ (ATHttpResponseInterceptor)globalResponseInterceptor{
    return _globalResponseInterceptor;
}
+ (void)setGlobalResponseInterceptor:(ATHttpResponseInterceptor)globalResponseInterceptor{
    _globalResponseInterceptor = [globalResponseInterceptor copy];
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
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:monitoringBlock];
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
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

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)request
                              success:(ATHttpRequestSuccess)success
                              failure:(ATHttpRequestFailure)failure{
    AFHTTPSessionManager * manager = [self defaultSessionManager];
    return [self sendRequest:request
                     manager:manager
              uploadProgress:nil
            downloadProgress:nil
                     success:success
                     failure:failure];
}

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)request
                       uploadProgress:(ATHttpUploadProgress)uploadProgress
                     downloadProgress:(ATHttpDownloadProgress)downloadProgress
                              success:(ATHttpRequestSuccess)success
                              failure:(ATHttpRequestFailure)failure
{
    AFHTTPSessionManager * manager = [self defaultSessionManager];
    return [self sendRequest:request
                     manager:manager
              uploadProgress:uploadProgress
            downloadProgress:downloadProgress
                     success:success
                     failure:failure];
}

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)request
                              manager:(AFHTTPSessionManager *)manager
                       uploadProgress:(ATHttpUploadProgress)uploadProgress
                     downloadProgress:(ATHttpDownloadProgress)downloadProgress
                              success:(ATHttpRequestSuccess)success
                              failure:(ATHttpRequestFailure)failure
{
    //判断是否能请求
    if(![request canSendRequest]){
        return nil;
    }
    //减少重试次数
    [request incrTryTimes];
    
    if(request.ext.sessionManagerInterceptor){
        //Session Manager拦截器
        request.ext.sessionManagerInterceptor(manager, request);
    }else if(_globalSessionManagerInterceptor){
        //Session Manager拦截器(全局)
        manager = _globalSessionManagerInterceptor(manager,request);
    }
    
    if(request.ext.requestInterceptor){
        //请求拦截器
        request.ext.requestInterceptor(manager,request);
    }else if(_globalRequestInterceptor){
        //请求拦截器(全局)
        _globalRequestInterceptor(manager,request);
    }
    //请求头处理
    [request.headers enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    //合并请求头
    NSDictionary * reqHeaders = [NSDictionary dictionaryWithDictionary:[manager.requestSerializer HTTPRequestHeaders]];
    
    NSString * method = nil;
    switch (request.method) {
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
                                                               URLString:request.requestUrl
                                                              parameters:request.params
                                                                 headers:request.headers
                                                          uploadProgress:uploadProgress
                                                        downloadProgress:downloadProgress
                                                                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [manager.session finishTasksAndInvalidate];
            
            //响应拦截器(全局)
            BOOL canContinue = YES;
            if(_globalResponseInterceptor){
                canContinue = _globalResponseInterceptor(request,task,responseObject,reqHeaders,YES,nil);
            }
            if(!canContinue){
                return;
            }
            
            //请求成功拦截器
            if(request.ext.successInterceptor){
                request.ext.successInterceptor(request, task, responseObject, success, failure);
                return;
            }
            //请求成功拦截器(全局)
            if(_globalSuccessInterceptor){
                _globalSuccessInterceptor(request,task,responseObject,success,failure);
                return;
            }
            //无拦截器
            success(request,task,responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [manager.session finishTasksAndInvalidate];
            
            //判断能不能继续
            if([request canSendRequest]){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(_globalRequestWillRetryInterceptor){
                        _globalRequestWillRetryInterceptor(request);
                    }
                    [ATHttpClient sendRequest:request
                               uploadProgress:uploadProgress
                             downloadProgress:downloadProgress
                                      success:success
                                      failure:failure];
                });
                return;
            }
            //响应拦截器(全局)
            BOOL canContinue = YES;
            if(_globalResponseInterceptor){
                canContinue = _globalResponseInterceptor(request,task,nil,reqHeaders,NO,error);
            }
            if(!canContinue){
                return;
            }
            //请求成功拦截器
            if(request.ext.failureInterceptor){
                request.ext.failureInterceptor(request, task, error, success, failure);
                return;
            }
            //请求失败拦截器(全局)
            if(_globalFailureInterceptor){
                _globalFailureInterceptor(request,task,error,success,failure);
                return;
            }
            //无拦截器
            failure(request,task,error);
        }];
        [dataTask resume];
        return dataTask;
    }
    return nil;
}

@end
