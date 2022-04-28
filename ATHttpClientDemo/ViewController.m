//
//  ViewController.m
//  ATHttpClientDemo
//
//  Created by abiaoyo on 2022/4/26.
//

#import "ViewController.h"

@import ATHttpClient;

@interface ViewController ()
@property (nonatomic,weak) ATHttpTask * task;
@property (nonatomic,strong) ATHttpTaskBox * taskBox;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskBox = ATHttpTaskBox.new;
}
- (IBAction)clickButton:(id)sender {
    NSLog(@"self.task: %@",self.task);
    if(self.task){
        return;
    }
    ATHttpRequest * request = ATHttpRequest.get;
//    request.baseUrl = @"https://www.tianqiapi.com";
    request.api = @"/api?version=v6&appid=21375891&appsecret=fTYv7v5E&city=%E5%8D%97%E4%BA%AC";
    request.headers = @{@"time":@"1234",@"age":@"23"};
    request.params = @{@"city":@(1001)};
    request.ext.name = @"天气接口";
    
//    request.ext.disableRequestInterceptor = true;
//    request.ext.disableResponseSuccessInterceptor = true;
    
    request.success = ^(ATHttpRequest * _Nonnull request, NSDictionary<NSString *,id> * _Nullable response) {
        NSLog(@"request.ext.success: %@",response);
    };
    
    request.failure = ^(ATHttpRequest * _Nonnull request, NSError * _Nullable error) {
        NSLog(@"request.ext.failure");
    };
    
    request.ext.jsonModelClass = ATHttpJsonModel.class;
    request.ext.jsonModelSuccess = ^(ATHttpRequest * _Nonnull req, NSDictionary<NSString *,id> * _Nullable response, ATHttpJsonModel * _Nullable jsonModel) {
        NSLog(@"request.ext.jsonModelSuccess: %@",jsonModel);
    };
    self.task = [ATHttpClient.client sendRequest:request];
    
    
//    [[ATHttpClient.client download:request cachePath:@"" downloadProgress:^(NSProgress * _Nonnull progress) {
//
//    } success:^(NSURL * _Nonnull url) {
//
//    } failure:^(NSError * _Nullable error) {
//
//    }] addToTaskBox:self.taskBox];
    
//    [ATHttpClient.client upload:request data:NSData.new fileName:@"" type:ATHttpFileTypeImage success:^(NSDictionary<NSString *,id> * _Nullable response) {
//
//    } failure:^(NSError * _Nullable error) {
//
//    }];
}


@end
