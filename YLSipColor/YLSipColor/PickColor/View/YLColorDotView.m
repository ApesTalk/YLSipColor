//
//  YLColorDotView.m
//  YLLoveMark
//
//  Created by lumin on 2017/12/24.
//  Copyright © 2017年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLColorDotView.h"

@implementation YLColorDotView

- (instancetype)init
{
    if(self = [super init]){
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:CGRectMake(0, 0, minDotSize, minDotSize)]){
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.frame = CGRectMake(0, 0, minDotSize, minDotSize);
    self.layer.cornerRadius = minDotSize * 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.f;
    self.layer.masksToBounds = YES;
}

- (void)showBigDotAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.25 : 0.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformMakeScale(2.f, 2.f);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resetAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.25 : 0.f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformMakeScale(1.f, 1.f);
    } completion:^(BOOL finished) {
        
    }];
}

@end
