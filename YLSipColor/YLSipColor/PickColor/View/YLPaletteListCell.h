//
//  YLPaletteListCell.h
//  YLLoveMark
//
//  Created by lumin on 2018/1/7.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLPalette;

typedef void(^YLPaletteListClickColorBlock)(UIColor *color, NSInteger index);

@interface YLPaletteListCell : UITableViewCell
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, copy) YLPaletteListClickColorBlock clickColorBlock;

- (void)refreshWithPalette:(YLPalette *)palette;
+ (CGFloat)height;
@end
