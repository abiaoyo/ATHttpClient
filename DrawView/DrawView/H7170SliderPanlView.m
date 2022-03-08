//
//  H7170TemInfoPanlView.m
//  DrawView
//
//  Created by abiaoyo on 2022/1/26.
//

#import "H7170TemInfoPanlView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 360.0 * 2*M_PI)

@interface H7170TemInfoPanlView()
@property (nonatomic,strong) UIView * contentView;
@property (nonatomic,strong) UIImageView * targetView;

@property (nonatomic,strong) CAShapeLayer * strokeLayer;
@property (nonatomic,strong) CAShapeLayer * trackLayer;

@property (nonatomic,assign) CGFloat radius;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,assign) CGFloat minValue;
@property (nonatomic,assign) CGFloat maxValue;
@property (nonatomic,assign) CGFloat targetValue;

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,assign) CGPoint trackLeftPoint;
@property (nonatomic,assign) CGPoint trackRightPoint;

@end

@implementation H7170TemInfoPanlView

- (instancetype)initWithFrame:(CGRect)frame
                       radius:(CGFloat)radius
                    lineWidth:(CGFloat)lineWidth
                     minValue:(CGFloat)minValue
                     maxValue:(CGFloat)maxValue{
    self = [super initWithFrame:frame];
    if (self) {
        self.radius = radius;
        self.lineWidth = lineWidth;
        self.minValue = minValue;
        self.maxValue = maxValue;
        [self setupSubviews];
    }
    return self;
}

- (void)setupData{
    self.touchPointSize = CGSizeMake(42.5, 42.5);
}

- (void)setupSubviews{
    self.contentView = [[UIView alloc] init];
    self.contentView.userInteractionEnabled = NO;
    [self addSubview:self.contentView];
    
    self.trackLayer = [CAShapeLayer layer];
    self.trackLayer.lineWidth = self.lineWidth;
    self.trackLayer.fillColor = UIColor.clearColor.CGColor;
    self.trackLayer.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25].CGColor;
    [self.contentView.layer addSublayer:self.trackLayer];
    
    self.strokeLayer = [CAShapeLayer layer];
    self.strokeLayer.lineWidth = self.lineWidth;
    self.strokeLayer.fillColor = UIColor.clearColor.CGColor;
    self.strokeLayer.strokeColor = UIColor.whiteColor.CGColor;
    [self.contentView.layer addSublayer:self.strokeLayer];
    
    self.targetView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.targetView.image = [UIImage imageNamed:@"new_h7170_pics_slider"];
    [self.contentView addSubview:self.targetView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    
    self.targetView.bounds = self.bounds;
    self.targetView.center = self.contentView.center;
    
    self.trackLayer.frame = self.bounds;
    self.strokeLayer.frame = self.bounds;
    
    [self updateTrackViewWithProgress:1.0];
    [self updateProgress:self.progress];
    
    NSMutableArray<NSValue *> * bezierPoints = [NSMutableArray array];
    CGPathApply(self.trackLayer.path, (__bridge void * _Nullable)(bezierPoints), TEMGetCGPathApplierFunc);
    self.trackLeftPoint = [bezierPoints.firstObject CGPointValue];
    self.trackRightPoint = [bezierPoints.lastObject CGPointValue];
    
    [self updateTargetValue:self.targetValue];
}

- (void)updateTrackViewWithProgress:(CGFloat)progress{
    UIBezierPath * path = [UIBezierPath bezierPath];
    CGFloat startAngle = M_PI*0.75;
    CGFloat endAngle = M_PI*0.75+(M_PI*1.5)*progress;
    [path addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0) radius:self.radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.trackLayer.path = path.CGPath;
}

- (void)updateStrokeViewWithProgress:(CGFloat)progress{
    UIBezierPath * path = [UIBezierPath bezierPath];
    CGFloat startAngle = M_PI*0.75;
    CGFloat endAngle = M_PI*0.75+(M_PI*1.5)*progress;
    [path addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0) radius:self.radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.strokeLayer.path = path.CGPath;
}

- (void)updateProgress:(CGFloat)progress{
    self.progress = progress;
    [self updateStrokeViewWithProgress:progress];
}

- (void)updateMinValue:(CGFloat)minValue maxValue:(CGFloat)maxValue{
    self.minValue = minValue;
    self.maxValue = maxValue;
    [self updateTargetValue:self.targetValue];
}

- (void)updateTargetValue:(CGFloat)targetValue{
    if(targetValue < self.minValue){
        targetValue = self.minValue;
    }
    if(targetValue > self.maxValue){
        targetValue = self.maxValue;
    }
    self.targetValue = targetValue;
    
    CGFloat angle = self.targetValue/(self.maxValue-self.minValue)*270.0;
    if(angle > 180){
        angle = -180+angle-180;
    }
    [self refreshTargetView:angle];
}



void TEMGetCGPathApplierFunc (void *info, const CGPathElement *element) {
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
        case kCGPathElementAddLineToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            break;
        case kCGPathElementAddCurveToPoint: // contains 3 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[2]]];
            break;
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}


//MARK: Method
- (double)distanceBetweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB {
    double x = fabs(pointA.x - pointB.x);
    double y = fabs(pointA.y - pointB.y);
    return hypot(x, y);//hypot(x, y)函数为计算三角形的斜边长度
}

- (CGFloat)getAngle:(CGPoint)oriPoint pt1:(CGPoint)pt1 pt2:(CGPoint)pt2{
    double ma_x = pt1.x - oriPoint.x;
    double ma_y = pt1.y - oriPoint.y;
    double mb_x = pt2.x - oriPoint.x;
    double mb_y = pt2.y - oriPoint.y;
    double k = (ma_x * mb_y - mb_x * ma_y);
    
    if (k != 0) {
        k = (k / sqrtf(k*k));
    } else {
        k = 1;
    }
    
    double v1 = (ma_x * mb_x) + (ma_y * mb_y);
    double ma_val = sqrtf(ma_x * ma_x + ma_y * ma_y);
    double mb_val = sqrtf(mb_x * mb_x + mb_y * mb_y);
    double cosM = v1 / (ma_val * mb_val);
    
    return (float) (acos(cosM) * 180 / M_PI * k);
}

- (CGFloat)adjustRangeWithAngle:(CGFloat)angle{
    if(angle > -10 && angle < 0){
        angle = 0;
    }
    if(angle > -90 && angle < -80){
        angle = -90;
    }
    return angle;
}

//MARK: Handle
- (void)handlerWithPoint:(CGPoint)point isEnd:(BOOL)isEnd{
    CGFloat angle = [self getAngle:self.contentView.center pt1:self.trackLeftPoint pt2:point];
    [self refreshTargetView:angle];
    
    angle = [self adjustRangeWithAngle:angle];
    
    CGFloat value = 0;
    if(angle >= 0 && angle <= 180){
        CGFloat p = (angle/270.0);
        value = p*(self.maxValue-self.minValue);
    }else{
        if(angle >= -180 && angle <= -90){
            CGFloat p = (180+angle+180)/270.0;
            value = p*(self.maxValue-self.minValue);
        }
    }
    self.targetValue = value;
    
    if(isEnd){
        if(self.onValueDidChangeBlock){
            self.onValueDidChangeBlock(value);
        }
    }
}

- (BOOL)canBeginTouchWithPoint:(CGPoint)point{
    double distance = [self distanceBetweenPointA:point pointB:self.contentView.center];
    BOOL inRadisRange = distance > (self.radius-self.touchPointSize.width/2.0) && distance < (self.radius+self.touchPointSize.width/2.0);
    
    CGFloat minX = self.trackLeftPoint.x+self.touchPointSize.width/2.0;
    CGFloat minY = self.trackLeftPoint.y-self.touchPointSize.width/2.0;
    
    CGFloat width = self.trackRightPoint.x - self.touchPointSize.width/2.0-minX;
    CGFloat height = self.trackRightPoint.y + self.touchPointSize.width/2.0-minY;
    
    CGRect bottomRect = CGRectMake(minX, minY, width, height);
    BOOL inBottomRange = CGRectContainsPoint(bottomRect, point);
    
    if(inRadisRange){
        if(!inBottomRange){
            return YES;
        }
    }
    return NO;
}

//MARK: Refresh
- (void)refreshTargetView:(CGFloat)angle{
    angle = [self adjustRangeWithAngle:angle];
    if(!(angle <= -10 && angle >= -80)){
        CGFloat _angle = DEGREES_TO_RADIANS(angle);
        self.targetView.transform = CGAffineTransformMakeRotation(_angle);
    }
}

#pragma mark - UIControl methods
//点击开始
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    BOOL canBeginTouch = [self canBeginTouchWithPoint:point];
    if(canBeginTouch){
        [self handlerWithPoint:point isEnd:NO];
        if(self.onBeginTouchTargetView){
            self.onBeginTouchTargetView();
        }
    }
    return canBeginTouch;
}

//拖动过程中
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    [self handlerWithPoint:point isEnd:NO];
    if(self.onMoveTouchTargetView){
        self.onMoveTouchTargetView();
    }
    return YES;
}

//拖动结束
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    [self handlerWithPoint:point isEnd:YES];
    if(self.onEndTouchTargetView){
        self.onEndTouchTargetView();
    }
}


@end
