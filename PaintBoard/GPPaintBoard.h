//
//  GPPaintBoard.h
//  PaintBoard
//
//  Created by MS on 15-9-7.
//  Copyright (c) 2015年 GaoPanpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
    PaintBoardToolTypeOrign = 0,
    PaintBoardToolTypeBlur
} PaintBoardToolType;

@interface GPPaintBoard : UIControl

@property (nonatomic,assign)PaintBoardToolType paintBoardToolType;

@property (nonatomic,assign)CGFloat brushWidth;

@property (nonatomic,assign)CGFloat brushBlur;

@property (nonatomic,assign)CGFloat brushOpacity;

@property (nonatomic,strong)UIColor *brushColor;

@property (nonatomic,strong)NSMutableArray * dropLines;

@property (nonatomic,strong)NSMutableArray * drawLines;

- (void)clearColor:(UIColor *)color;

- (UIImage *)getSketch;
- (void)setSketch:(UIImage *)sketch;
- (void)drop;
- (void)back;

@end
