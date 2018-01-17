//
//  YLColorDotView.h
//  YLLoveMark
//
//  Created by lumin on 2017/12/24.
//  Copyright © 2017年 https://github.com/lqcjdx. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat minDotSize = 45.f;

@interface YLColorDotView : UIView

- (void)showBigDotAnimated:(BOOL)animated;
- (void)resetAnimated:(BOOL)animated;

@end
