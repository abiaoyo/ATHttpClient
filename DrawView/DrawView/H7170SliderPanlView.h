//
//  H7170SliderPanlView.h
//  DrawView
//
//  Created by abiaoyo on 2022/1/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface H7170SliderPanlView : UIControl
@property (nonatomic,strong,readonly) CAShapeLayer * strokeLayer;
@property (nonatomic,strong,readonly) CAShapeLayer * trackLayer;

@property (nonatomic,strong,readonly) UIImageView * targetView;

@property (nonatomic,assign,readonly) CGFloat minValue;
@property (nonatomic,assign,readonly) CGFloat maxValue;
@property (nonatomic,assign,readonly) CGFloat targetValue;

@property (nonatomic,assign) CGSize touchPointSize;

@property (nonatomic,copy) void (^onValueDidChangeBlock)(CGFloat targetValue);
@property (nonatomic,copy) void (^onBeginTouchTargetView)(void);
@property (nonatomic,copy) void (^onMoveTouchTargetView)(void);
@property (nonatomic,copy) void (^onEndTouchTargetView)(void);

- (instancetype)initWithFrame:(CGRect)frame
                       radius:(CGFloat)radius
                    lineWidth:(CGFloat)lineWidth
                     minValue:(CGFloat)minValue
                     maxValue:(CGFloat)maxValue;

- (void)updateProgress:(CGFloat)progress;

- (void)updateMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue;

- (void)updateTargetValue:(CGFloat)targetValue;

@end

NS_ASSUME_NONNULL_END
