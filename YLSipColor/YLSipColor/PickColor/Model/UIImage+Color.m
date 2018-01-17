//
//  UIImage+Color.m
//  YLLoveMark
//
//  Created by lumin on 2017/12/24.
//  Copyright © 2017年 https://github.com/lqcjdx. All rights reserved.
//
//https://developer.apple.com/library/content/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html#//apple_ref/doc/uid/TP30001066-CH203

#import "UIImage+Color.h"

@implementation UIImage (Color)
- (UIColor *)yl_colorAtPoint:(CGPoint)point
{
    if(!CGRectContainsPoint(CGRectMake(0, 0, self.size.width, self.size.height), point)){
        return nil;
    }
    NSInteger pointX = trunc(point.x);//截断取整，不四舍五入
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    //创建色彩标准
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = {0, 0, 0, 0};
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY - height);
    CGContextDrawImage(context, CGRectMake(0.f, 0.f, width, height), cgImage);
    CGContextRelease(context);
    
    CGFloat red = (CGFloat)pixelData[0] / 255.f;
    CGFloat green = (CGFloat)pixelData[1] / 255.f;
    CGFloat blue = (CGFloat)pixelData[2] / 255.f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.f;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return color;
}

- (UIImage *)yl_resizeToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
