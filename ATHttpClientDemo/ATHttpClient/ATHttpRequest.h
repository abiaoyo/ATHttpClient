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
- (void)incrTryTimes;
- (NSString *)requestUrl;
- (NSString *)requestInfo;
- (NSString *)requestInfoExt;
- (NSString *)methodName;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,assign) NSInteger tryTimes;
@property (nonatomic,assign) NSInteger tryCount;
@property (nonatomic,copy) ATHttpSessionManagerInterceptor sessionManagerInterceptor;
@property (nonatomic,copy) ATHttpRequestInterceptor requestInterceptor;
@property (nonatomic,copy) ATHttpSuccessInterceptor successInterceptor;
@property (nonatomic,copy) ATHttpFailureInterceptor failureInterceptor;
@end

NS_ASSUME_NONNULL_END
