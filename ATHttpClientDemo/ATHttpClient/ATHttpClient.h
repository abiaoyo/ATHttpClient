#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ATHttpClientDefine.h"
#import "ATHttpRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpClient : NSObject

@property (nonatomic,copy,class,readwrite) ATHttpSessionManagerInterceptor globalSessionManagerInterceptor;
@property (nonatomic,copy,class,readwrite) ATHttpRequestInterceptor globalRequestInterceptor;
@property (nonatomic,copy,class,readwrite) ATHttpSuccessInterceptor globalSuccessInterceptor;
@property (nonatomic,copy,class,readwrite) ATHttpFailureInterceptor globalFailureInterceptor;

+ (void)startNetworkMonitoring:(void (^)(AFNetworkReachabilityStatus status))monitoringBlock;
+ (NSString *)coverterNetworkStatus:(AFNetworkReachabilityStatus)status;
+ (AFNetworkReachabilityStatus)networkStatus;

+ (NSURLSessionDataTask * _Nullable)sendRequest:(ATHttpRequest *)reqeust
                                        success:(ATHttpRequestSuccess _Nullable)success
                                        failure:(ATHttpRequestFailure _Nullable)failure;

+ (NSURLSessionDataTask * _Nullable)sendRequest:(ATHttpRequest *)reqeust
                                 uploadProgress:(ATHttpUploadProgress _Nullable)uploadProgress
                               downloadProgress:(ATHttpDownloadProgress _Nullable)downloadProgress
                                        success:(ATHttpRequestSuccess _Nullable)success
                                        failure:(ATHttpRequestFailure _Nullable)failure;

@end

NS_ASSUME_NONNULL_END
