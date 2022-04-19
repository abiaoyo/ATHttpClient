#import "ATHttpClient.h"


@interface ATHttpClient()
@property (nonatomic,strong) ATHttpUrlsPool * baseUrlsPool;
@end

@implementation ATHttpClient

+ (ATHttpClient *)client{
    static ATHttpClient * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ATHttpClient new];
    });
    return instance;
}

- (ATHttpUrlsPool *)baseUrlsPool{
    if(!_baseUrlsPool){
        _baseUrlsPool = [ATHttpUrlsPool new];
    }
    return _baseUrlsPool;
}

- (void)startNetworkMonitoring:(void (^)(AFNetworkReachabilityStatus status))monitoringBlock{
    [AFNetworkReachabilityManager.sharedManager setReachabilityStatusChangeBlock:monitoringBlock];
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
}

- (AFNetworkReachabilityStatus)networkStatus{
    return AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus;
}

- (AFHTTPSessionManager *)defaultSessionManager{
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

- (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)request{
    AFHTTPSessionManager * manager = [self defaultSessionManager];
    return [self sendRequest:request manager:manager];
}

- (NSURLSessionDataTask *)sendRequest:(ATHttpRequest *)request
                              manager:(AFHTTPSessionManager *)manager{
    if(request.baseUrl.length == 0){
        request.baseUrl = self.baseUrlsPool.currentUrl;
    }
    //判断是否能请求
    if(![request.ext canSendRequest]){
        return nil;
    }
    //减少重试次数
    [request.ext incrTryTimes];
    
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
    
    
    __weak typeof(self) weakself = self;
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
        if(weakself.globalResponseSuccessInterceptor && !request.ext.disableResponseSuccessInterceptor){
            canContinue = weakself.globalResponseSuccessInterceptor(request,task,responseObject,nil);
            if(!canContinue){
                return;
            }
        }
        //无拦截器
        if(request.ext.jsonSuccess){
            id respModel = nil;
            if(request.ext.jsonModelClass){
                respModel = [[request.ext.jsonModelClass alloc] initWithDictionary:responseObject error:nil];
            }else if(weakself.jsonModelClass){
                respModel = [[weakself.jsonModelClass alloc] initWithDictionary:responseObject error:nil];
            }
            request.ext.jsonSuccess(request, task, responseObject, respModel);
        }
        if(request.ext.success){
            request.ext.success(request,task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [manager.session finishTasksAndInvalidate];
        
        //判断能不能继续
        if([request.ext canSendRequest]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(weakself.globalRequestRetryInterceptor && !request.ext.disableRequestRetryInterceptor){
                    weakself.globalRequestRetryInterceptor(request);
                }
                [weakself sendRequest:request];
            });
            return;
        }
        //响应拦截器(全局)
        BOOL canContinue = YES;
        if(weakself.globalResponseFailureInterceptor && !request.ext.disableResponseFailureInterceptor){
            canContinue = weakself.globalResponseFailureInterceptor(request,task,nil,error);
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
