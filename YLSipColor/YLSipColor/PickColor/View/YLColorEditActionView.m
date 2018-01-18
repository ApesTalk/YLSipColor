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
        NSArray *titles = @[@"Hue", @"Saturation", @"Brightness", @"Alpha"];
        for(NSInteger i = 0; i < 4; i++){
            UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 20, 16)];
            tLabel.font = [UIFont systemFontOfSize:14];
            tLabel.textColor = [UIColor lightGrayColor];
            tLabel.text = titles[i];
            [_bottomView addSubview:tLabel];
            y += 25;
            UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(10, y, frame.size.width - 10 - 45, 35)];
            slider.layer.cornerRadius = 17.5;
            slider.layer.masksToBounds = YES;
            [slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
            [_bottomView addSubview:slider];
            UILabel *vLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, y + (35 - 16) * 0.5, 40, 16)];
            vLabel.font = [UIFont systemFontOfSize:14];
            vLabel.textColor = [UIColor lightGrayColor];
            [_bottomView addSubview:vLabel];
            y += 35 + 10;
            
            if(i == 0){
                _hueLabel = tLabel;
                _hueSlider = slider;
                _hueValueLabel = vLabel;
            }else if (i == 1){
                _saturationLabel = tLabel;
                _saturationSlider = slider;
                _saturationValueLabel = vLabel;
            }else if (i == 2){
                _brightLabel = tLabel;
                _brightSlider = slider;
                _brightValueLabel = vLabel;
            }else{
                _alphaLabel = tLabel;
                _alphaSlider = slider;
                _alphaValueLabel = vLabel;
            }
        }
        
        y += 10;
        self.toolBar.frame = CGRectMake(0, y, frame.size.width, 44);
        [_bottomView addSubview:self.toolBar];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_toolBar addSubview:line];
        
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
    return [image resizableImageWithCapInsets:UIEdgeInsetsZero];
}

#pragma mark---other methods
- (void)refreshSliderGradientImage
{
    UIImage *img = [[UIImage imageNamed:@"sliderBg"]resizableImageWithCapInsets:UIEdgeInsetsZero];
    [_hueSlider setMinimumTrackImage:img forState:UIControlStateNormal];
    [_hueSlider setMaximumTrackImage:img forState:UIControlStateNormal];
    CGFloat hue = _hueSlider.value;
    CGFloat saturation = _saturationSlider.value;
    CGFloat brightness = _brightSlider.value;
    CGFloat alpha = _alphaSlider.value;
    UIColor *nowColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];

    UIColor *hStartColor = [UIColor colorWithHue:0 saturation:saturation brightness:brightness alpha:alpha];
    UIColor *hEndColor = [UIColor colorWithHue:1.0 saturation:saturation brightness:brightness alpha:alpha];
    UIImage *hMinImg = [self getGradientImageWithColors:@[hStartColor, nowColor] imgSize:CGSizeMake(_hueSlider.bounds.size.width * hue, 2)];
//    [_hueSlider setMinimumTrackImage:hMinImg forState:UIControlStateNormal];
//    UIImage *hMaxImg = [self getGradientImageWithColors:@[nowColor, hEndColor] imgSize:CGSizeMake(_hueSlider.bounds.size.width * (1 - hue), 2)];
//    [_hueSlider setMaximumTrackImage:hMaxImg forState:UIControlStateNormal];
    
    UIColor *sStartColor = [UIColor colorWithHue:hue saturation:0 brightness:brightness alpha:alpha];
    UIColor *sEndColor = [UIColor colorWithHue:hue saturation:1.0 brightness:brightness alpha:alpha];
    UIImage *sMinImg = [self getGradientImageWithColors:@[sStartColor, nowColor] imgSize:CGSizeMake(_saturationSlider.bounds.size.width * saturation, 2)];
    [_saturationSlider setMinimumTrackImage:sMinImg forState:UIControlStateNormal];
    UIImage *sMaxImg = [self getGradientImageWithColors:@[nowColor, sEndColor] imgSize:CGSizeMake(_saturationSlider.bounds.size.width * (1 - saturation), 2)];
    [_saturationSlider setMaximumTrackImage:sMaxImg forState:UIControlStateNormal];
    
    UIColor *bStartColor = [UIColor colorWithHue:hue saturation:saturation brightness:0 alpha:alpha];
    UIColor *bEndColor = [UIColor colorWithHue:hue saturation:saturation brightness:1.0 alpha:alpha];
    UIImage *bMinImg = [self getGradientImageWithColors:@[bStartColor, nowColor] imgSize:CGSizeMake(_brightSlider.bounds.size.width * brightness, 2)];
    [_brightSlider setMinimumTrackImage:bMinImg forState:UIControlStateNormal];
    UIImage *bMaxImg = [self getGradientImageWithColors:@[nowColor, bEndColor] imgSize:CGSizeMake(_brightSlider.bounds.size.width * (1 - brightness), 2)];
    [_brightSlider setMaximumTrackImage:bMaxImg forState:UIControlStateNormal];
    
    UIColor *aStartColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0];
    UIColor *aEndColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
    UIImage *aMinImg = [self getGradientImageWithColors:@[aStartColor, nowColor] imgSize:CGSizeMake(_alphaSlider.bounds.size.width * alpha, 2)];
    [_alphaSlider setMinimumTrackImage:aMinImg forState:UIControlStateNormal];
    UIImage *aMaxImg = [self getGradientImageWithColors:@[nowColor, aEndColor] imgSize:CGSizeMake(_alphaSlider.bounds.size.width * (1 - alpha), 2)];
    [_alphaSlider setMaximumTrackImage:aMaxImg forState:UIControlStateNormal];
}

- (void)sliderChanged
{
    [self refreshSliderGradientImage];
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
