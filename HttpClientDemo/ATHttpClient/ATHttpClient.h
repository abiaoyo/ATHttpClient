#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ATHttpClientDef.h"
#import "ATHttpRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpClient : NSObject

@property (nonatomic,copy,class,readwrite) ATHttpSessionManagerInterceptor globalSessionManagerInterceptor;
@property (nonatomic,copy,class,readwrite) ATHttpRequestRetryInterceptor globalRequestRetryInterceptor;
@property (nonatomic,copy,class,readwrite) ATHttpRequestInterceptor globalRequestInterceptor;
@property (nonatomic,copy,class,readwrite) ATHttpResponseInterceptor globalResponseSuccessInterceptor;
@property (nonatomic,copy,class,readwrite) ATHttpResponseInterceptor globalResponseFailureInterceptor;

@property (nonatomic,assign,class,readonly) AFNetworkReachabilityStatus networkStatus;

+ (void)startNetworkMonitoring:(void (^)(AFNetworkReachabilityStatus status))monitoringBlock;
+ (NSString *)networkStatusStr:(AFNetworkReachabilityStatus)status;

+ (NSURLSessionDataTask * _Nullable)sendRequest:(ATHttpRequest *)request;

@end

NS_ASSUME_NONNULL_END
