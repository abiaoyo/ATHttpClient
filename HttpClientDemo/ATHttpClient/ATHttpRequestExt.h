#import <Foundation/Foundation.h>
#import "ATHttpClientDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpRequestExt : NSObject

@property (nonatomic,copy) NSString * name;
@property (nonatomic,assign) NSInteger tryTimes;
@property (nonatomic,assign) NSInteger tryCount;
@property (nonatomic,copy) ATHttpSessionManagerInterceptor sessionManagerInterceptor;
@property (nonatomic,copy) ATHttpRequestInterceptor requestInterceptor;
@property (nonatomic,copy) ATHttpResponseInterceptor responseInterceptor;
@property (nonatomic,copy) ATHttpSuccessInterceptor successInterceptor;
@property (nonatomic,copy) ATHttpFailureInterceptor failureInterceptor;

@end

NS_ASSUME_NONNULL_END
