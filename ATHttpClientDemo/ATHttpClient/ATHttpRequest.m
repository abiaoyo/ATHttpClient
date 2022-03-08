#import "ATHttpRequest.h"
#import <objc/runtime.h>

@implementation ATHttpRequest

@end

@implementation ATHttpRequest(Ext)

+ (ATHttpRequest *)getRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodGet;
    request.tryCount = 1;
    return request;
}

+ (ATHttpRequest *)postRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodPost;
    request.tryCount = 1;
    return request;
}

- (BOOL)canSendRequest{
    return self.tryTimes < self.tryCount;
}

- (void)incrTryTimes{
    self.tryTimes += 1;
}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@%@",self.baseUrl,self.api];
}

- (NSString *)requestInfo{
    return [NSString stringWithFormat:@"\n.url:%@\n.method:%@\n.headers:%@\n.params:%@",self.requestUrl,self.methodName,self.headers,self.params];
}

- (NSString *)requestInfoExt{
    return [NSString stringWithFormat:@" \n.name:%@\n.retryTimes:%@\n.tryCount:%@\n.url:%@\n.method:%@\n.headers:%@\n.params:%@",self.name,@(self.tryTimes),@(self.tryCount),self.requestUrl,self.methodName,self.headers,self.params];
}

- (NSString *)methodName{
    switch (self.method) {
        case ATHttpMethodGet:{
            return @"GET";
        }
            break;
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
            
        default:
            break;
    }
    return @"";
}

- (NSString *)name{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setName:(NSString *)name{
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)tryTimes{
    NSNumber * value = objc_getAssociatedObject(self, _cmd);
    return value.integerValue;
}
- (void)setTryTimes:(NSInteger)tryTimes{
    objc_setAssociatedObject(self, @selector(tryTimes), @(tryTimes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tryCount{
    NSNumber * value = objc_getAssociatedObject(self, _cmd);
    return value.integerValue;
}
- (void)setTryCount:(NSInteger)tryCount{
    objc_setAssociatedObject(self, @selector(tryCount), @(tryCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ATHttpSessionManagerInterceptor)sessionManagerInterceptor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setSessionManagerInterceptor:(ATHttpSessionManagerInterceptor)sessionManagerInterceptor{
    objc_setAssociatedObject(self, @selector(sessionManagerInterceptor), sessionManagerInterceptor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ATHttpRequestInterceptor)requestInterceptor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setRequestInterceptor:(ATHttpRequestInterceptor)requestInterceptor{
    objc_setAssociatedObject(self, @selector(requestInterceptor), requestInterceptor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ATHttpSuccessInterceptor)successInterceptor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setSuccessInterceptor:(ATHttpSuccessInterceptor)successInterceptor{
    objc_setAssociatedObject(self, @selector(successInterceptor), successInterceptor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ATHttpFailureInterceptor)failureInterceptor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFailureInterceptor:(ATHttpFailureInterceptor)failureInterceptor{
    objc_setAssociatedObject(self, @selector(failureInterceptor), failureInterceptor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


@end
