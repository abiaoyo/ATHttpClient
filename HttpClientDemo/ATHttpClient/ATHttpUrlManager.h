//
//  ATHttpUrlManager.h
//  HttpClientDemo
//
//  Created by abiaoyo on 2022/4/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATHttpUrlManager : NSObject

@property (nonatomic,copy,readonly) NSArray<NSString *> * urls;
@property (nonatomic,copy,readonly) NSString * _Nullable currentUrl;

- (void)addUrls:(NSArray<NSString *> *)urls;
- (void)removeUrls:(NSArray<NSString *> *)urls;
- (void)removeAllUrls;

- (void)prev;
- (void)next;
- (void)selectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
