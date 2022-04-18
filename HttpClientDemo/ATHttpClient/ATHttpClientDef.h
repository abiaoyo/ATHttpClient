#ifndef ATHttpClientDef_h
#define ATHttpClientDef_h

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <JSONModel/JSONModel.h>

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

//回调
@class ATHttpRequest;
typedef void (^ATHttpRequestSuccess)(ATHttpRequest * _Nonnull req,
                                     NSURLSessionDataTask * _Nullable task,
                                     id _Nullable resp);

typedef void (^ATHttpRequestJSONSuccess)(ATHttpRequest * _Nonnull req,
                                        NSURLSessionDataTask * _Nullable task,
                                         id _Nullable resp,
                                         JSONModel * _Nullable respModel);

typedef void (^ATHttpRequestFailure)(ATHttpRequest * _Nonnull req,
                                     NSURLSessionDataTask * _Nullable task,
                                     NSError * _Nullable error);

typedef void (^ATHttpUploadProgress)(NSProgress * _Nullable uploadProgress);
typedef void (^ATHttpDownloadProgress)(NSProgress * _Nullable downloadProgress);

//拦截
typedef AFHTTPSessionManager * _Nonnull (^ATHttpSessionManagerInterceptor)(AFHTTPSessionManager * _Nonnull manager,ATHttpRequest * _Nonnull req);

typedef void (^ATHttpRequestInterceptor)(AFHTTPSessionManager * _Nonnull manager,ATHttpRequest * _Nonnull req);

typedef BOOL (^ATHttpResponseInterceptor)(ATHttpRequest * _Nonnull req,NSURLSessionDataTask * _Nullable task,id _Nullable resp,NSError * _Nullable error);

typedef void (^ATHttpRequestRetryInterceptor)(ATHttpRequest * _Nonnull req);

#endif /* ATHttpClientDef_h */
