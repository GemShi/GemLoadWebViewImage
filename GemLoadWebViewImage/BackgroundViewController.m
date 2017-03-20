//
//  BackgroundViewController.m
//  GemLoadWebViewImage
//
//  Created by GemShi on 2017/3/19.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import "BackgroundViewController.h"
#import "UIImageView+WebCache.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface BackgroundViewController ()<UIScrollViewDelegate>

@end

@implementation BackgroundViewController
{
    UIScrollView *_scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createUI
{
    self.view.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToDismissView:)];
    [self.view addGestureRecognizer:tapToDismiss];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _scrollView.contentSize = CGSizeMake(kScreenWidth * _imgArray.count, kScreenHeight);
    _scrollView.contentOffset = CGPointMake(_index * kScreenWidth, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < _imgArray.count; i++) {
        UIScrollView *subScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(kScreenWidth * i, 0, kScreenWidth, kScreenHeight)];
        subScrollView.maximumZoomScale = 3.0;
        subScrollView.delegate = self;
        subScrollView.showsHorizontalScrollIndicator = NO;
        subScrollView.showsVerticalScrollIndicator = NO;
        [_scrollView addSubview:subScrollView];
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [imgView sd_setImageWithURL:[NSURL URLWithString:_imgArray[i]] placeholderImage:[UIImage imageNamed:@"xcode"]];
        [subScrollView addSubview:imgView];
    }
}

-(void)tapToDismissView:(UITapGestureRecognizer *)tap
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - delegateMethod
//用户使用捏合手势时调用
//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIView *view = [scrollView.subviews lastObject];
    return view;
}

@end
