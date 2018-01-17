//
//  YLPaletteDetailController.h
//  YLLoveMark
//
//  Created by lumin on 2018/1/7.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLPalette;

@protocol YLPaletteDetailDelegate <NSObject>
- (void)changedPalette:(YLPalette *)palette;///< 修改or新增
- (void)deletedPalette:(YLPalette *)palette;///< 删除
@end

@interface YLPaletteDetailController : UIViewController
@property (nonatomic, weak) id <YLPaletteDetailDelegate> delegate;

- (instancetype)initWithPalette:(YLPalette *)palette currentIndex:(NSInteger)index;

@end
