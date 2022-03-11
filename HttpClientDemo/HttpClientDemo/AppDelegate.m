#import "AppDelegate.h"
#import "ATHttpClient.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [ATHttpClient startNetworkMonitoring:^(AFNetworkReachabilityStatus status) {
        ATHttpClientPrint(@"网络状态: %@",[ATHttpClient coverterNetworkStatus:status]);
    }];
    
    [ATHttpClient setGlobalRequestInterceptor:^(AFHTTPSessionManager * _Nonnull manager, ATHttpRequest * _Nonnull request) {
        [manager.requestSerializer setValue:@"123456789" forHTTPHeaderField:@"token"];
        ATHttpClientPrint(@"全局请求拦截器: %@\n.requestHeaders:%@\n",request.requestInfoExt,[manager.requestSerializer HTTPRequestHeaders]);
    }];
    [ATHttpClient setGlobalResponseInterceptor:^(ATHttpRequest * _Nonnull request,
                                                 NSURLSessionDataTask * _Nullable task,
                                                 id  _Nullable response,
                                                 NSError * _Nullable error) {
        NSDictionary * respHeader = ((NSHTTPURLResponse *)task.response).allHeaderFields;
        ATHttpClientPrint(@"全局响应拦截器: %@\n.responseHeaders: %@\n.response: %@\n",request.requestInfoExt,respHeader,response);
    }];
    [ATHttpClient setGlobalSuccessInterceptor:^(ATHttpRequest * _Nonnull request,
                                                NSURLSessionDataTask * _Nullable task,
                                                id  _Nullable response,
                                                ATHttpRequestSuccess  _Nullable success,
                                                ATHttpRequestFailure  _Nullable failure) {
//        NSLog(@"全局成功拦截器: %@\n",request.requestInfoExt);
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary * formatResponse = @{
            @"code":@(httpResponse.statusCode),
            @"message":@"",
            @"data":response
        };
        if(success){
            success(request,task,formatResponse);
        }
    }];
    [ATHttpClient setGlobalFailureInterceptor:^(ATHttpRequest * _Nonnull request,
                                                NSURLSessionDataTask * _Nullable task,
                                                NSError * _Nullable error,
                                                ATHttpRequestSuccess  _Nullable success,
                                                ATHttpRequestFailure  _Nullable failure) {
//        NSLog(@"全局失败拦截器: %@\n.error:%@\n",request.requestInfoExt,error.localizedDescription);
    }];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
