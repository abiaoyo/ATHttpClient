#import "ATHttpClient.h"

static ATHttpSessionManagerInterceptor _globalSessionManagerInterceptor;
static ATHttpRequestRetryInterceptor _globalRequestRetryInterceptor;
static ATHttpRequestInterceptor _globalRequestInterceptor;
static ATHttpResponseInterceptor _globalResponseSuccessInterceptor;
static ATHttpResponseInterceptor _globalResponseFailureInterceptor;
static Class _jsonModelClass;

@implementation ATHttpClient

+ (Class)jsonModelClass{
    return _jsonModelClass;
}

+ (void)setJsonModelClass:(Class)jsonModelClass{
    _jsonModelClass = jsonModelClass;
}

+ (ATHttpSessionManagerInterceptor)globalSessionManagerInterceptor{
    return _globalSessionManagerInterceptor;
}
+ (void)setGlobalSessionManagerInterceptor:(ATHttpSessionManagerInterceptor)globalSessionManagerInterceptor{
    _globalSessionManagerInterceptor = [globalSessionManagerInterceptor copy];
}

+ (ATHttpRequestRetryInterceptor)globalRequestRetryInterceptor{
    return _globalRequestRetryInterceptor;
}

+ (void)setGlobalRequestRetryInterceptor:(ATHttpRequestRetryInterceptor)globalRequestRetryInterceptor{
    _globalRequestRetryInterceptor = [globalRequestRetryInterceptor copy];
}

+ (ATHttpRequestInterceptor)globalRequestInterceptor{
    return _globalRequestInterceptor;
}
+ (void)setGlobalRequestInterceptor:(ATHttpRequestInterceptor)globalRequestInterceptor{
    _globalRequestInterceptor = [globalRequestInterceptor copy];
}

+ (ATHttpResponseInterceptor)globalResponseSuccessInterceptor{
    return _globalResponseSuccessInterceptor;
}
+ (void)setGlobalResponseSuccessInterceptor:(ATHttpResponseInterceptor)globalResponseSuccessInterceptor{
    _globalResponseSuccessInterceptor = [globalResponseSuccessInterceptor copy];
}

+ (ATHttpResponseInterceptor)globalResponseFailureInterceptor{
    return _globalResponseFailureInterceptor;
}
+ (void)setGlobalResponseFailureInterceptor:(ATHttpResponseInterceptor)globalResponseFailureInterceptor{
    _globalResponseFailureInterceptor = [globalResponseFailureInterceptor copy];
}


+ (void)startNetworkMonitoring:(void (^)(AFNetworkReachabilityStatus status))monitoringBlock{
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:monitoringBlock];
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
}

+ (NSString *)networkStatusStr:(AFNetworkReachabilityStatus)status{
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

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)request{
    AFHTTPSessionManager * manager = [self defaultSessionManager];
    return [self sendRequest:request manager:manager];
}

+ (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)request
                              manager:(AFHTTPSessionManager *)manager{
    //判断是否能请求
    if(![request canSendRequest]){
        return nil;
    }
    //减少重试次数
    [request incrTryTimes];
    
    //Session Manager拦截器(全局)
    if(_globalSessionManagerInterceptor && !request.ext.disableSessionManagerInterceptor){
        manager = _globalSessionManagerInterceptor(manager,request);
    }
    
    //Session Manager拦截器
    if(request.ext.sessionManagerHandler){
        request.ext.sessionManagerHandler(manager, request);
    }
    
    //请求拦截器(全局)
    if(_globalRequestInterceptor && !request.ext.disableRequestInterceptor){
        _globalRequestInterceptor(manager,request);
    }
    
    //请求头处理
    [request.headers enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithHTTPMethod:request.requestMethod
                                                           URLString:request.requestUrl
                                                          parameters:request.params
                                                             headers:request.headers
                                                      uploadProgress:request.ext.uploadProgress
                                                    downloadProgress:request.ext.downloadProgress
                                                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [manager.session finishTasksAndInvalidate];
        
        //响应拦截器(全局)
        BOOL canContinue = YES;
        if(_globalResponseSuccessInterceptor && !request.ext.disableResponseSuccessInterceptor){
            canContinue = _globalResponseSuccessInterceptor(request,task,responseObject,nil);
            if(!canContinue){
                return;
            }
        }
        //无拦截器
        if(request.ext.jsonSuccess){
            id respModel = nil;
            if(request.ext.jsonModelClass){
                respModel = [[request.ext.jsonModelClass alloc] initWithDictionary:responseObject error:nil];
            }else if(_jsonModelClass){
                respModel = [[_jsonModelClass alloc] initWithDictionary:responseObject error:nil];
            }
            request.ext.jsonSuccess(request, task, responseObject, respModel);
        }
        if(request.ext.success){
            request.ext.success(request,task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [manager.session finishTasksAndInvalidate];
        
        //判断能不能继续
        if([request canSendRequest]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(_globalRequestRetryInterceptor && !request.ext.disableRequestRetryInterceptor){
                    _globalRequestRetryInterceptor(request);
                }
                [ATHttpClient sendRequest:request];
            });
            return;
        }
        //响应拦截器(全局)
        BOOL canContinue = YES;
        if(_globalResponseFailureInterceptor && !request.ext.disableResponseFailureInterceptor){
            canContinue = _globalResponseFailureInterceptor(request,task,nil,error);
            if(!canContinue){
                return;
            }
        }
        //无拦截器
        if(request.ext.failure){
            request.ext.failure(request,task,error);
        }
    }];
    [dataTask resume];
    return dataTask;
}

@end
