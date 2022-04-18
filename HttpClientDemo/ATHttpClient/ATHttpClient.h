#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ATHttpClientDef.h"
#import "ATHttpRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpClient : NSObject

@property (nonatomic,copy) ATHttpSessionManagerInterceptor globalSessionManagerInterceptor;
@property (nonatomic,copy) ATHttpRequestRetryInterceptor globalRequestRetryInterceptor;
@property (nonatomic,copy) ATHttpRequestInterceptor globalRequestInterceptor;
@property (nonatomic,copy) ATHttpResponseInterceptor globalResponseSuccessInterceptor;
@property (nonatomic,copy) ATHttpResponseInterceptor globalResponseFailureInterceptor;

@property (nonatomic,strong,readonly) ATHttpUrlManager * baseUrlsManager;
@property (nonatomic,assign,readonly) AFNetworkReachabilityStatus networkStatus;
@property (nonatomic,strong) Class jsonModelClass;//JSONModel sub class

- (void)startNetworkMonitoring:(void (^)(AFNetworkReachabilityStatus status))monitoringBlock;

- (NSURLSessionDataTask * _Nullable)sendRequest:(ATHttpRequest *)request;

+ (ATHttpClient *)client;


@end

NS_ASSUME_NONNULL_END
