#import "AppDelegate.h"
#import "ATHttpClient.h"

@interface API_ResponseModel : JSONModel
@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString * message;
@property (nonatomic,copy) NSDictionary * data;
@property (nonatomic,copy) NSString * info;
@end

@implementation API_ResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BOOL b = [API_ResponseModel.class isKindOfClass:JSONModel.class];
    BOOL b2 = [API_ResponseModel.class isMemberOfClass:JSONModel.class];
    BOOL b3 = [API_ResponseModel.class isEqual:JSONModel.class];
    
    
    NSLog(@"b:%@  b2:%@ b3:%@",@(b),@(b2),@(b3));
    
    [ATHttpClient startNetworkMonitoring:^(AFNetworkReachabilityStatus status) {
        ATHttpClientPrint(@"网络状态: %@",[ATHttpClient networkStatusStr:status]);
    }];
    
    //设置json默认类型
    [ATHttpClient setJsonModelClass:API_ResponseModel.class];
    
    //这里处理manager
    [ATHttpClient setGlobalSessionManagerInterceptor:^AFHTTPSessionManager * _Nonnull(AFHTTPSessionManager * _Nonnull manager, ATHttpRequest * _Nonnull req) {
        NSLog(@"global session manager 拦截");
        return manager;
    }];
    
    //全局请求拦截器 - 这里可以处理请求头加字段（权限，信息等），可以用于处理请求日志
    [ATHttpClient setGlobalRequestInterceptor:^(AFHTTPSessionManager * _Nonnull manager, ATHttpRequest * _Nonnull req) {
        [manager.requestSerializer setValue:@"123456789" forHTTPHeaderField:@"token"];
        ATHttpClientPrint(@"全局请求拦截器: %@\n.reqHeaders:%@\n",req.requestInfoExt,[manager.requestSerializer HTTPRequestHeaders]);
    }];
    //全局请求即将重试拦截器 - 这里可以用于处理切换服务器地址
    [ATHttpClient setGlobalRequestRetryInterceptor:^(ATHttpRequest * _Nonnull req) {
        if([req.baseUrl isEqualToString:@"https://www.tianqiapi.com"]){
            req.baseUrl = @"https://www.tianqiapi_h222.com";
        }
    }];
    //全局响应拦截器 - 这里可以用于处理响应日志，登录权限判断等
    //return : 返回能不能继续，  NO:表示不能继续请求逻辑   YES:表示继续请求逻辑;  例：如果登录 token 失效，则 return NO;
    [ATHttpClient setGlobalResponseSuccessInterceptor:^BOOL(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, id  _Nullable resp, NSError * _Nullable error) {
        NSDictionary * respHeader = ((NSHTTPURLResponse *)task.response).allHeaderFields;
        ATHttpClientPrint(@"success 全局响应拦截器: %@\n.reqHeaders:%@\n.respHeaders: %@\n.response: %@\n",req.requestInfoExt,task.currentRequest.allHTTPHeaderFields,respHeader,resp);
        return YES;
    }];
    [ATHttpClient setGlobalResponseFailureInterceptor:^BOOL(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, id  _Nullable resp, NSError * _Nullable error) {
        NSDictionary * respHeader = ((NSHTTPURLResponse *)task.response).allHeaderFields;
        ATHttpClientPrint(@"全局响应拦截器: %@\n.reqHeaders:%@\n.respHeaders: %@\n.response: %@\n",req.requestInfoExt,task.currentRequest.allHTTPHeaderFields,respHeader,resp);
        return YES;
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
