//
//  Created by ldy on 15/10/22.
//  Copyright (c) 2015年 TalkNic. All rights reserved.
//
#import "DaView.h"

@implementation DaView
+ (instancetype)createInstance {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class)
                                         owner:self
                                       options:nil].lastObject;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
