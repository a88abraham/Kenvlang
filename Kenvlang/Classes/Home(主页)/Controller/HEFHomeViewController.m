//
//  HEFHomeViewController.m
//  Kenvlang
//
//  Created by 贺恩发 on 16/1/26.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import "HEFHomeViewController.h"
#import "HEFSupermarketViewController.h"

@interface HEFHomeViewController ()<UIWebViewDelegate>
@property (nonatomic, weak) UIActivityIndicatorView *loadingView;
@end

@implementation HEFHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"nav_01"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake((_WIDTH - image.size.width) / 2 , 0, image.size.width, 44);
    //将字体图片添加到导航栏上 不能用[[UINavigationBar appearance] addSubview:imageView];
    [self.navigationController.navigationBar addSubview:imageView];
    // 1. 创建webView, 展示首页
    UIWebView *homeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -50, _WIDTH,_HEIGHT)];
    // 添加代理  对webView的编辑
    homeWebView.delegate = self;
    // 根据屏幕大小自动调整页面尺寸
    homeWebView.scalesPageToFit = YES;
    // 禁止webView的滑动
    homeWebView.scrollView.bounces = NO;
    [self.view addSubview:homeWebView];
    // 2. 设置请求URL
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:__BASE_URL]];
    
    // 加载页面
    [homeWebView loadRequest:request];
    
    //3.创建一个加载蒙板
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView startAnimating];
    loadingView.center = CGPointMake(_WIDTH / 2, _HEIGHT / 2);
    
    [self.view addSubview:loadingView];
    self.loadingView = loadingView;
    
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 执行JS代码，将网页里面的多余的节点删掉
    NSMutableString *js1 = [NSMutableString string];
    // 0.删除顶部的导航条
    [js1 appendString:@"var header = document.getElementsByTagName('header')[0];"];
    [js1 appendString:@"header.parentNode.removeChild(header);"];
    
    // 1.删除底部的tabbar
    [js1 appendString:@"var footer = document.getElementsByTagName('footer')[0];"];
    [js1 appendString:@"footer.parentNode.removeChild(footer);"];

    // OC中调用js
    [webView stringByEvaluatingJavaScriptFromString:js1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableString *js2 = [NSMutableString string];
        // 2.删除浮动的广告
        [js2 appendString:@"var list = document.body.childNodes;"];
        [js2 appendString:@"var len = list.length;"];
        [js2 appendString:@"var banner = list[len - 1];"];
        [js2 appendString:@"banner.parentNode.removeChild(banner);"];
        [webView stringByEvaluatingJavaScriptFromString:js2];
        
        // 显示scrollView
        webView.scrollView.hidden = NO;
        
        // 删除圈圈
        [self.loadingView removeFromSuperview];
    });
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *requestString = [[request URL] absoluteString];
    
    if ([requestString rangeOfString:[NSString stringWithFormat:@"%@/Mobile/SeckillGoods/Index",__BASE_URL]].location != NSNotFound) {
        
        HEFSupermarketViewController *supermarketVC = [[HEFSupermarketViewController alloc] init];
        
        [self.navigationController pushViewController:supermarketVC animated:YES];
    }
    
    return YES;
    
    
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
