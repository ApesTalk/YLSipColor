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
    _nameLabel.text = @"ABC";
    _hexNameLabel.text = @"#888888";
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
@property (nonatomic, strong) UILabel *saturationLabel;
@property (nonatomic, strong) UISlider *saturationSlider;
@property (nonatomic, strong) UILabel *saturationValueLabel;
@property (nonatomic, strong) UILabel *brightLabel;
@property (nonatomic, strong) UISlider *brightSlider;
@property (nonatomic, strong) UILabel *brightValueLabel;
@property (nonatomic, strong) UILabel *alphaLabel;
@property (nonatomic, strong) UISlider *alphaSlider;
@property (nonatomic, strong) UILabel *alphaValueLabel;
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
        
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kActionSmallHeight, frame.size.width, kActionBigHeight - kActionSmallHeight)];
        [self addSubview:_bottomView];
        
        CGFloat y = 0;
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, y, frame.size.width, 0.5)];
        topLine.backgroundColor = [UIColor lightGrayColor];
        [_bottomView addSubview:topLine];
        y += 0.5 + 15;
        _hueLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 20, 21)];
        _hueLabel.backgroundColor = [UIColor whiteColor];
        _hueLabel.font = [UIFont systemFontOfSize:14];
        _hueLabel.textColor = [UIColor lightGrayColor];
        _hueLabel.text = @"Hue";
        [_bottomView addSubview:_hueLabel];
        y += 25;
        _hueSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 10 - 45, 25)];
        _hueSlider.minimumTrackTintColor = [UIColor yellowColor];
        _hueSlider.maximumTrackTintColor = [UIColor greenColor];
        [_hueSlider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
        [_bottomView addSubview:_hueSlider];
        _hueValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, y, 40, 21)];
        _hueValueLabel.backgroundColor = [UIColor whiteColor];
        _hueValueLabel.font = [UIFont systemFontOfSize:14];
        _hueValueLabel.textColor = [UIColor lightGrayColor];
        [_bottomView addSubview:_hueValueLabel];
        
        y += 21 + 15;
        _saturationLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 20, 21)];
        _saturationLabel.backgroundColor = [UIColor whiteColor];
        _saturationLabel.font = [UIFont systemFontOfSize:14];
        _saturationLabel.textColor = [UIColor lightGrayColor];
        _saturationLabel.text = @"Saturation";
        [_bottomView addSubview:_saturationLabel];
        y += 25;
        _saturationSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 10 - 45, 25)];
        _saturationSlider.minimumTrackTintColor = [UIColor yellowColor];
        _saturationSlider.maximumTrackTintColor = [UIColor greenColor];
        [_saturationSlider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
        [_bottomView addSubview:_saturationSlider];
        _saturationValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, y, 40, 21)];
        _saturationValueLabel.backgroundColor = [UIColor whiteColor];
        _saturationValueLabel.font = [UIFont systemFontOfSize:14];
        _saturationValueLabel.textColor = [UIColor lightGrayColor];
        [_bottomView addSubview:_saturationValueLabel];
        
        y += 21 + 15;
        _brightLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 20, 21)];
        _brightLabel.backgroundColor = [UIColor whiteColor];
        _brightLabel.font = [UIFont systemFontOfSize:14];
        _brightLabel.textColor = [UIColor lightGrayColor];
        _brightLabel.text = @"Brightness";
        [_bottomView addSubview:_brightLabel];
        y += 25;
        _brightSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 10 - 45, 25)];
        _brightSlider.minimumTrackTintColor = [UIColor yellowColor];
        _brightSlider.maximumTrackTintColor = [UIColor greenColor];
        [_brightSlider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];

        [_bottomView addSubview:_brightSlider];
        _brightValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, y, 40, 21)];
        _brightValueLabel.backgroundColor = [UIColor whiteColor];
        _brightValueLabel.font = [UIFont systemFontOfSize:14];
        _brightValueLabel.textColor = [UIColor lightGrayColor];
        [_bottomView addSubview:_brightValueLabel];
        
        y += 21 + 15;
        _alphaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 20, 21)];
        _alphaLabel.backgroundColor = [UIColor whiteColor];
        _alphaLabel.font = [UIFont systemFontOfSize:14];
        _alphaLabel.textColor = [UIColor lightGrayColor];
        _alphaLabel.text = @"Alpha";
        [_bottomView addSubview:_alphaLabel];
        y += 25;
        _alphaSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 10 - 45, 25)];
        _alphaSlider.minimumTrackTintColor = [UIColor yellowColor];
        _alphaSlider.maximumTrackTintColor = [UIColor greenColor];
        [_alphaSlider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];

        [_bottomView addSubview:_alphaSlider];
        _alphaValueLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, y, 40, 21)];
        _alphaValueLabel.backgroundColor = [UIColor whiteColor];
        _alphaValueLabel.font = [UIFont systemFontOfSize:14];
        _alphaValueLabel.textColor = [UIColor lightGrayColor];
        [_bottomView addSubview:_alphaValueLabel];
        
        y += 21 + 25;
        _toolBar = [[YLTranslucentToolbar alloc]initWithFrame:CGRectMake(0, y, frame.size.width, 44)];
        _toolBar.tintColor = [UIColor blackColor];
        [_bottomView addSubview:_toolBar];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_toolBar addSubview:line];
        
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
        [self setEditItemsEnable:NO];
    }
    return self;
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
    
}

#pragma mark---tool
- (NSString *)hexNameForColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

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
    
    [self refreshSliderGradientImage];
}

-(UIImage *)getGradientImageWithColors:(NSArray*)colors imgSize:(CGSize)imgSize
{
    NSMutableArray *arRef = [NSMutableArray array];
    for(UIColor *ref in colors) {
        [arRef addObject:(id)ref.CGColor];
        
    }
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arRef, NULL);
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(imgSize.width, imgSize.height);
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark---other methods
- (void)refreshSliderGradientImage
{
    UIColor *nowColor = [UIColor colorWithHue:_hueSlider.value saturation:_saturationSlider.value brightness:_brightSlider.value alpha:_alphaSlider.value];
    
    UIColor *hStartColor = [UIColor colorWithHue:0 saturation:_saturationSlider.value brightness:_brightSlider.value alpha:_alphaSlider.value];
    UIColor *hEndColor = [UIColor colorWithHue:1.0 saturation:_saturationSlider.value brightness:_brightSlider.value alpha:_alphaSlider.value];
    UIImage *hMinImg = [self getGradientImageWithColors:@[hStartColor, nowColor] imgSize:CGSizeMake(_hueSlider.bounds.size.width * _hueSlider.value, 4)];
    [_hueSlider setMinimumTrackImage:hMinImg forState:UIControlStateNormal];
    UIImage *hMaxImg = [self getGradientImageWithColors:@[nowColor, hEndColor] imgSize:CGSizeMake(_hueSlider.bounds.size.width - _hueSlider.bounds.size.width * _hueSlider.value, 4)];
    [_hueSlider setMaximumTrackImage:hMaxImg forState:UIControlStateNormal];
    
    UIColor *sStartColor = [UIColor colorWithHue:_hueSlider.value saturation:0 brightness:_brightSlider.value alpha:_alphaSlider.value];
    UIColor *sEndColor = [UIColor colorWithHue:_hueSlider.value saturation:1.0 brightness:_brightSlider.value alpha:_alphaSlider.value];
    UIImage *sMinImg = [self getGradientImageWithColors:@[sStartColor, nowColor] imgSize:CGSizeMake(_saturationSlider.bounds.size.width * _saturationSlider.value, 4)];
    [_saturationSlider setMinimumTrackImage:sMinImg forState:UIControlStateNormal];
    UIImage *sMaxImg = [self getGradientImageWithColors:@[nowColor, sEndColor] imgSize:CGSizeMake(_saturationSlider.bounds.size.width - _saturationSlider.bounds.size.width * _saturationSlider.value, 4)];
    [_saturationSlider setMaximumTrackImage:sMaxImg forState:UIControlStateNormal];
    
    UIColor *bStartColor = [UIColor colorWithHue:_hueSlider.value saturation:_saturationSlider.value brightness:0 alpha:_alphaSlider.value];
    UIColor *bEndColor = [UIColor colorWithHue:_hueSlider.value saturation:_saturationSlider.value brightness:1.0 alpha:_alphaSlider.value];
    UIImage *bMinImg = [self getGradientImageWithColors:@[bStartColor, nowColor] imgSize:CGSizeMake(_brightSlider.bounds.size.width * _brightSlider.value, 4)];
    [_brightSlider setMinimumTrackImage:bMinImg forState:UIControlStateNormal];
    UIImage *bMaxImg = [self getGradientImageWithColors:@[nowColor, bEndColor] imgSize:CGSizeMake(_brightSlider.bounds.size.width - _brightSlider.bounds.size.width * _brightSlider.value, 4)];
    [_brightSlider setMaximumTrackImage:bMaxImg forState:UIControlStateNormal];
    
    UIColor *aStartColor = [UIColor colorWithHue:_hueSlider.value saturation:_saturationSlider.value brightness:_brightSlider.value alpha:0];
    UIColor *aEndColor = [UIColor colorWithHue:_hueSlider.value saturation:_saturationSlider.value brightness:_brightSlider.value alpha:1.0];
    UIImage *aMinImg = [self getGradientImageWithColors:@[aStartColor, nowColor] imgSize:CGSizeMake(_alphaSlider.bounds.size.width * _alphaSlider.value, 4)];
    [_alphaSlider setMinimumTrackImage:aMinImg forState:UIControlStateNormal];
    UIImage *aMaxImg = [self getGradientImageWithColors:@[nowColor, aEndColor] imgSize:CGSizeMake(_alphaSlider.bounds.size.width - _alphaSlider.bounds.size.width * _alphaSlider.value, 4)];
    [_alphaSlider setMaximumTrackImage:aMaxImg forState:UIControlStateNormal];
}

- (void)sliderChanged
{
    [self refreshSliderGradientImage];

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
        [_delegate actionView:self actionType:YLActionTypeEndEdit oldColor:_currentColor newColor:nil];
    }
    
    CGRect newRect;
    if(self.isBig){
        UIBarButtonItem *redoItem = (UIBarButtonItem *)[_toolBar.items objectAtIndex:1];
        [self selectItem:redoItem];
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
        item.enabled = NO;
    }
}

@end
