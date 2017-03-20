//
//  ViewController.m
//  GemLoadWebViewImage
//
//  Created by GemShi on 2017/3/18.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import "ViewController.h"
#import "BackgroundViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)NSMutableArray *array;
@property(nonatomic,strong)NSMutableArray *picArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initData];
    [self createWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    self.array = [[NSMutableArray alloc]init];
    self.picArray = [[NSMutableArray alloc]init];
}

-(void)createWebView
{
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.webView.delegate = self;
    [self.view addSubview:_webView];
    self.webView.scalesPageToFit = YES;
    NSURL *url = [NSURL URLWithString:@"https://m.toutiao.com/i6398761320518255106/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - 图片预览
-(void)loadBigImageWithURL:(NSString *)str
{
    NSUInteger index = 0;
    for (NSString *s in _picArray) {
        if ([s isEqualToString:str]) {
            index = [_picArray indexOfObject:s];
        }
    }
    BackgroundViewController *bgVC = [[BackgroundViewController alloc]init];
    bgVC.imgArray = _picArray;
    bgVC.index = index;
    [self presentViewController:bgVC animated:YES completion:nil];
}

#pragma mark - delegateMethod
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (_picArray.count == 0 && _array.count > 0) {
        for (NSString *str in _array) {
            NSArray *arr = [str componentsSeparatedByString:@"/"];
            if (arr.count > 0 && arr.count > 3) {
                if ([arr[2] isEqualToString:@"p.pstatp.com"] && [arr[3] isEqualToString:@"large"]) {
                    [self.picArray addObject:str];
                }
            }
        }
    }
    
    //通过JS，添加了点击事件之后，每次点击图片会执行这个方法，截取非正常的URL
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString *path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]];
        NSArray *array = [path componentsSeparatedByString:@"/"];
        if ([array[2] isEqualToString:@"p.pstatp.com"] && [array[3] isEqualToString:@"large"]) {
            //预览图片
            [self loadBigImageWithURL:path];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //获取webView中所有的图片
    static NSString *jsGetImageStr = @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    [self.webView stringByEvaluatingJavaScriptFromString:jsGetImageStr];
    NSString *imageStr = [self.webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    _array = [NSMutableArray arrayWithArray:[imageStr componentsSeparatedByString:@"+"]];
    
    //添加图片可点击js
    static NSString *jsAddClickStr = @"function registerImageClickAction(){\
    var imgs=document.getElementsByTagName('img');\
    var length=imgs.length;\
    for(var i=0;i<length;i++){\
    img=imgs[i];\
    img.onclick=function(){\
    window.location.href='image-preview:'+this.src}\
    }\
    }";
    [self.webView stringByEvaluatingJavaScriptFromString:jsAddClickStr];
    [self.webView stringByEvaluatingJavaScriptFromString:@"registerImageClickAction();"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end
