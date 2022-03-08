#import <Foundation/Foundation.h>
#import "ATHttpClientDef.h"
#import "ATHttpRequestExt.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpRequest : NSObject

@property (nonatomic,assign) ATHttpMethod method;
@property (nonatomic,copy) NSString * baseUrl;
@property (nonatomic,copy) NSString * api;
@property (nonatomic,copy) NSDictionary * headers;
@property (nonatomic,copy) NSDictionary * params;
@property (nonatomic,strong,readonly) ATHttpRequestExt * ext;
@end

@interface ATHttpRequest(Ext)
+ (ATHttpRequest *)getRequest;
+ (ATHttpRequest *)postRequest;
+ (ATHttpRequest *)putRequest;
+ (ATHttpRequest *)deleteRequest;
+ (ATHttpRequest *)headRequest;
+ (ATHttpRequest *)patchRequest;

- (BOOL)canSendRequest;
- (void)incrTryTimes;

- (NSString *)requestUrl;
- (NSString *)methodName;
- (NSString *)requestInfo;
- (NSString *)requestInfoExt;

@end

NS_ASSUME_NONNULL_END
