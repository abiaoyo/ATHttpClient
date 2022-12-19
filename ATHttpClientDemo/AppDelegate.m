//
//  AppDelegate.m
//  ATHttpClientDemo
//
//  Created by abiaoyo on 2022/4/26.
//

#import "AppDelegate.h"

@import ATHttpClient;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [ATHttpClient initNetworkListening:^(enum ATHttpNetworkStatus status) {
        NSLog(@"### 网络状态: %@",@(status));
    }];
    
    [ATHttpClient.client.baseUrlsPool add:@[@"https://www.tianqiapi.com"]];
    
    ATHttpClient.client.requestInterceptor = ^(ATHttpRequest * _Nonnull req) {
        NSLog(@"### 请求拦截");
        [req setHeader:@"1234567" forKey:@"token"];
        [req setHeader:@"zhangsan" forKey:@"username"];
        NSLog(@"请求信息: %@",req.desc1);
    };
    ATHttpClient.client.retryRequestInterceptor = ^(ATHttpRequest * _Nonnull req) {
        NSLog(@"### 请求重试拦截");
        [ATHttpClient.client.baseUrlsPool next];
    };
    
    ATHttpClient.client.responseSuccessInterceptor = ^NSError * _Nullable(ATHttpRequest * _Nonnull req, NSDictionary<NSString *,id> * _Nullable response) {
        NSLog(@"### 响应成功拦截");
        NSLog(@"### request.headers: %@", req.ext.requestHeaders);
        NSLog(@"### response.headers: %@", req.ext.responseHeaders);
        return nil;
    };
    ATHttpClient.client.responseFailureInterceptor = ^NSError * _Nullable(ATHttpRequest * _Nonnull req, NSError * _Nonnull error) {
        NSLog(@"### 响应失败拦截");
        NSLog(@"### request.error: %@", error);
        NSLog(@"### request.headers: %@", req.ext.requestHeaders);
        NSLog(@"### response.headers: %@", req.ext.responseHeaders);
        return error;
    };
    
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
