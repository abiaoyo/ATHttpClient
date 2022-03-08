//
//  ViewController.m
//  ATATHttpClientDemo
//
//  Created by abiaoyo on 2022/1/25.
//

#import "ViewController.h"
#import "ATHttpClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)clickButton1:(id)sender {
    ATHttpRequest * request = [ATHttpRequest getRequest];
    request.baseUrl = @"https://www.tianqiapi.com";
    request.api = @"/api?version=v6&appid=21375891&appsecret=fTYv7v5E&city=%E5%8D%97%E4%BA%AC";
    request.headers = @{};
    request.params = @{};
    request.name = @"测试接口";
    request.retryTimes = 2;
    request.successInterceptor = ^(ATHttpRequest * _Nonnull request,
                                   NSURLSessionDataTask * _Nullable task,
                                   id  _Nullable response,
                                   ATHttpRequestSuccess  _Nullable success,
                                   ATHttpRequestFailure  _Nullable failure) {
        
        NSLog(@"拦截器 响应: \n.url:%@\n",request.requestUrl);
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary * formatResponse = @{
            @"status":@(httpResponse.statusCode),
            @"message":@"",
            @"data":response
        };
        if(success){
            success(request,task,formatResponse);
        }
    };
    
    [ATHttpClient sendRequest:request success:^(ATHttpRequest * _Nonnull request,
                                                NSURLSessionDataTask * _Nonnull task,
                                                id  _Nullable response) {
        
    } failure:^(ATHttpRequest * _Nonnull request, NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (IBAction)clickButton2:(id)sender {
    ATHttpRequest * request = [ATHttpRequest getRequest];
    request.baseUrl = @"https://restapi.amap.com";
    request.api = @"/v3/weather/weatherInfo?key=5d2d3e6c0d5188bec134fc4fc1b139e0&city=%E4%BB%99%E6%B8%B8&extensions=base";
    request.headers = @{};
    request.params = @{};
    request.name = @"登录接口";
    request.requestInterceptor = ^(ATHttpRequest * _Nonnull request) {
        //登录接口比较特殊，不需要token，所以自定义请求拦截器为空实现即可
        NSLog(@"自定义拦截器: %@",request.requestInfo);
    };
    [ATHttpClient sendRequest:request success:^(ATHttpRequest * _Nonnull request,
                                                NSURLSessionDataTask * _Nonnull task,
                                                id  _Nonnull response) {
        
    } failure:^(ATHttpRequest * _Nonnull request,
                NSURLSessionDataTask * _Nullable task,
                NSError * _Nonnull error) {
        
    }];
}

- (IBAction)clickButton3:(id)sender {
    
}


@end
