//
//  YLDashLine.m
//  YLLoveMark
//
//  Created by lumin on 2018/1/20.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLDashLine.h"

#define  kDefalutDashLineWidth 0.5
#define  kDefaultDashLineColor [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1]

@implementation YLDashLine

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, _lineWidth > 0 ? _lineWidth: kDefalutDashLineWidth);
    CGContextSetStrokeColorWithColor(context, _lineColor?_lineColor.CGColor:kDefaultDashLineColor.CGColor);
    //    CGFloat lengths[] = {4,2,10,5};//绘制4个点，跳过2个点，再绘制10个点，再跳过5个点。依次循环
    //    ｛10, 20, 10｝，则表示先绘制10个点，跳过20个点，绘制10个点，跳过10个点，再绘制20个点
    //     {3,3};//绘制3个点，跳过3个点。依次循环
    if(!_lengths){
        _lengths = @[@2, @2];
    }
    NSInteger count = _lengths.count;
    CGFloat *lens = (CGFloat*)malloc(count * sizeof(CGFloat));
    for(NSInteger i = 0; i < count; i++){
        lens[i] = [_lengths[i] floatValue];
    }
    CGContextSetLineDash(context, 0, lens, count);//parse=0 phase参数表示在第一个虚线绘制的时候跳过多少个点  count=2，是lengthes数组的长度
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, CGRectGetMaxX(self.bounds), 0);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}


@end
