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

@interface YLPaletteDetailController () <UICollectionViewDataSource, UICollectionViewDelegate,YLCollectionContainerViewDelegate, YLColorEditActionViewDelegate>
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
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat height = kScreenHeight - kBottomBarHeight;
    _rightBgView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth * 0.5, 0, kScreenWidth * 0.5, height)];
    _rightBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"translucentBg"]];
    _rightBgView.hidden = YES;
    [self.view addSubview:_rightBgView];
    
    _rightColorView = [[UIImageView alloc]initWithFrame:_rightBgView.bounds];
    _rightColorView.backgroundColor = [UIColor clearColor];
    [_rightBgView addSubview:_rightColorView];
    
    _containerView = [[YLCollectionContainerView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    _containerView.itemSize = CGSizeMake(kScreenWidth, height);
    _containerView.collectionView.pagingEnabled = YES;
    _containerView.delegate = self;
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

#pragma mark---YLCollectionContainerViewDelegate
- (void)containerView:(YLCollectionContainerView *)view scrollToPoint:(CGPoint)point
{
    [self.editView scrolToPoint:point];
}

#pragma mark---YLColorEditActionViewDelegate
- (void)actionView:(YLColorEditActionView *)actionView actionType:(YLActionType)type oldColor:(UIColor *)oldColor newColor:(UIColor *)newColor
{
    switch (type) {
        case YLActionTypeBeginEdit:{
            _containerView.collectionView.scrollEnabled = NO;
            [UIView animateWithDuration:0.25 animations:^{
                _topBar.frame = CGRectMake(0, -(kStatusBarHeight + kNavigatonBarHeight), kScreenWidth, kNavigatonBarHeight);
            } completion:nil];
            break;
        }
        case YLActionTypeEndEdit:{
            [UIView animateWithDuration:0.25 animations:^{
                _topBar.frame = CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavigatonBarHeight);
            } completion:nil];
            _containerView.collectionView.scrollEnabled = YES;
            _rightColorView.backgroundColor = [UIColor clearColor];
            _rightBgView.hidden = YES;
            [self.view sendSubviewToBack:_rightBgView];
            break;
        }
        case YLActionTypeClose:
            [self close];
            break;
        case YLActionTypeRedo:
            _rightColorView.backgroundColor = [UIColor clearColor];
            _rightBgView.hidden = YES;
            [self.view sendSubviewToBack:_rightBgView];
            break;
        case YLActionTypeAdd:{
            NSInteger index = _containerView.collectionView.contentOffset.x / _containerView.bounds.size.width;
            if(index >= 0 && index < _palette.colors.count){
                NSMutableArray *array = [NSMutableArray arrayWithArray:_palette.colors];
                if(array.count > index + 1){
                    [array insertObject:newColor atIndex:index + 1];
                }else{
                    [array addObject:newColor];
                }
                _palette.colors = array;
                [_containerView.collectionView reloadData];
                [self.editView refreshWithPalette:_palette];
                
                if([_delegate respondsToSelector:@selector(changedPalette:)]){
                    [_delegate changedPalette:_palette];
                }
            }
            [self close];
        }
            break;
        case YLActionTypeDone:{
            NSInteger index = _containerView.collectionView.contentOffset.x / _containerView.bounds.size.width;
            if(index >= 0 && index < _palette.colors.count){
                NSMutableArray *array = [NSMutableArray arrayWithArray:_palette.colors];
                [array replaceObjectAtIndex:index withObject:newColor];
                _palette.colors = array;
                [_containerView.collectionView reloadData];
                [self.editView refreshWithPalette:_palette];
                
                if([_delegate respondsToSelector:@selector(changedPalette:)]){
                    [_delegate changedPalette:_palette];
                }
            }
            [self close];
        }
            break;
        case YLActionTypeSlider:
            _rightColorView.backgroundColor = newColor;
            _rightBgView.hidden = NO;
            [self.view insertSubview:_rightBgView aboveSubview:_containerView];
            break;
        default:
            break;
    }
}

- (void)actionView:(YLColorEditActionView *)actionView scrollToPoint:(CGPoint)point
{
    _containerView.collectionView.contentOffset = point;
}

#pragma mark---other methods
- (void)close
{
    _topBar.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share
{
    
}

- (void)delete
{
    //TODO:弹窗提示
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger index = _containerView.collectionView.contentOffset.x / _containerView.bounds.size.width;
        if(index >= 0 && index < _palette.colors.count){
            NSMutableArray *array = [NSMutableArray arrayWithArray:_palette.colors];
            [array removeObjectAtIndex:index];
            _palette.colors = array;
            if([_delegate respondsToSelector:@selector(changedPalette:)]){
                [_delegate changedPalette:_palette];
            }
        }
        _topBar.hidden = YES;
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
