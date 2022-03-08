//
//  AppDelegate.m
//  ATHttpClientDemo
//
//  Created by abiaoyo on 2022/1/25.
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
        NSLog(@"全局响应拦截器: %@\n.response:%@\n",request.requestInfoExt,response);
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

@end
