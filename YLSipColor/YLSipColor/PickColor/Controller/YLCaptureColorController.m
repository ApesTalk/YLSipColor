//
//  YLCaptureColorController.m
//  YLLoveMark
//
//  Created by lumin on 2017/12/24.
//  Copyright © 2017年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLCaptureColorController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "YLColorDotView.h"
#import "UIImage+Color.h"
#import "UIView+Color.h"
#import "UIImage+FixOrientation.h"
#import "YLTranslucentToolbar.h"
#import "Constant.h"
#import "YLCollectionContainerView.h"
#import "YLPalette.h"

static NSInteger const kMinDotCount = 2;
static NSInteger const kMaxDotCount = 8;
static CGFloat const kToolBarHeight = 60.f;
static CGFloat const kScrollViewHeight = 60.f;

@interface YLCaptureColorController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) BOOL sessionPaused;
@property(nonatomic, assign) BOOL isUsingFaceCamera;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;///< 照片输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;///< 预览
@property (nonatomic, strong) UIView *backView;///< 拍照可见范围

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAccelerometerData *currentAccelerometerData;
@property (nonatomic, strong) CMGyroData *currentGyroData;
@property (nonatomic, strong) UIImage *capturedImage;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *lightBtn;
@property (nonatomic, strong) UIButton *lensBtn;

@property (nonatomic, strong) YLCollectionContainerView *scrollView;
@property (nonatomic, strong) UIButton *decreaseBtn;
@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, strong) YLTranslucentToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, strong) UIBarButtonItem *saveItem;
@property (nonatomic, strong) UIBarButtonItem *albumItem;

@property (nonatomic, assign) NSUInteger dotCount;
@property (nonatomic, strong) NSMutableArray *dotViews;
@property (nonatomic, strong) YLColorDotView *currentDragDotView;
@property (nonatomic, strong) NSMutableArray *dotColors;
@end

@implementation YLCaptureColorController
- (instancetype)init
{
    if(self = [super init]){
        _dotCount = 4;
        _dotViews = [NSMutableArray arrayWithCapacity:_dotCount];
        _dotColors = [NSMutableArray arrayWithCapacity:_dotCount];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];
    
    [self initAVCAptureSession];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGesture];
    
    _motionManager = [[CMMotionManager alloc]init];
    //判断加速度是否可用  监听平移
    if([_motionManager isAccelerometerAvailable] && ![_motionManager isAccelerometerActive]){
        //更新频率
        _motionManager.accelerometerUpdateInterval = 1;
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        //push方式获取和处理数据
        [_motionManager startAccelerometerUpdates];
        [_motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//            NSLog(@"x=%.4f", accelerometerData.acceleration.x);
//            NSLog(@"y=%.4f", accelerometerData.acceleration.y);
//            NSLog(@"z=%.4f", accelerometerData.acceleration.z);
            if(_sessionPaused){
                return;
            }
            if(!_currentAccelerometerData ||
               fabs(_currentAccelerometerData.acceleration.x - accelerometerData.acceleration.x) >= 0.1 ||
               fabs(_currentAccelerometerData.acceleration.y - accelerometerData.acceleration.y) >= 0.1 ||
               fabs(_currentAccelerometerData.acceleration.z - accelerometerData.acceleration.z) >= 0.1){
                [self captureImageFromBuffer];
            }
            _currentAccelerometerData = accelerometerData;
        }];
    }
    
    //判断陀螺仪是否可用 监听旋转
    if([_motionManager isGyroAvailable] && ![_motionManager isGyroActive]){
        _motionManager.gyroUpdateInterval = 1;
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [_motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
//            NSLog(@"Gyro rotation x=%.4f", gyroData.rotationRate.x);
//            NSLog(@"Gyro rotation y=%.4f", gyroData.rotationRate.y);
//            NSLog(@"Gyro rotation z=%.4f", gyroData.rotationRate.z);
            if(_sessionPaused){
                return;
            }
            if(!_currentGyroData ||
               fabs(_currentGyroData.rotationRate.x - gyroData.rotationRate.x) >= 0.1 ||
               fabs(_currentGyroData.rotationRate.y - gyroData.rotationRate.y) >= 0.1 ||
               fabs(_currentGyroData.rotationRate.z - gyroData.rotationRate.z) >= 0.1){
                [self captureImageFromBuffer];
            }
            _currentGyroData = gyroData;
        }];
    }
    
    [self generateDots];
    
    if(_session){
        [_session startRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(_session){
        [_session stopRunning];
    }
}

- (UIImageView *)imageView
{
    if(!_imageView){
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kScrollViewHeight - kToolBarHeight)];
        //测试
//        UIImage *image = [UIImage imageNamed:@"pubu.jpg"];
//        _imageView.image = [[image yl_resizeToSize:self.view.bounds.size]yl_fixOrientation];
        _imageView.hidden = YES;
    }
    return _imageView;
}

- (YLTranslucentToolbar *)toolBar
{
    if(!_toolBar){
        _toolBar = [[YLTranslucentToolbar alloc]initWithFrame:CGRectMake(0, kScreenHeight - kToolBarHeight, kScreenWidth, kToolBarHeight)];
        _toolBar.tintColor = [UIColor blackColor];
        UIBarButtonItem *spaceItem0 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *spaceItem1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _toolBar.items = @[self.closeItem, spaceItem0, self.saveItem, spaceItem1, self.albumItem];
    }
    return _toolBar;
}

- (UIBarButtonItem *)closeItem
{
    if(!_closeItem){
        _closeItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss)];
    }
    return _closeItem;
}

- (UIBarButtonItem *)saveItem
{
    if(!_saveItem){
        _saveItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"save"] style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    }
    return _saveItem;
}

- (UIBarButtonItem *)albumItem
{
    if(!_albumItem){
        _albumItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"photo"] style:UIBarButtonItemStylePlain target:self action:@selector(selectImage)];
    }
    return _albumItem;
}

- (UIButton *)lightBtn
{
    if(!_lightBtn){
        _lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lightBtn.frame = CGRectMake(0, kStatusBarHeight, 60, 60);
        [_lightBtn setImage:[UIImage imageNamed:@"light-off"] forState:UIControlStateNormal];
        [_lightBtn addTarget:self action:@selector(switchLightMode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightBtn;
}

- (UIButton *)lensBtn
{
    if(!_lensBtn){
        _lensBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lensBtn.frame = CGRectMake(kScreenWidth - 60, kStatusBarHeight, 60, 60);
        [_lensBtn setImage:[UIImage imageNamed:@"lens"] forState:UIControlStateNormal];
        [_lensBtn addTarget:self action:@selector(exchangeLens) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lensBtn;
}

- (YLCollectionContainerView *)scrollView
{
    if(!_scrollView){
        _scrollView = [[YLCollectionContainerView alloc]initWithFrame:CGRectMake(0, kScreenHeight - kScrollViewHeight - kToolBarHeight, kScreenWidth, kScrollViewHeight)];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.itemSize = CGSizeMake((kScreenWidth / _dotCount * 1.0), kScrollViewHeight);
        _scrollView.collectionView.bounces = NO;
        _scrollView.collectionView.scrollEnabled = NO;
        _scrollView.hidden = YES;
        [_scrollView addSubview:self.decreaseBtn];
        [_scrollView addSubview:self.addBtn];
    }
    return _scrollView;
}

- (UIButton *)decreaseBtn
{
    if(!_decreaseBtn){
        _decreaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _decreaseBtn.frame = CGRectMake(0, 0, 60, 60);
        [_decreaseBtn setImage:[UIImage imageNamed:@"reduce"] forState:UIControlStateNormal];
        [_decreaseBtn addTarget:self action:@selector(decreaseDot) forControlEvents:UIControlEventTouchUpInside];
    }
    return _decreaseBtn;
}

- (UIButton *)addBtn
{
    if(!_addBtn){
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.frame = CGRectMake(kScreenWidth - 60, 0, 60, 60);
        [_addBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(increaseDot) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

- (void)initSubViews
{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kScrollViewHeight)];
    [self.view addSubview:_backView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.lightBtn];
    [self.view addSubview:self.lensBtn];
}

//设置相机属性
- (void)initAVCAptureSession
{
    CGFloat captureWidth = kScreenWidth;
    CGFloat captureHeight = kScrollViewHeight - kScrollViewHeight - kToolBarHeight;
    
    //初始化会话、配置输入输出
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device hasFlash]){
        //更改这个设置的时候必须先锁定设备，修改完成后再解锁，否则崩溃
        [device lockForConfiguration:nil];
        //设置闪光灯关闭
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }else{
        NSLog(@"此设备不支持闪光灯");
    }
    
    _deviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
    if(error){
        NSLog(@"初始化deviceInput时出错：%@", error);
    }
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc]init];
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    //http://blog.csdn.net/volcan1987/article/details/6741011
    // Specify the pixel format
    //这里必须设置，才能在captureOutput:didOutputSampleBuffer:fromConnection:中获得图片，否则获取的是nil
    captureOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                            [NSNumber numberWithFloat:captureWidth], (id)kCVPixelBufferWidthKey,
                            [NSNumber numberWithFloat:captureHeight], (id)kCVPixelBufferHeightKey,
                            nil];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    
    //输出设置，jpeg格式
    NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    
    if([_session canAddInput:_deviceInput]){
        [_session addInput:_deviceInput];
    }
    if([_session canAddOutput:captureOutput]){
        [_session addOutput:captureOutput];
    }
    if([_session canAddOutput:_stillImageOutput]){
        [_session addOutput:_stillImageOutput];
    }
    
    //初始化预览图层
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_session];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    _previewLayer.frame = _backView.bounds;
    _backView.layer.masksToBounds = YES;
    [_backView.layer addSublayer:_previewLayer];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if(deviceOrientation == UIDeviceOrientationLandscapeLeft){
        result = AVCaptureVideoOrientationLandscapeRight;
    }else if (deviceOrientation == UIDeviceOrientationLandscapeRight){
        result = AVCaptureVideoOrientationLandscapeLeft;
    }
    return result;
}

//会有快门声
- (void)takePhoto
{
//    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
//    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
//    [stillImageConnection setVideoOrientation:avcaptureOrientation];
//    [stillImageConnection setVideoScaleAndCropFactor:1.f];
//
//    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//
//        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
//                                                                    imageDataSampleBuffer,
//                                                                    kCMAttachmentMode_ShouldPropagate);
//        UIImage *image = [UIImage imageWithData:jpegData];
//        NSLog(@"%@", image);
//        self.imageView.image = [image yl_resizeToSize:self.view.bounds.size];
//    }];
}

#pragma mark---AVCaptureVideoDataOutputSampleBufferDelegate
//没有声音，但是会调用很多次
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    /*We create an autorelealse pool because as we are not in the main_queue our code is
     not executed in the main thread. So we have to create an autorelease pool for the thread we are in*/
    //设置横屏，否则获取的图片是横屏图片 https://www.jianshu.com/p/61ca3a917fe5
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    _capturedImage = [[self imageFromSampleBuffer:sampleBuffer]yl_resizeToSize:self.imageView.bounds.size];
}

#pragma mark---
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = [[image yl_resizeToSize:self.imageView.bounds.size]yl_fixOrientation];
    self.imageView.hidden = NO;
    [self generateDots];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.lightBtn.hidden = NO;
    self.lensBtn.hidden = NO;
    _sessionPaused = NO;
    [_session startRunning];
}

#pragma mark---other methods
- (void)captureImageFromBuffer
{
    if(_capturedImage && _imageView.hidden){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = _capturedImage;
            [self generateDots];
        });
    }
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return (image);
}

- (void)generateDots
{
    [_dotColors removeAllObjects];
    NSInteger maxWidth = kScreenWidth - minDotSize;
    NSInteger maxHeight = kScreenHeight - kScrollViewHeight - kToolBarHeight - minDotSize;
    NSMutableArray *centerPoints = [NSMutableArray arrayWithCapacity:_dotCount];
    for(NSInteger i = 0; i < _dotCount; i++){
        CGFloat x = minDotSize * 0.5 + arc4random() % maxWidth + 1;//[1, maxWidth]
        CGFloat y = minDotSize * 0.5 + arc4random() % maxHeight + 1;
        CGPoint center = CGPointMake(x, y);
        [centerPoints addObject:[NSValue valueWithCGPoint:center]];
        YLColorDotView *dotView = nil;
        UIColor *color = [_imageView.image yl_colorAtPoint:center];
        if(color){
            [_dotColors addObject:color];
        }
        _scrollView.itemSize = CGSizeMake((kScreenWidth / _dotCount * 1.0), kScrollViewHeight);
        [_scrollView refreshWithColors:_dotColors];
        _scrollView.hidden = _dotColors.count == 0;
        
        if(i < _dotViews.count){
            dotView = _dotViews[i];
        }else{
            dotView = [[YLColorDotView alloc]init];
            //move from the view's center
            dotView.center = self.view.center;
            [self.view addSubview:dotView];
            [_dotViews addObject:dotView];
        }
        dotView.tag = i;
        //set color
        dotView.backgroundColor = color;
    }
    
    [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        //move to the point
        for(NSInteger i = 0; i < _dotCount; i++){
            UIView *dotView = _dotViews[i];
            dotView.center = [centerPoints[i]CGPointValue];
        }
    } completion:^(BOOL finished) {
        
    }];
    [self.view layoutIfNeeded];
}

- (void)switchLightMode:(UIButton *)sender
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //必选先判断是否有闪光灯
    if([device hasFlash]){
        //更改这个设置的时候必须先锁定设备，修改完成后再解锁，否则崩溃
        [device lockForConfiguration:nil];
        //设置闪光灯关闭
        AVCaptureTorchMode mode = device.torchMode;
        [device setTorchMode:mode == AVCaptureTorchModeOff ?  AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        UIImage *icon = mode == AVCaptureFlashModeOff ? [UIImage imageNamed:@"light-off"] : [UIImage imageNamed:@"light-on"];
        [sender setImage:icon forState:UIControlStateNormal];
        [device unlockForConfiguration];
    }else{
        NSLog(@"此设备不支持闪光灯");
    }
}

- (void)exchangeLens
{
    AVCaptureDevicePosition desiredPosition;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(_isUsingFaceCamera){
        if(device.isFlashAvailable){
            self.lightBtn.hidden = NO;
        }
        desiredPosition = AVCaptureDevicePositionBack;
    }else{
        desiredPosition = AVCaptureDevicePositionFront;
        self.lightBtn.hidden = YES;
    }
    
    for(AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]){
        if([device position] == desiredPosition){
            [self.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            for(AVCaptureDeviceInput *oldInput in self.session.inputs){
                [self.session removeInput:oldInput];
            }
            [self.session addInput:input];
            [self.session commitConfiguration];
            break;
        }
    }
    _isUsingFaceCamera =  !_isUsingFaceCamera;
}

- (void)decreaseDot
{
    if(_dotCount > kMinDotCount){
        _dotCount--;
        [self generateDots];
    }
}

- (void)increaseDot
{
    if(_dotCount < kMaxDotCount){
        _dotCount++;
        [self generateDots];
    }
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)save
{
    YLPalette *palette = [[YLPalette alloc]initWithName:@"" colors:_dotColors];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)selectImage
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if(![UIImagePickerController isSourceTypeAvailable:sourceType]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请允许使用相册" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.lightBtn.hidden = YES;
    self.lensBtn.hidden = YES;
    _sessionPaused = YES;
    
    [_session stopRunning];
    
    UIImagePickerController *photoVc = [[UIImagePickerController alloc]init];
    photoVc.sourceType = sourceType;
    photoVc.delegate = self;
    [self presentViewController:photoVc animated:YES completion:nil];
}


#pragma mark---signle tap action
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if(_imageView.hidden){
        //TODO:点一下停止监听，再点一下继续监听
        if(!_sessionPaused){
            _sessionPaused = YES;
            [_session stopRunning];
        }else{
            _sessionPaused = NO;
            [_session startRunning];
        }
    }
}

#pragma mark---touch action move dots
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_imageView.hidden){
        return;
    }
    
    BOOL touchOnDot = NO;
    for(UITouch *touch in touches.allObjects){
        if([touch.view isKindOfClass:[YLColorDotView class]]){
            _currentDragDotView = (YLColorDotView *)(touch.view);
            [self.view insertSubview:_currentDragDotView belowSubview:_scrollView];
            [_currentDragDotView showBigDotAnimated:YES];
            touchOnDot = YES;
            break;
        }
    }
    if(!touchOnDot && _currentDragDotView){
        _currentDragDotView = nil;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_imageView.hidden){
        return;
    }
    
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self.imageView];
    CGFloat maxCenterY = CGRectGetHeight(self.imageView.bounds) - 1;
    if(location.y > maxCenterY){
        location.y = maxCenterY;
    }
    
    if(_currentDragDotView){
        UIColor *newColor = [self.imageView.image yl_colorAtPoint:location];
        if(newColor && _currentDragDotView.tag < _dotColors.count){
            [_dotColors replaceObjectAtIndex:_currentDragDotView.tag withObject:newColor];
            [_scrollView refreshWithColors:_dotColors];
        }
        _currentDragDotView.backgroundColor = newColor;
        _currentDragDotView.center = location;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_imageView.hidden){
        return;
    }
    
    if(_currentDragDotView){
        [_currentDragDotView resetAnimated:YES];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_imageView.hidden){
        return;
    }
    
    if(_currentDragDotView){
        [_currentDragDotView resetAnimated:YES];
    }
}


@end
