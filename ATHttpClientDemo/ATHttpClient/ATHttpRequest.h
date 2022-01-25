#import <Foundation/Foundation.h>
#import "ATHttpClientDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpRequest : NSObject

@property (nonatomic,assign) ATHttpMethod method;
@property (nonatomic,copy) NSString * baseUrl;
@property (nonatomic,copy) NSString * api;
@property (nonatomic,copy) NSDictionary * headers;
@property (nonatomic,copy) NSDictionary * params;

@end

@interface ATHttpRequest(Ext)
+ (ATHttpRequest *)getRequest;
+ (ATHttpRequest *)postRequest;

- (BOOL)canSendRequest;
- (void)reduceRetryTimes;
- (NSString *)requestUrl;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * tag;
@property (nonatomic,assign) NSInteger retryTimes; //默认为1，当为<=0时，将不会发起网络
@property (nonatomic,copy) ATHttpSessionManagerInterceptor sessionManagerInterceptor;
@property (nonatomic,copy) ATHttpRequestInterceptor requestInterceptor;
@property (nonatomic,copy) ATHttpSuccessInterceptor successInterceptor;
@property (nonatomic,copy) ATHttpFailureInterceptor failureInterceptor;
@end

NS_ASSUME_NONNULL_END
