#ifndef ATHttpClientDef_h
#define ATHttpClientDef_h

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#ifdef DEBUG
#define ATHttpClientPrint(format, ...) printf("-- (ATHttpClientPrint🍄) %s:(%d) --   %s\n\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define ATHttpClientPrint(format, ...)
#endif

typedef NS_ENUM(NSInteger,ATHttpMethod){
    ATHttpMethodGet = 0,
    ATHttpMethodPost,
    ATHttpMethodPut,
    ATHttpMethodDelete,
    ATHttpMethodHead,
    ATHttpMethodPatch
};

@class ATHttpRequest;
typedef void (^ATHttpRequestSuccess)(ATHttpRequest * _Nonnull request,
                                     NSURLSessionDataTask * _Nullable task,
                                     id _Nullable response);

typedef void (^ATHttpRequestFailure)(ATHttpRequest * _Nonnull request,
                                     NSURLSessionDataTask * _Nullable task,
                                     NSError * _Nullable error);

typedef void (^ATHttpUploadProgress)(NSProgress * _Nullable uploadProgress);
typedef void (^ATHttpDownloadProgress)(NSProgress * _Nullable downloadProgress);
typedef AFHTTPSessionManager * _Nonnull (^ATHttpSessionManagerInterceptor)(AFHTTPSessionManager * _Nonnull manager, ATHttpRequest * _Nonnull request);
typedef void (^ATHttpRequestInterceptor)(AFHTTPSessionManager * _Nonnull manager,
                                         ATHttpRequest * _Nonnull request);
typedef void (^ATHttpResponseInterceptor)(ATHttpRequest * _Nonnull request,
                                          NSURLSessionDataTask * _Nullable task,
                                          id _Nullable response,
                                          BOOL reqSuccess,
                                          NSError * _Nullable error);
typedef void (^ATHttpRequestRetryInterceptor)(ATHttpRequest * _Nonnull request);

typedef void (^ATHttpSuccessInterceptor)(ATHttpRequest * _Nonnull request,
                                         NSURLSessionDataTask * _Nullable task,
                                         id _Nullable response,
                                         ATHttpRequestSuccess _Nullable success,
                                         ATHttpRequestFailure _Nullable failure);

typedef void (^ATHttpFailureInterceptor)(ATHttpRequest * _Nonnull request,
                                         NSURLSessionDataTask * _Nullable task,
                                         NSError * _Nullable error,
                                         ATHttpRequestSuccess _Nullable success,
                                         ATHttpRequestFailure _Nullable failure);

#endif /* ATHttpClientDef_h */
