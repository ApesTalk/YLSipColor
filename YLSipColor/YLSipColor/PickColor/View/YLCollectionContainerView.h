//
//  YLCollectionContainerView.h
//  YLSipColor
//
//  Created by lumin on 2018/1/14.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//  含有CollectionView的容器

#import <UIKit/UIKit.h>

typedef void(^YLCollectionViewClickCellBlock)(NSIndexPath *indexPath, UIColor *color);

@interface YLCollectionContainerView : UIView
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, copy) YLCollectionViewClickCellBlock clickBlock;
- (void)refreshWithColors:(NSArray *)colors;
@end
