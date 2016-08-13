//
//  GPPaintBoard.m
//  PaintBoard
//
//  Created by MS on 15-9-7.
//  Copyright (c) 2015年 GaoPanpan. All rights reserved.
//

#import "GPPaintBoard.h"

@implementation GPPaintBoard
{
    CALayer * drawLayer;
    UIImage * mainImage;
    UIImage * drawImage;
    UIImage * blurImage;
    CGPoint lastPoint;
    CGPoint currentPoint;
    CGPoint blurPoint;
    NSTimer * blurTimer;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        [self initCommon];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super initWithCoder:aDecoder]) {
        [self initCommon];
    }
    return self;
}
- (void)initCommon
{
    self.dropLines = [NSMutableArray array];
    self.drawLines = [NSMutableArray array];
    self.paintBoardToolType = 0;
    self.brushColor = [UIColor blackColor];
    self.brushWidth = 1.0f;
    self.brushBlur = 0.5f;
    self.brushOpacity = 1.0f;
    drawLayer = [[CALayer alloc]init];
    drawLayer.frame = CGRectMake(0, 0, self.layer.frame.size.width, self.layer.frame.size.height);
    mainImage = nil;
    drawImage = nil;
    blurImage = nil;
    blurTimer = nil;
    [self.layer addSublayer:drawLayer];
    [self clearColor:self.backgroundColor];
}
- (void)layoutSubviews
{
    drawLayer.frame = CGRectMake(0, 0, self.layer.frame.size.width, self.layer.frame.size.height);
}
- (void)setBrushOpacity:(CGFloat)brushOpacity
{
    _brushOpacity = brushOpacity;
    drawLayer.opacity = brushOpacity;
}
- (void)setBrushBlur:(CGFloat)brushBlur
{
    _brushBlur = MIN(MAX(brushBlur, 0.0f), 1.0f);
}
#pragma mark -画图的方法-
//Paint的画线
- (void)drawLineFrom:(CGPoint)start to:(CGPoint)end withWidth:(CGFloat)width
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    /**
     *  该方法控制坐标系统水平方向上缩放 sx，垂直方向上缩放 sy。在缩放后的坐标系统上绘制图形时，所有点的 X 坐标都相当于乘以 sx 因子，所有点的 Y 坐标都相当于乘以 sy 因子。
     */
    CGContextScaleCTM(contextRef, 1, -1);
    /**
     *  平移坐标系统。
     该方法相当于把原来位于 (0, 0) 位置的坐标原点平移到 (tx, ty) 点。
     在平移后的坐标系统上绘制图形时，所有坐标点的 X 坐标都相当于增加了 tx，所有点的 Y 坐标都相当于增加了 ty。
     */
    CGContextTranslateCTM(contextRef, 0, -self.frame.size.height);
    if (drawImage != nil) {
        CGContextDrawImage(contextRef, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), drawImage.CGImage);
    }
    //画线
    CGContextSetLineCap(contextRef, kCGLineCapRound);
    CGContextSetLineWidth(contextRef, width);
    CGContextSetStrokeColorWithColor(contextRef, self.brushColor.CGColor);
    CGContextMoveToPoint(contextRef, start.x, start.y);
    CGContextAddLineToPoint(contextRef, end.x, end.y);
    CGContextStrokePath(contextRef);
    CGContextFlush(contextRef);
    //将线条保存为图片
    drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    drawLayer.contents = (id)drawImage.CGImage;
}
//Blur的画图
- (void)drawImage:(UIImage *)image at:(CGPoint)point
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextTranslateCTM(contextRef, 0, -self.frame.size.height);
    if (drawImage != nil) {
        CGContextDrawImage(contextRef, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), drawImage.CGImage);
    }
    CGRect rect = CGRectMake(point.x - (image.size.width/2), point.y - (image.size.height/2), image.size.width, image.size.width);
    CGContextDrawImage(contextRef, rect, image.CGImage);
    CGContextFlush(contextRef);
    drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    drawLayer.contents = (id)drawImage.CGImage;
}
- (void) drawImage:(UIImage*)image from:(CGPoint)fromPoint to:(CGPoint)toPoint
{
    CGFloat dx = toPoint.x - fromPoint.x;
    CGFloat dy = toPoint.y - fromPoint.y;
    CGFloat len = sqrtf((dx*dx)+(dy*dy));
    CGFloat ix = dx/len;
    CGFloat iy = dy/len;
    CGPoint point = fromPoint;
    int ilen = (int)len;
    
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, 1.0f, -1.0f);
    CGContextTranslateCTM(ctx, 0.0f, -self.frame.size.height);
    if (drawImage != nil) {
        CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        CGContextDrawImage(ctx, rect, drawImage.CGImage);
    }
    for (int i = 0; i < ilen; i++) {
        CGRect rect = CGRectMake(point.x - (image.size.width / 2.0f),
                                 point.y - (image.size.height / 2.0f),
                                 image.size.width, image.size.height);
        CGContextDrawImage(ctx, rect, image.CGImage);
        point.x += ix;
        point.y += iy;
    }
    CGContextFlush(ctx);
    drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    drawLayer.contents = (id)drawImage.CGImage;
}

- (void)commitDrawingWithOpacity:(CGFloat)opacity
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextTranslateCTM(contextRef, 0, -self.frame.size.height);
    if (mainImage != nil) {
#warning mainImage.CGImage
        CGContextDrawImage(contextRef, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), mainImage.CGImage);
    }
    CGContextSetAlpha(contextRef, opacity);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), drawImage.CGImage);
    mainImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.layer.contents = (id)mainImage.CGImage;
    drawImage = nil;
    drawLayer.contents = nil;
}
 
/*
- (void)commitDrawingWithOpacity:(CGFloat)opacity
{
    [self.drawLines addObject:drawImage];
//    UIGraphicsBeginImageContext(self.frame.size);
//    CGContextRef contextRef = UIGraphicsGetCurrentContext();
//    CGContextScaleCTM(contextRef, 1, -1);
//    CGContextTranslateCTM(contextRef, 0, -self.frame.size.height);
    if (self.drawLines.count >0) {
        for (UIImage * image in self.drawLines) {
//            CGContextDrawImage(contextRef, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), image.CGImage);
//            CGContextSetAlpha(contextRef, opacity);
            self.layer.contents = image.CIImage;
        }
    }
}
*/

- (void)paintTouchesBegan
{
    drawLayer.opacity = self.brushOpacity;
    [self drawLineFrom:lastPoint to:lastPoint withWidth:self.brushWidth];
}
- (void)paintTouchesMoved
{
    [self drawLineFrom:lastPoint to:currentPoint withWidth:self.brushWidth];
}
- (void)paintTouchesEnded
{
    [self commitDrawingWithOpacity:self.brushOpacity];
}
- (void)blurBrushTimerExpired:(NSTimer *)timer
{
    if ((lastPoint.x == blurPoint.x)&&(lastPoint.y == blurPoint.y)) {
        [self drawImage:blurImage at:lastPoint];
    }
    blurPoint = lastPoint;
}
- (void)blurBrushTouchesBegan
{
    UIGraphicsBeginImageContext(CGSizeMake(self.brushWidth, self.brushWidth));
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGFloat wd = self.brushWidth / 2;
    CGPoint pt = CGPointMake(wd, wd);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = {1.0, 0.0};
    CGFloat * comp = (CGFloat *)CGColorGetComponents(self.brushColor.CGColor);
    CGFloat fc = sinf(((self.brushBlur/5.0f)*M_PI)/2.0f);
    CGFloat colors[8] = { comp[0], comp[1], comp[2], 0.0f, comp[0], comp[1], comp[2], fc };
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorspace, colors, locations, num_locations);
    /**
     *  <#Description#>
     */
    CGContextDrawRadialGradient(contextRef, gradientRef, pt, 0, pt, wd, 0);
    CGContextFlush(contextRef);
    blurImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CFRelease(gradientRef);
    CFRelease(colorspace);
    
    blurPoint = CGPointMake(-5000, -5000);
    blurTimer = [NSTimer scheduledTimerWithTimeInterval:1/60 target:self selector:@selector(blurBrushTimerExpired:) userInfo:nil repeats:YES];
}
- (void)blurBrushTouchesMoved
{
    [self drawImage:blurImage from:lastPoint to:currentPoint];
}
- (void)blurBrushTouchesEnd
{
    [blurTimer invalidate];
    blurTimer = nil;
    blurImage = nil;
    [self commitDrawingWithOpacity:self.brushOpacity];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.userInteractionEnabled) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch * touch = [touches anyObject];
    lastPoint = [touch locationInView:self];
    lastPoint.y = self.frame.size.height - lastPoint.y;
    
    if (self.paintBoardToolType == 0) {
        [self paintTouchesBegan];
    }
    if (self.paintBoardToolType == PaintBoardToolTypeBlur) {
        [self blurBrushTouchesBegan];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.userInteractionEnabled) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    UITouch * touch = [touches anyObject];
    currentPoint = [touch locationInView:self];
    currentPoint.y = self.frame.size.height - currentPoint.y;
    
    if (self.paintBoardToolType == 0) {
        [self paintTouchesMoved];
    }
    if (self.paintBoardToolType == PaintBoardToolTypeBlur) {
        [self blurBrushTouchesMoved];
    }
    lastPoint = currentPoint;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.userInteractionEnabled) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    if (self.paintBoardToolType == 0) {
        [self paintTouchesEnded];
    }
    if (self.paintBoardToolType == PaintBoardToolTypeBlur) {
        [self blurBrushTouchesEnd];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.userInteractionEnabled) {
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    [self touchesEnded:touches withEvent:event];
}
#pragma mark -自定义方法-
- (void)clearColor:(UIColor *)color
{
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextAddRect(contextRef, rect);
    CGContextSetFillColorWithColor(contextRef, color.CGColor);
    CGContextFlush(contextRef);
    
    mainImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.layer.contents = mainImage;
}

- (UIImage *)getSketch
{
    return mainImage;
}
- (void)setSketch:(UIImage *)sketch
{
    mainImage = sketch;
    self.layer.contents = (id)sketch.CGImage;
}
//- (void)drop
//{
//    [self.dropLines addObject:[self.drawLines lastObject]];
//    [self.drawLines removeLastObject];
//    [self setNeedsDisplay];
//}
//- (void)back
//{
//    [self.drawLines addObject:[self.dropLines lastObject]];
//    [self.dropLines removeLastObject];
//    [self setNeedsDisplay];
//}
//- (void)clearColor:(UIColor *)color
//{
//    [self.drawLines removeAllObjects];
//}
@end
