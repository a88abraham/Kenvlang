//
//  HEFShoesViewController.m
//  Kenvlang
//
//  Created by 贺恩发 on 16/1/26.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import "HEFShoesViewController.h"

@interface HEFShoesViewController ()<UIWebViewDelegate>
@property (nonatomic, weak) UIActivityIndicatorView *loadingView;


@end

@implementation HEFShoesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBar.hidden = YES;
    
    // 1. 创建webView, 展示首页
    UIWebView *homeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, _WIDTH,_HEIGHT)];
    // 添加代理  对webView的编辑
    homeWebView.delegate = self;
    // 根据屏幕大小自动调整页面尺寸
    homeWebView.scalesPageToFit = YES;
    // 禁止webView的滑动
    //homeWebView.scrollView.bounces = NO;
    [self.view addSubview:homeWebView];
    // 2. 设置请求URL
    
    NSString *urlString = [__BASE_URL stringByAppendingString:@"/Mobile/SeckillGoods/GoodsIndex?source=ios"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    // 加载页面
    [homeWebView loadRequest:request];
    
    //3.创建一个加载蒙板
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView startAnimating];
    loadingView.center = CGPointMake(_WIDTH / 2, _HEIGHT / 2);
    
    [self.view addSubview:loadingView];
    self.loadingView = loadingView;
    
    // Do any additional setup after loading the view.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 删除圈圈
    [self.loadingView removeFromSuperview];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
