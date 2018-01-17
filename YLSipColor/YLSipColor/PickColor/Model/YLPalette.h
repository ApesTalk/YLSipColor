//
//  YLPalette.h
//  YLLoveMark
//
//  Created by lumin on 2018/1/7.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//  颜色分组

#import <Foundation/Foundation.h>

@interface YLPalette : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *colors;
- (instancetype)initWithName:(NSString *)name colors:(NSArray *)colors;
@end
