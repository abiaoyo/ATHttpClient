//
//  ATHttpUrlManager.m
//  HttpClientDemo
//
//  Created by abiaoyo on 2022/4/18.
//

#import "ATHttpUrlManager.h"

@interface ATHttpUrlManager()
@property (nonatomic,copy) NSMutableArray<NSString *> * mUrls;
@property (nonatomic,assign) NSInteger index;
@end

@implementation ATHttpUrlManager

- (void)addUrls:(NSArray<NSString *> *)urls{
    [self.mUrls addObjectsFromArray:urls];
}

- (void)removeUrls:(NSArray<NSString *> *)urls{
    [self.mUrls removeObjectsInArray:urls];
}

- (void)removeAllUrls{
    [self.mUrls removeAllObjects];
}

- (void)prev{
    NSInteger count = self.mUrls.count;
    self.index -= 1;
    if(self.index < 0){
        self.index = count-1;
    }
}

- (void)next{
    NSInteger count = self.mUrls.count;
    if(count > 0){
        self.index += 1;
        if(self.index >= count){
            self.index = 0;
        }
    }else{
        self.index = 0;
    }
}

- (void)selectIndex:(NSInteger)index{
    if(index >= 0 && index < self.mUrls.count){
        self.index = index;
    }
}

- (NSString *)currentUrl{
    if(self.index < self.mUrls.count){
        return self.mUrls[self.index];
    }
    return nil;
}

- (NSArray<NSString *> *)Urls{
    return [_mUrls copy];
}

- (NSMutableArray<NSString *> *)mUrls{
    if(!_mUrls){
        _mUrls = [NSMutableArray new];
    }
    return _mUrls;
}

@end
