//
//  GPMainViewController.m
//  PaintBoard
//
//  Created by MS on 15-9-7.
//  Copyright (c) 2015年 GaoPanpan. All rights reserved.
//

#import "GPMainViewController.h"
#import "GPPaintBoard.h"

@interface GPMainViewController ()<UIAlertViewDelegate>
//画板
@property (strong, nonatomic) IBOutlet GPPaintBoard *paintBoard;
//模糊度
@property (weak, nonatomic) IBOutlet UISlider *blur;
//设置粗细
- (IBAction)setWidth:(id)sender;
//设置透明度
- (IBAction)setOpacity:(id)sender;
//清除
- (IBAction)clearPainting:(id)sender;
//选择画板
- (IBAction)selectPaintView:(UIButton *)sender;
//选择颜色
- (IBAction)setColor:(id)sender;
//P
- (IBAction)paint:(id)sender;
//B
- (IBAction)blur:(id)sender;
//撤销
- (IBAction)revoke:(id)sender;

@end

@implementation GPMainViewController
{
    NSInteger curImage;
    UIImage * image[3];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //实例化
    for (int i = 0; i<3; i++) {
        image[i] = nil;
    }
    curImage = 0;
    //旋转
    self.blur.transform= CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -130, -70);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    [self setPaintBoard:nil];
    [self setBlur:nil];
    [super viewDidUnload];
    self.paintBoard.backgroundColor = [UIColor whiteColor];
}
- (IBAction)setWidth:(id)sender {
    UISlider * slider = (UISlider *)sender;
    self.paintBoard.brushWidth = slider.value;
}

- (IBAction)setOpacity:(id)sender {
    UISlider * slider = (UISlider *)sender;
    self.paintBoard.brushOpacity = slider.value;
}

- (IBAction)clearPainting:(id)sender {
    [self.paintBoard clearColor:[UIColor whiteColor]];
}

- (IBAction)selectPaintView:(UIButton *)sender {
    image[curImage] = [self.paintBoard getSketch];
    UIButton * button = sender;
    curImage = button.tag;
    [self.paintBoard setSketch:image[curImage]];
}

- (IBAction)paint:(id)sender {
    self.paintBoard.paintBoardToolType = PaintBoardToolTypeOrign;
}

- (IBAction)setColor:(id)sender {
    UIButton * button = (UIButton *)sender;
    self.paintBoard.brushColor = button.backgroundColor;
    
}

- (IBAction)blur:(id)sender {
    self.paintBoard.paintBoardToolType = PaintBoardToolTypeBlur;
}

- (IBAction)revoke:(id)sender {
    if(self.paintBoard.backgroundColor == [UIColor whiteColor])
    {
        UIAlertView * alterView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有需要撤销的线条" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        alterView.frame = CGRectMake(375/2-alterView.bounds.size.width/2, 677/2-alterView.bounds.size.height, 10, 10);
        [self.paintBoard addSubview:alterView];
        [alterView show];
    }else
        self.paintBoard.brushColor = self.paintBoard.backgroundColor;
    
}

@end
