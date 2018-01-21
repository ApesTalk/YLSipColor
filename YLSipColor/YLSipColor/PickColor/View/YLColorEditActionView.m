//
//  YLColorEditActionView.m
//  YLSipColor
//
//  Created by lumin on 2018/1/14.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLColorEditActionView.h"
#import "YLTranslucentToolbar.h"
#import "YLPalette.h"
#import "Constant.h"
#import "YLDashLine.h"
#import "UIColor+Name.h"

static NSString *cellIdentifier = @"cell";

@interface YLColorNameCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *hexNameLabel;
- (void)refreshWithColor:(UIColor *)color;
@end

@implementation YLColorNameCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        CGFloat gap = (kActionSmallHeight - 42) * 0.5;
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, gap, frame.size.width - 60, 21)];
        _nameLabel.backgroundColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLabel];
        _hexNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, kActionSmallHeight-21-gap, frame.size.width - 60, 21)];
        _hexNameLabel.backgroundColor = [UIColor whiteColor];
        _hexNameLabel.font = [UIFont systemFontOfSize:14];
        _hexNameLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_hexNameLabel];
    }
    return self;
}

- (void)refreshWithColor:(UIColor *)color
{
    _nameLabel.text = [color yl_commonName];
    _hexNameLabel.text = [color yl_hexName];
}

@end


@interface YLSlider : UISlider
@end

@implementation YLSlider
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    CGRect newRect = [super trackRectForBounds:bounds];
    //默认2
    newRect.size.height = 4;
    return newRect;
}
@end

@interface YLColorEditActionView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) YLPalette *palette;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *hueLabel;
@property (nonatomic, strong) UISlider *hueSlider;
@property (nonatomic, strong) UILabel *hueValueLabel;
@property (nonatomic, strong) CAGradientLayer *hueLayer;
@property (nonatomic, strong) UILabel *saturationLabel;
@property (nonatomic, strong) UISlider *saturationSlider;
@property (nonatomic, strong) UILabel *saturationValueLabel;
@property (nonatomic, strong) CAGradientLayer *saturationLayer;
@property (nonatomic, strong) UILabel *brightLabel;
@property (nonatomic, strong) UISlider *brightSlider;
@property (nonatomic, strong) UILabel *brightValueLabel;
@property (nonatomic, strong) CAGradientLayer *brightLayer;
@property (nonatomic, strong) UILabel *alphaLabel;
@property (nonatomic, strong) UISlider *alphaSlider;
@property (nonatomic, strong) UILabel *alphaValueLabel;
@property (nonatomic, strong) CAGradientLayer *alphaLayer;
@property (nonatomic, strong) YLTranslucentToolbar *toolBar;
@property (nonatomic, strong) UIColor *currentColor;
@end


@implementation YLColorEditActionView
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 0.f;
        layout.itemSize = CGSizeMake(frame.size.width, kActionSmallHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, kActionSmallHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[YLColorNameCell class] forCellWithReuseIdentifier:cellIdentifier];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        [self addSubview:_collectionView];
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.backgroundColor = [UIColor whiteColor];
        _editBtn.frame = CGRectMake(frame.size.width - 50, 0, 50, kActionSmallHeight);
        [_editBtn setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_editBtn];
        
        [self setBottomSubViews:frame];
        
        [self setEditItemsEnable:NO];
    }
    return self;
}

- (YLTranslucentToolbar *)toolBar
{
    if(!_toolBar){
        _toolBar = [[YLTranslucentToolbar alloc]init];
        _toolBar.tintColor = [UIColor blackColor];
        [_bottomView addSubview:_toolBar];
        
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(selectItem:)];
        closeItem.tag = YLActionTypeClose;
        UIBarButtonItem *spaceItem0 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *redoItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(selectItem:)];
        redoItem.tag = YLActionTypeRedo;
        UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectItem:)];
        addItem.tag = YLActionTypeAdd;
        UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"save"] style:UIBarButtonItemStylePlain target:self action:@selector(selectItem:)];
        doneItem.tag = YLActionTypeDone;
        _toolBar.items = @[closeItem, spaceItem0, redoItem, spaceItem1, addItem, spaceItem2, doneItem];
    }
    return _toolBar;
}

- (void)setBottomSubViews:(CGRect)frame
{
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kActionSmallHeight, frame.size.width, kActionBigHeight - kActionSmallHeight)];
    [self addSubview:_bottomView];
    
    CGFloat y = 0;
    UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, y, frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [_bottomView addSubview:topLine];
    y += 0.5 + 15;
    NSArray *titles = @[@"Hue", @"Saturation", @"Brightness", @"Alpha"];
    for(NSInteger i = 0; i < 4; i++){
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 20, 16)];
        tLabel.font = [UIFont systemFontOfSize:14];
        tLabel.textColor = [UIColor lightGrayColor];
        tLabel.text = titles[i];
        [_bottomView addSubview:tLabel];
        y += 25;
        UISlider *slider = [[YLSlider alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 10 - 45, 35)];
        slider.minimumTrackTintColor = [UIColor clearColor];
        slider.maximumTrackTintColor = [UIColor clearColor];
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [_bottomView addSubview:slider];
        //背景图
        YLDashLine *dashLine = [[YLDashLine alloc]init];
        dashLine.layer.cornerRadius = 2;
        dashLine.layer.masksToBounds = YES;
        dashLine.layer.borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.00].CGColor;
        dashLine.layer.borderWidth = 0.5;
        dashLine.frame = CGRectMake(0, 0, frame.size.width - 10 - 45, 4);
        dashLine.backgroundColor = [UIColor whiteColor];
        dashLine.lineColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.00];
        dashLine.lineWidth = 6;
        dashLine.center = slider.center;
        [_bottomView insertSubview:dashLine belowSubview:slider];
        //渐变色
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        gradientLayer.locations = @[@0.0, @0.5, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1.0, 0);
        gradientLayer.frame = CGRectMake(0, 0, frame.size.width - 10 - 45, 4);
        [dashLine.layer addSublayer:gradientLayer];
        
        
        UILabel *vLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, y + (35 - 16) * 0.5, 40, 16)];
        vLabel.font = [UIFont systemFontOfSize:14];
        vLabel.textColor = [UIColor lightGrayColor];
        [_bottomView addSubview:vLabel];
        y += 35 + 10;
        
        if(i == 0){
            _hueLabel = tLabel;
            _hueSlider = slider;
            _hueValueLabel = vLabel;
            _hueLayer = gradientLayer;
        }else if (i == 1){
            _saturationLabel = tLabel;
            _saturationSlider = slider;
            _saturationValueLabel = vLabel;
            _saturationLayer = gradientLayer;
        }else if (i == 2){
            _brightLabel = tLabel;
            _brightSlider = slider;
            _brightValueLabel = vLabel;
            _brightLayer = gradientLayer;
        }else{
            _alphaLabel = tLabel;
            _alphaSlider = slider;
            _alphaValueLabel = vLabel;
            _alphaLayer = gradientLayer;
        }
    }
    
    y += 10;
    self.toolBar.frame = CGRectMake(0, y, frame.size.width, 44);
    [_bottomView addSubview:self.toolBar];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_toolBar addSubview:line];
}

- (BOOL)isBig
{
    return self.bounds.size.height > kActionSmallHeight + kHomeIndicatorHeight;
}

- (void)refreshWithPalette:(YLPalette *)palette
{
    _palette = palette;
    if(palette.colors.count > 0){
        _currentColor = [palette.colors firstObject];
        [self getHSBAFromColor:_currentColor];
    }
    [_collectionView reloadData];
}

- (void)scrolToPoint:(CGPoint)point
{
    _collectionView.contentOffset = point;
}

#pragma mark---UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _palette.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLColorNameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell refreshWithColor:[_palette.colors objectAtIndex:indexPath.row]];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([_delegate respondsToSelector:@selector(actionView:scrollToPoint:)]){
        [_delegate actionView:self scrollToPoint:scrollView.contentOffset];
    }
}

#pragma mark---tool
- (void)getHSBAFromColor:(UIColor *)color
{
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    _hueSlider.value = hue;
    _hueValueLabel.text = [NSString stringWithFormat:@"%li°", (NSInteger)(hue * 360)];
    _saturationSlider.value = saturation;
    _saturationValueLabel.text = [NSString stringWithFormat:@"%.0f%%", saturation * 100];
    _brightSlider.value = brightness;
    _brightValueLabel.text = [NSString stringWithFormat:@"%.0f%%", brightness * 100];
    _alphaSlider.value = alpha;
    _alphaValueLabel.text = [NSString stringWithFormat:@"%.0f%%", alpha * 100];
    
    [self refreshSliderGradientColor];
}

- (void)refreshSliderGradientColor
{
    CGFloat hue = _hueSlider.value;
    CGFloat saturation = _saturationSlider.value;
    CGFloat brightness = _brightSlider.value;
    CGFloat alpha = _alphaSlider.value;
    UIColor *nowColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];

    UIColor *hStartColor = [UIColor colorWithHue:0 saturation:saturation brightness:brightness alpha:alpha];
    UIColor *hEndColor = [UIColor colorWithHue:1.0 saturation:saturation brightness:brightness alpha:alpha];
    _hueLayer.colors = @[(__bridge id)hStartColor.CGColor, (__bridge id)nowColor.CGColor, (__bridge id)hEndColor.CGColor];
    _hueLayer.locations = @[@0.0, @(hue), @1.0];

    UIColor *sStartColor = [UIColor colorWithHue:hue saturation:0 brightness:brightness alpha:alpha];
    UIColor *sEndColor = [UIColor colorWithHue:hue saturation:1.0 brightness:brightness alpha:alpha];
    _saturationLayer.colors = @[(__bridge id)sStartColor.CGColor, (__bridge id)nowColor.CGColor, (__bridge id)sEndColor.CGColor];
    _saturationLayer.locations = @[@0.0, @(saturation), @1.0];
    
    UIColor *bStartColor = [UIColor colorWithHue:hue saturation:saturation brightness:0 alpha:alpha];
    UIColor *bEndColor = [UIColor colorWithHue:hue saturation:saturation brightness:1.0 alpha:alpha];
    _brightLayer.colors = @[(__bridge id)bStartColor.CGColor, (__bridge id)nowColor.CGColor, (__bridge id)bEndColor.CGColor];
    _brightLayer.locations = @[@0.0, @(brightness), @1.0];

    UIColor *aStartColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0];
    UIColor *aEndColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
    _alphaLayer.colors = @[(__bridge id)aStartColor.CGColor, (__bridge id)nowColor.CGColor, (__bridge id)aEndColor.CGColor];
    _alphaLayer.locations = @[@0.0, @(alpha), @1.0];
}

- (void)sliderValueChanged
{
    [self refreshSliderGradientColor];
    [self setEditItemsEnable:YES];
    if([_delegate respondsToSelector:@selector(actionView:actionType:oldColor:newColor:)]){
        UIColor *newColor = [UIColor colorWithHue:_hueSlider.value saturation:_saturationSlider.value brightness:_brightSlider.value alpha:_alphaSlider.value];
        [_delegate actionView:self actionType:YLActionTypeSlider oldColor:_currentColor newColor:newColor];
    }
}

- (void)editAction
{
    if([_delegate respondsToSelector:@selector(actionView:actionType:oldColor:newColor:)]){
        NSInteger index = _collectionView.contentOffset.x / _collectionView.bounds.size.width;
        if(index > 0 && index < _palette.colors.count){
            _currentColor = [_palette.colors objectAtIndex:index];
        }
        if(self.isBig){
            [self setEditItemsEnable:NO];
            //重置颜色
            [self getHSBAFromColor:_currentColor];
            _collectionView.scrollEnabled = YES;
        }else{
            _collectionView.scrollEnabled = NO;
        }
        [_delegate actionView:self actionType:self.isBig ? YLActionTypeEndEdit : YLActionTypeBeginEdit oldColor:_currentColor newColor:nil];
    }
    
    CGRect newRect;
    if(self.isBig){
        newRect = CGRectMake(0, kScreenHeight - kActionSmallHeight - kHomeIndicatorHeight, kScreenWidth, kActionSmallHeight + kHomeIndicatorHeight);
    }else{
        newRect = CGRectMake(0, kScreenHeight - kActionBigHeight - kHomeIndicatorHeight, kScreenWidth, kActionBigHeight + kHomeIndicatorHeight);
    }
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = newRect;
    } completion:nil];
}

- (void)selectItem:(UIBarButtonItem *)item
{
    NSInteger index = _collectionView.contentOffset.x / _collectionView.bounds.size.width;
    if(index > 0 && index < _palette.colors.count){
        _currentColor = [_palette.colors objectAtIndex:index];
    }
    
    if(item.tag == YLActionTypeRedo){
        [self setEditItemsEnable:NO];
        //重置颜色
        [self getHSBAFromColor:_currentColor];
    }
    
    if([_delegate respondsToSelector:@selector(actionView:actionType:oldColor:newColor:)]){
        UIColor *newColor = [UIColor colorWithHue:_hueSlider.value saturation:_saturationSlider.value brightness:_brightSlider.value alpha:_alphaSlider.value];
        [_delegate actionView:self actionType:item.tag oldColor:_currentColor newColor:newColor];
    }
}

- (void)setEditItemsEnable:(BOOL)enable
{
    for(NSInteger i = 1; i < 7; i++){
        UIBarButtonItem *item = (UIBarButtonItem *)[_toolBar.items objectAtIndex:i];
        item.enabled = enable;
    }
}

@end
