#import "ATHttpRequestExt.h"

@implementation ATHttpRequestExt

- (BOOL)canSendRequest{
    return self.tryTimes < self.tryCount;
}

- (void)incrTryTimes{
    self.tryTimes += 1;
}

@end
