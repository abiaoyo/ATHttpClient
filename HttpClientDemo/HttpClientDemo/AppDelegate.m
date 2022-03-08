//
//  AppDelegate.m
//  HttpClientDemo
//
//  Created by 李叶彪 on 2022/3/8.
//

#import "AppDelegate.h"
#import "ATHttpClient.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [ATHttpClient startNetworkMonitoring:^(AFNetworkReachabilityStatus status) {
        NSLog(@"网络状态: %@",[ATHttpClient coverterNetworkStatus:status]);
    }];
    
    [ATHttpClient setGlobalRequestInterceptor:^(ATHttpRequest * _Nonnull request) {
        NSLog(@"全局请求拦截器: %@\n",request.requestInfoExt);
    }];
    [ATHttpClient setGlobalSuccessInterceptor:^(ATHttpRequest * _Nonnull request,
                                                NSURLSessionDataTask * _Nullable task,
                                                id  _Nullable response,
                                                ATHttpRequestSuccess  _Nullable success,
                                                ATHttpRequestFailure  _Nullable failure) {
        NSLog(@"全局响应拦截器: %@\n.response: %@\n",request.requestInfoExt,response);
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary * formatResponse = @{
            @"statusCode":@(httpResponse.statusCode),
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
                                                ATHttpUploadProgress  _Nullable uploadProgress,
                                                ATHttpDownloadProgress  _Nullable downloadProgress,
                                                ATHttpRequestSuccess  _Nullable success,
                                                ATHttpRequestFailure  _Nullable failure) {
        NSLog(@"全局异常拦截器: %@\n.error:%@\n",request.requestInfoExt,error.localizedDescription);
        if([request canSendRequest]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ATHttpClient sendRequest:request
                           uploadProgress:uploadProgress
                         downloadProgress:downloadProgress
                                  success:success
                                  failure:failure];
            });
        }else{
            if(failure){
                failure(request,task,error);
            }
        }
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
