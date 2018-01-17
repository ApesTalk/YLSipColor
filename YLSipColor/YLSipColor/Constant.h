//
//  Constant.h
//  YLSipColor
//
//  Created by lumin on 2018/1/14.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kIsIphoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define kStatusBarHeight (kIsIphoneX ? (20.f + 24.f) : 20.f)
#define kNavigatonBarHeight 44.f
#define kStatusAndNavigationBarHeight (kStatusBarHeight + kNavigatonBarHeight)
#define kTabBarHeight (kIsIphoneX ? (49.f + 34.f) : 49.f)
#define kHomeIndicatorHeight (kIsIphoneX ? 34.f : 0.f)

#endif /* Constant_h */
