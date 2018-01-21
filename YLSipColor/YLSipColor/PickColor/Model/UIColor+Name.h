//
//  UIColor+Name.h
//  YLSipColor
//
//  Created by lumin on 2018/1/21.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Name)
- (NSString *)yl_hexName;///< 返回十六进制名称 ex: #666666
- (NSString *)yl_commonName;///< 返回颜色名称  ex: Grey

@end
