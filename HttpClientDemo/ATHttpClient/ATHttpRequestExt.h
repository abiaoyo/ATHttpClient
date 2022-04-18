#import <Foundation/Foundation.h>
#import "ATHttpClientDef.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpRequestExt : NSObject

@property (nonatomic,copy) NSString * name;
@property (nonatomic,assign) NSInteger tryTimes;
@property (nonatomic,assign) NSInteger tryCount;

@property (nonatomic,assign) BOOL disableSessionManagerInterceptor;
@property (nonatomic,assign) BOOL disableRequestInterceptor;
@property (nonatomic,assign) BOOL disableRequestRetryInterceptor;
@property (nonatomic,assign) BOOL disableResponseSuccessInterceptor;
@property (nonatomic,assign) BOOL disableResponseFailureInterceptor;

@property (nonatomic,copy) ATHttpSessionManagerInterceptor sessionManagerHandler;

@property (nonatomic,copy) ATHttpRequestSuccess success;
@property (nonatomic,copy) ATHttpRequestFailure failure;
@property (nonatomic,copy) ATHttpRequestJSONSuccess jsonSuccess;
@property (nonatomic,copy) ATHttpUploadProgress uploadProgress;
@property (nonatomic,copy) ATHttpDownloadProgress downloadProgress;

//JSONModel sub class
@property (nonatomic,strong) Class jsonModelClass;

- (BOOL)canSendRequest;
- (void)incrTryTimes;

@end

NS_ASSUME_NONNULL_END
