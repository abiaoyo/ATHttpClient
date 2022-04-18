#import "ViewController.h"
#import "ATHttpClient.h"

@interface TestJsonModel : JSONModel
@property (nonatomic,copy) NSString * info;
@property (nonatomic,assign) NSInteger infocode;
@property (nonatomic,copy) NSString * key;
@property (nonatomic,copy) NSString * sec_code;
@property (nonatomic,copy) NSString * sec_code_debug;
@property (nonatomic,assign) NSInteger status;
@end

@implementation TestJsonModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)clickButton1:(id)sender {
    ATHttpRequest * request = [ATHttpRequest getRequest];
//    request.baseUrl = @"https://www.tianqiapi.com";
    request.api = @"/api?version=v6&appid=21375891&appsecret=fTYv7v5E&city=%E5%8D%97%E4%BA%AC";
    request.ext.name = @"测试接口";
    
    request.ext.tryCount = 2;
    request.ext.jsonSuccess = ^(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, id  _Nullable resp, JSONModel * _Nullable respModel) {
        ATHttpClientPrint(@"请求成功回调: %@\n.response:%@\n",req.requestInfoExt,respModel);
    };
    
    request.ext.success = ^(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, id  _Nullable resp) {
        ATHttpClientPrint(@"请求成功回调: %@\n.response:%@\n",req.requestInfoExt,resp);
    };
    request.ext.failure = ^(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        ATHttpClientPrint(@"请求失败回调: %@\n.error:%@\n",req.requestInfoExt,error);
    };
    [ATHttpClient.client sendRequest:request];
}

- (IBAction)clickButton2:(id)sender {
    ATHttpRequest * request = [ATHttpRequest getRequest];
    request.baseUrl = @"https://restapi.amap.com";
    request.api = @"/v3/weather/weatherInfo?key=5d2d3e6c0d5188bec134fc4fc1b139e0&city=%E4%BB%99%E6%B8%B8&extensions=base";
    
    request.ext.name = @"登录接口";
    request.ext.disableRequestInterceptor = YES;
    request.ext.disableRequestRetryInterceptor = YES;
    request.ext.disableResponseSuccessInterceptor = YES;
    request.ext.disableResponseFailureInterceptor = YES;
    
    request.ext.success = ^(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, id  _Nullable resp) {
        ATHttpClientPrint(@"请求成功回调: %@\n.response:%@\n",req.requestInfoExt,resp);
    };
    request.ext.failure = ^(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        ATHttpClientPrint(@"请求失败回调: %@\n.error:%@\n",req.requestInfoExt,error);
    };
    //请求拦截器 - 会覆盖全局请求拦截器
    [ATHttpClient.client sendRequest:request];
}

- (IBAction)clickButton3:(id)sender {
    ATHttpRequest * request = [ATHttpRequest getRequest];
    request.baseUrl = @"https://restapi.amap.com";
    request.api = @"/v3/weather/weatherInfo?key=5d2d3e6c0d5188bec134fc4fc1b139e0&city=%E4%BB%99%E6%B8%B8&extensions=base";
    request.ext.name = @"登录接口";
    request.ext.jsonModelClass = TestJsonModel.class;
    request.ext.jsonSuccess = ^(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, id  _Nullable resp, JSONModel * _Nullable respModel) {
        ATHttpClientPrint(@"请求成功回调2: %@\n.response:%@\n",req.requestInfoExt,respModel);
    };
    request.ext.failure = ^(ATHttpRequest * _Nonnull req, NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        ATHttpClientPrint(@"请求失败回调: %@\n.error:%@\n",req.requestInfoExt, error);
    };
    
    [ATHttpClient.client sendRequest:request];
}


@end
