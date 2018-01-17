//
//  YLCollectionContainerView.m
//  YLSipColor
//
//  Created by lumin on 2018/1/14.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLCollectionContainerView.h"

static NSString *cellIdentifier = @"cell";

@interface YLCollectionContainerView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray *colors;
@end

@implementation YLCollectionContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 0.f;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)refreshWithColors:(NSArray *)colors
{
    _colors = colors;
    [_collectionView reloadData];
}

#pragma mark---UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@""]];
    UIView *colorView = [cell.contentView viewWithTag:1000];
    if(!colorView){
        colorView = [[UIView alloc]init];
        colorView.tag = 1000;
        [cell.contentView addSubview:colorView];
    }
    colorView.frame = CGRectMake(0, 0, _itemSize.width, _itemSize.height);
    colorView.backgroundColor = [_colors objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark---UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(_clickBlock){
        _clickBlock(indexPath, [_colors objectAtIndex:indexPath.row]);
    }
}

@end
