//
//  YLPaletteDetailController.m
//  YLLoveMark
//
//  Created by lumin on 2018/1/7.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLPaletteDetailController.h"
#import "Masonry.h"
#import "YLPalette.h"
#import "Constant.h"
#import "YLTranslucentToolbar.h"
#import "YLCollectionContainerView.h"
#import "YLColorEditActionView.h"

static CGFloat const kBottomBarHeight = 60;
static NSString *cellIdentifier = @"cell";

@interface YLPaletteDetailController () <UICollectionViewDataSource, UICollectionViewDelegate, YLColorEditActionViewDelegate>
@property (nonatomic, strong) YLPalette *palette;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIImageView *rightBgView;
@property (nonatomic, strong) UIView *rightColorView;
@property (nonatomic, strong) YLTranslucentToolbar *topBar;
@property (nonatomic, strong) YLCollectionContainerView *containerView;
@property (nonatomic, strong) YLColorEditActionView *editView;

@end

@implementation YLPaletteDetailController
- (instancetype)initWithPalette:(YLPalette *)palette currentIndex:(NSInteger)index
{
    if(self = [super init]){
        _palette = palette;
        _currentIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat height = kScreenHeight - kBottomBarHeight;
    _rightBgView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth * 0.5, 0, kScreenWidth * 0.5, height)];
    _rightBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"translucentBg"]];
    [self.view addSubview:_rightBgView];
    
    _rightColorView = [[UIImageView alloc]initWithFrame:_rightBgView.bounds];
    _rightColorView.backgroundColor = [UIColor clearColor];
    [_rightBgView addSubview:_rightColorView];
    
    _containerView = [[YLCollectionContainerView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    _containerView.itemSize = CGSizeMake(kScreenWidth, height);
    _containerView.collectionView.pagingEnabled = YES;
    [self.view addSubview:_containerView];

    _topBar = [[YLTranslucentToolbar alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavigatonBarHeight)];
    _topBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close)];
    UIBarButtonItem *spaceItem0 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete)];
    _topBar.items = @[closeItem, spaceItem0, shareItem, spaceItem1, deleteItem];
    [self.view addSubview:_topBar];
    
    [self.view addSubview:self.editView];
    [self.editView refreshWithPalette:_palette];
    [_containerView refreshWithColors:_palette.colors];
    if(_currentIndex > 0 && _currentIndex < _palette.colors.count){
        [_containerView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (YLColorEditActionView *)editView
{
    if(!_editView){
        _editView = [[YLColorEditActionView alloc]initWithFrame:CGRectMake(0, kScreenHeight - kActionSmallHeight - kHomeIndicatorHeight, kScreenWidth, kActionSmallHeight + kHomeIndicatorHeight)];
        _editView.delegate = self;
    }
    return _editView;
}

#pragma mark---YLColorEditActionViewDelegate
- (void)actionView:(YLColorEditActionView *)actionView actionType:(YLActionType)type oldColor:(UIColor *)oldColor newColor:(UIColor *)newColor
{
    switch (type) {
        case YLActionTypeEndEdit:{
            _rightColorView.backgroundColor = [UIColor clearColor];
            [self.view sendSubviewToBack:_rightBgView];
            break;
        }
        case YLActionTypeClose:
            [self close];
            break;
        case YLActionTypeRedo:
            _rightColorView.backgroundColor = [UIColor clearColor];
            [self.view sendSubviewToBack:_rightBgView];
            break;
        case YLActionTypeAdd:{
            NSInteger index = _containerView.collectionView.contentOffset.x / _containerView.bounds.size.width;
            if(index > 0 && index < _palette.colors.count){
                NSMutableArray *array = [NSMutableArray arrayWithArray:_palette.colors];
                [array insertObject:newColor atIndex:index];
                _palette.colors = array;
                [_containerView.collectionView reloadData];
                [self.editView refreshWithPalette:_palette];
            }
        }
            break;
        case YLActionTypeDone:{
            NSInteger index = _containerView.collectionView.contentOffset.x / _containerView.bounds.size.width;
            if(index > 0 && index < _palette.colors.count){
                NSMutableArray *array = [NSMutableArray arrayWithArray:_palette.colors];
                [array replaceObjectAtIndex:index withObject:newColor];
                _palette.colors = array;
                [_containerView.collectionView reloadData];
                [self.editView refreshWithPalette:_palette];
            }
        }
            break;
        case YLActionTypeSlider:
            _rightColorView.backgroundColor = newColor;
            [self.view insertSubview:_rightBgView aboveSubview:_containerView];
            break;
        default:
            break;
    }
}

#pragma mark---other methods
- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share
{
    
}

- (void)delete
{
    
}

@end
