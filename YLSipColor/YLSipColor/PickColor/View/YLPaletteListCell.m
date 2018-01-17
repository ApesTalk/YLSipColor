//
//  YLPaletteListCell.m
//  YLLoveMark
//
//  Created by lumin on 2018/1/7.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLPaletteListCell.h"
#import "Masonry.h"
#import "YLPalette.h"
#import "YLCollectionContainerView.h"
#import "Constant.h"

static CGFloat kCollectionViewHeight = 60.f;

@interface YLPaletteListCell () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) YLCollectionContainerView *containerView;
@end

@implementation YLPaletteListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _titleField = [[UITextField alloc]init];
        _titleField.font = [UIFont systemFontOfSize:16];
        _titleField.textColor = [UIColor blackColor];
        _titleField.placeholder = @"给这组颜色取个名吧...";
        [self.contentView addSubview:_titleField];
        
        _containerView = [[YLCollectionContainerView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kCollectionViewHeight)];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.collectionView.bounces = NO;
        _containerView.collectionView.scrollEnabled = NO;
        [self.contentView addSubview:_containerView];
        
        [_titleField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@25).priorityHigh();
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.contentView).offset(-10);
        }];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(kCollectionViewHeight)).priorityHigh();
            make.left.bottom.right.equalTo(self.contentView);
            make.top.equalTo(_titleField.mas_bottom);
        }];
    }
    return self;
}

- (void)refreshWithPalette:(YLPalette *)palette
{
    if(palette){
        _titleField.text = palette.name;
        CGFloat itemWidth = CGRectGetWidth(self.contentView.bounds) / palette.colors.count;
        _containerView.itemSize = CGSizeMake(itemWidth, kCollectionViewHeight);
        [_containerView refreshWithColors:palette.colors];
        __weak typeof(self) weakSelf = self;
        _containerView.clickBlock = ^(NSIndexPath *indexPath, UIColor *color) {
            if(weakSelf.clickColorBlock){
                weakSelf.clickColorBlock(color, indexPath.row);
            }
        };
    }
}

+ (CGFloat)height
{
    return kCollectionViewHeight + 40;
}

@end
