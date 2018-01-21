//
//  YLDashLine.h
//  YLLoveMark
//
//  Created by lumin on 2018/1/20.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//  虚线

#import <UIKit/UIKit.h>

@interface YLDashLine : UIView
@property (nonatomic, assign) CGFloat   lineWidth;  ///< 线条粗度
@property (nonatomic, strong) UIColor  *lineColor;  ///< 线条颜色
@property (nonatomic, copy) NSArray *lengths; ///< 绘制规则 ex:[@3, @3]绘制三个点，跳过三个点，默认[@2, @2]
@end
