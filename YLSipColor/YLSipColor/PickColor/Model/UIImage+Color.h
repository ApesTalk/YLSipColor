//
//  UIImage+Color.h
//  YLLoveMark
//
//  Created by lumin on 2017/12/24.
//  Copyright © 2017年 https://github.com/lqcjdx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)
- (UIColor *)yl_colorAtPoint:(CGPoint)point;
- (UIImage *)yl_resizeToSize:(CGSize)size;

@end
