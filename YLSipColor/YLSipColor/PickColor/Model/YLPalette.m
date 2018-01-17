//
//  YLPalette.m
//  YLLoveMark
//
//  Created by lumin on 2018/1/7.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLPalette.h"

@implementation YLPalette
- (instancetype)initWithName:(NSString *)name colors:(NSArray *)colors
{
    if(self = [super init]){
        self.name = name;
        self.colors = colors;
    }
    return self;
}

@end
