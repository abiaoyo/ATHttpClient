#import "ATHttpRequest.h"
#import <objc/runtime.h>

@implementation ATHttpRequest

@end

@implementation ATHttpRequest(Ext)

+ (ATHttpRequest *)getRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodGet;
    request.retryTimes = 1;
    return request;
}

+ (ATHttpRequest *)postRequest{
    ATHttpRequest * request = [ATHttpRequest new];
    request.method = ATHttpMethodPost;
    request.retryTimes = 1;
    return request;
}

- (BOOL)canSendRequest{
    return self.retryTimes > 0;
}

- (void)reduceRetryTimes{
    self.retryTimes -= 1;
}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@%@",self.baseUrl,self.api];
}

- (NSString *)requestInfo{
    return [NSString stringWithFormat:@"请求信息: \n.name:%@\n.url:%@\n.headers:%@\n.params:%@",self.name,self.requestUrl,self.headers,self.params];
}

- (NSString *)name{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setName:(NSString *)name{
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)tag{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setTag:(NSString *)tag{
    objc_setAssociatedObject(self, @selector(tag), tag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)retryTimes{
    NSNumber * value = objc_getAssociatedObject(self, _cmd);
    return value.integerValue;
}
- (void)setRetryTimes:(NSInteger)retryTimes{
    objc_setAssociatedObject(self, @selector(retryTimes), @(retryTimes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
