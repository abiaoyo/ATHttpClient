#import "ATHttpRequest.h"
#import <objc/runtime.h>

@interface ATHttpRequest()
@property (nonatomic,strong) ATHttpRequestExt * ext;
@end

@implementation ATHttpRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ext = [ATHttpRequestExt new];
        self.headers = @{};
        self.params = @{};
    }
    return self;
}
@end

@implementation ATHttpRequest(Ext)

+ (ATHttpRequest *)getRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodGet;
    request.ext.tryCount = 1;
    return request;
}

+ (ATHttpRequest *)postRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodPost;
    request.ext.tryCount = 1;
    return request;
}

+ (ATHttpRequest *)putRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodPut;
    request.ext.tryCount = 1;
    return request;
}
+ (ATHttpRequest *)deleteRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodDelete;
    request.ext.tryCount = 1;
    return request;
}
+ (ATHttpRequest *)headRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodHead;
    request.ext.tryCount = 1;
    return request;
}
+ (ATHttpRequest *)patchRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodPatch;
    request.ext.tryCount = 1;
    return request;
}


- (BOOL)canSendRequest{
    return self.ext.tryTimes < self.ext.tryCount;
}

- (void)incrTryTimes{
    self.ext.tryTimes += 1;
}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@%@",self.safeBaseUrl,self.safeApi];
}

- (NSString *)requestMethod{
    switch (self.method) {
        case ATHttpMethodPost:{
            return @"POST";
        }
            break;
        case ATHttpMethodPut:{
            return @"PUT";
        }
            break;
        case ATHttpMethodDelete:{
            return @"DELETE";
        }
            break;
        case ATHttpMethodHead:{
            return @"HEAD";
        }
            break;
        case ATHttpMethodPatch:{
            return @"PATCH";
        }
            break;
        case ATHttpMethodGet:
        default:
            return @"GET";
            break;
    }
}

- (NSString *)safeBaseUrl{
    if(self.baseUrl){
        return self.baseUrl;
    }
    return @"";
}

- (NSString *)safeApi{
    if(self.api){
        return self.api;
    }
    return @"";
}

- (NSString *)requestInfo{
    return [NSString stringWithFormat:@"\n.baseUrl = %@\n.api = %@\n.method = %@\n.headers = %@\n.params = %@",self.safeBaseUrl,self.safeApi,self.requestMethod,self.headers,self.params];
}

- (NSString *)requestInfoExt{
    return [NSString stringWithFormat:@" \n.name = %@\n.tryTimes = %@\n.tryCount = %@\n.baseUrl = %@\n.api = %@\n.method = %@\n.headers = %@\n.params = %@",self.ext.name,@(self.ext.tryTimes),@(self.ext.tryCount),self.safeBaseUrl,self.safeApi,self.requestMethod,self.headers,self.params];
}


@end
