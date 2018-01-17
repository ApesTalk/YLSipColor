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

@interface YLCaptureColorController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;///< 照片输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;///< 预览
@property (nonatomic, strong) UIView *backView;///< 拍照可见范围

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMAccelerometerData *currentAccelerometerData;
@property (nonatomic, strong) CMGyroData *currentGyroData;
@property (nonatomic, strong) UIImage *capturedImage;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *lightBtn;
@property (nonatomic, strong) UIButton *lensBtn;
@property (nonatomic, strong) UIButton *decreaseBtn;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *albumBtn;

@property (nonatomic, assign) NSUInteger maxDotCount;
@property (nonatomic, strong) NSMutableArray *dotViews;
@property (nonatomic, strong) YLColorDotView *currentDragDotView;
@end

@implementation YLCaptureColorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _maxDotCount = 8;
    _dotViews = [NSMutableArray arrayWithCapacity:_maxDotCount];
    [self initSubViews];
    [self generateDots];
    /*
    [self initAVCAptureSession];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGesture];
    
    _motionManager = [[CMMotionManager alloc]init];
    //判断加速度是否可用
    if([_motionManager isAccelerometerAvailable] && ![_motionManager isAccelerometerActive]){
        //更新频率
        _motionManager.accelerometerUpdateInterval = 1;
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        //push方式获取和处理数据
        [_motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//            NSLog(@"x=%.4f", accelerometerData.acceleration.x);
//            NSLog(@"y=%.4f", accelerometerData.acceleration.y);
//            NSLog(@"z=%.4f", accelerometerData.acceleration.z);
            if(!_currentAccelerometerData ||
               fabs(_currentAccelerometerData.acceleration.x - accelerometerData.acceleration.x) >= 0.1 ||
               fabs(_currentAccelerometerData.acceleration.y - accelerometerData.acceleration.y) >= 0.1 ||
               fabs(_currentAccelerometerData.acceleration.z - accelerometerData.acceleration.z) >= 0.1){
                [self captureImageFromBuffer];
            }
            _currentAccelerometerData = accelerometerData;
        }];
    }
    
    //判断陀螺仪是否可用
    if([_motionManager isGyroAvailable] && ![_motionManager isGyroActive]){
        _motionManager.gyroUpdateInterval = 1;
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [_motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
//            NSLog(@"Gyro rotation x=%.4f", gyroData.rotationRate.x);
//            NSLog(@"Gyro rotation y=%.4f", gyroData.rotationRate.y);
//            NSLog(@"Gyro rotation z=%.4f", gyroData.rotationRate.z);
            if(!_currentGyroData ||
               fabs(_currentGyroData.rotationRate.x - gyroData.rotationRate.x) >= 0.1 ||
               fabs(_currentGyroData.rotationRate.y - gyroData.rotationRate.y) >= 0.1 ||
               fabs(_currentGyroData.rotationRate.z - gyroData.rotationRate.z) >= 0.1){
                [self captureImageFromBuffer];
            }
            _currentGyroData = gyroData;
        }];
    }
    */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_session && !_imageView.image){
        [_session startRunning];
    }
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
        _imageView = [[UIImageView alloc]init];
        UIImage *image = [UIImage imageNamed:@"pubu.jpg"];
        _imageView.image = [[image yl_resizeToSize:self.view.bounds.size]yl_fixOrientation];
//        _imageView.hidden = YES;
    }
    return _imageView;
}

- (UIButton *)closeBtn
{
    if(!_closeBtn){
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(10, 10, 100, 50);
        _closeBtn.backgroundColor = [UIColor redColor];
        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)lensBtn
{
    if(!_lensBtn){
        _lensBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lensBtn.frame = CGRectMake(CGRectGetWidth(self.view.bounds) -110, 10, 100, 50);
        _lensBtn.backgroundColor = [UIColor redColor];
        [_lensBtn addTarget:self action:@selector(exchangeLens) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lensBtn;
}

- (UIButton *)lightBtn
{
    if(!_lightBtn){
        _lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lightBtn.frame = CGRectMake(CGRectGetWidth(self.view.bounds) -110, 10, 100, 50);
        _lightBtn.backgroundColor = [UIColor redColor];
        [_lightBtn addTarget:self action:@selector(switchLightMode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightBtn;
}

- (void)initSubViews
{
    CGFloat selfWidth = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    
    self.imageView.frame = self.view.frame;
    [self.view addSubview:self.imageView];
//    [self.view addSubview:self.closeBtn];
//    [self.view addSubview:self.lensBtn];
//
//    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, selfWidth, selfHeight)];
//    [self.view addSubview:_backView];
//
//    [self.view addSubview:_lightBtn];
}

//设置相机属性
- (void)initAVCAptureSession
{
    CGFloat selfWidth = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    
    //初始化会话、配置输入输出
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //更改这个设置的时候必须先锁定设备，修改完成后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
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
                            [NSNumber numberWithFloat:selfWidth], (id)kCVPixelBufferWidthKey,
                            [NSNumber numberWithFloat:selfHeight], (id)kCVPixelBufferHeightKey,
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
    _previewLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
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

- (void)generateDots
{
    NSInteger maxWidth = CGRectGetWidth(self.view.bounds) - minDotSize;
    NSInteger maxHeight = CGRectGetHeight(self.view.bounds) - minDotSize;
    NSMutableArray *centerPoints = [NSMutableArray arrayWithCapacity:_maxDotCount];
    for(NSInteger i = 0; i < _maxDotCount; i++){
        CGFloat x = minDotSize * 0.5 + arc4random() % maxWidth + 1;//[1, maxWidth]
        CGFloat y = minDotSize * 0.5 + arc4random() % maxHeight + 1;
        CGPoint center = CGPointMake(x, y);
        [centerPoints addObject:[NSValue valueWithCGPoint:center]];
        YLColorDotView *dotView = nil;
        UIColor *color = [_imageView.image yl_colorAtPoint:center];
        if(i < _dotViews.count){
            dotView = _dotViews[i];
        }else{
            dotView = [[YLColorDotView alloc]init];
            //move from the view's center
            dotView.center = self.view.center;
            [self.view addSubview:dotView];
            [_dotViews addObject:dotView];
        }
        //set color
        dotView.backgroundColor = color;
    }
    
    [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        //move to the point
        for(NSInteger i = 0; i < _maxDotCount; i++){
            UIView *dotView = _dotViews[i];
            dotView.center = [centerPoints[i]CGPointValue];
        }
    } completion:^(BOOL finished) {
        
    }];
    [self.view layoutIfNeeded];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)exchangeLens
{
    [self captureImageFromBuffer];
}

- (void)switchLightMode:(UIButton *)sender
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //修改前需要先锁定
    [device lockForConfiguration:nil];
    //必选先判断是否有闪光灯
    if([device hasFlash]){
        NSString *title = sender.titleLabel.text;
        if([title isEqualToString:@"打开"]){
            if([device isFlashModeSupported:AVCaptureFlashModeOn]){
                [device setFlashMode:AVCaptureFlashModeOn];
            }
        }else if ([title isEqualToString:@"自动"]){
            if([device isFlashModeSupported:AVCaptureFlashModeAuto]){
                [device setFlashMode:AVCaptureFlashModeAuto];
            }
        }else if ([title isEqualToString:@"关闭"]){
            if([device isFlashModeSupported:AVCaptureFlashModeOff]){
                [device setFlashMode:AVCaptureFlashModeOff];
            }
        }
    }else{
        NSLog(@"此设备不支持闪光灯");
    }
    [device unlockForConfiguration];
}

#pragma mark---AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    /*We create an autorelealse pool because as we are not in the main_queue our code is
     not executed in the main thread. So we have to create an autorelease pool for the thread we are in*/
    //设置横屏，否则获取的图片是横屏图片 https://www.jianshu.com/p/61ca3a917fe5
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    _capturedImage = [[self imageFromSampleBuffer:sampleBuffer]yl_resizeToSize:self.imageView.bounds.size];
}

- (void)captureImageFromBuffer
{
    if(_capturedImage){
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

#pragma mark---signle tap action
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if(_imageView.hidden){
        //TODO:点一下停止监听，再点一下继续监听
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
            [self.view bringSubviewToFront:_currentDragDotView];
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
    CGPoint location = [touch locationInView:self.view];
    if(_currentDragDotView){
        _currentDragDotView.backgroundColor = [self.imageView.image yl_colorAtPoint:location];
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


@end
