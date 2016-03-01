//
//  HEFTabBarController.m
//  Kenvlang
//
//  Created by 贺恩发 on 16/1/26.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import "HEFTabBarController.h"
#import "MainHeader.h"
#import <Masonry.h>


#define tabBarCount 5.0         // tabBar个数

@interface HEFTabBarController (){

    CGRect _dockRect;
    NSArray *controllers;
    UINavigationController *allNavController;
    UIButton *shadeItem;
}

@property (nonatomic, strong) NSMutableArray *tabBarItems;
@property (nonatomic, weak) HEFCartViewController *cartVC; // cartVC的item(用于添加badgeView)
@property (nonatomic, weak) UITabBarItem *item;

@end

@implementation HEFTabBarController

//懒加载
- (NSMutableArray *)tabBarItems{
    
    if (_tabBarItems == nil) {
        _tabBarItems = [NSMutableArray array];
    }
    return _tabBarItems;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat tabBarWidth = self.tabBar.bounds.size.width;  // tabBar整体宽度
    
    CGSize indicatorImageSize = CGSizeMake(tabBarWidth / tabBarCount, self.tabBar.bounds.size.height);
    self.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_normal"]; //正常情况下item的背景图片
    self.tabBar.selectionIndicatorImage = [self drawTabBarItemBackgroundImageWithSize:indicatorImageSize]; //选中item后的背景色
    // 设置子控制器
    [self addChildViewControllers];

}
/**
 *  绘制选中item后的背景色  如果背景色更换 不用切图
 *
 *  @param size 图片大小
 *
 *  @return 绘制好的背景图片
 */
#pragma mark - 绘制选中item后的背景色
- (UIImage *)drawTabBarItemBackgroundImageWithSize:(CGSize)size{
    //准备绘制环境
    UIGraphicsBeginImageContext(size);
    
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    //绘制背景色
    CGContextSetRGBFillColor(ctr, 198.0 / 255, 37.0 / 255, 44.0 / 255, 1);
    
    CGContextFillRect(ctr, CGRectMake(0, 0, size.width, size.height));
    //获取该绘图中的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束绘图
    UIGraphicsEndImageContext();
    return image;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma mark - 添加多个子控制器
- (void)addChildViewControllers{

    // 首页
    HEFHomeViewController *homeVC = [[HEFHomeViewController alloc] init];
    /**
     *  添加首页子控制器
     *
     *  @param viewController 首页子控制器
     *  @param normalImage    未选中时的图片
     *  @param pressedImage   选中时的图片（后续可让UI直接切图实现）
     *  @param tbTitle        tabBarTitle
     *  @param nbTitle        navigationBarTitle
     */
    [self addOneChildViewController:homeVC
                        normalImage:[UIImage originalImageNamed:@"tabbar_home"]
                       pressedImage:nil
                        tabBarTitle:@"主页"
                 navigationBarTitle:@""];
    
    // 超级市场
    HEFSupermarketViewController *supermarketVC = [[HEFSupermarketViewController alloc] init];
    [self addOneChildViewController:supermarketVC
                        normalImage:[UIImage originalImageNamed:@"tabbar_supermarket"]
                       pressedImage:nil
                        tabBarTitle:@"超级市场"
                 navigationBarTitle:@""];
    
    
    // 鞋品区
    HEFShoesViewController *shoesVC = [[HEFShoesViewController alloc] init];
    [self addOneChildViewController:shoesVC
                        normalImage:[UIImage originalImageNamed:@"tabbar_shoes"]
                       pressedImage:nil
                        tabBarTitle:@"鞋品区"
                 navigationBarTitle:@""];
    
    // 购物车
    HEFCartViewController *cartVC = [[HEFCartViewController alloc] init];
    [self addOneChildViewController:cartVC
                        normalImage:[UIImage originalImageNamed:@"tabbar_cart"]
                       pressedImage:nil
                        tabBarTitle:@"购物车"
                 navigationBarTitle:@"购物车"];
    _cartVC = cartVC;
    
    // 个人中心
    HEFMyCenterViewController *MyVC = [[HEFMyCenterViewController alloc] init];

    [self addOneChildViewController:MyVC
                        normalImage:[UIImage originalImageNamed:@"tabbar_my"]
                       pressedImage:nil
                        tabBarTitle:@"个人中心"
                 navigationBarTitle:@"个人中心"];

}

#pragma mark - 添加1个子控制器
- (void)addOneChildViewController:(UIViewController *)viewController
                      normalImage:(UIImage *)normalImage
                     pressedImage:(UIImage *)pressedImage
                      tabBarTitle:(NSString *)tbTitle
               navigationBarTitle:(NSString *)nbTitle{
    
    // 设置子控制器导航条标题
    viewController.navigationItem.title = nbTitle;
    
    // 设置tabbar名称、图片
    viewController.tabBarItem = [viewController.tabBarItem initWithTitle:tbTitle image:normalImage selectedImage:pressedImage];
    // 设置tabbar字体的颜色为白色
    [viewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

    // 添加子控制器至导航控制器
    HEFNavigationController  *navigationVC
    = [[HEFNavigationController alloc] initWithRootViewController:viewController];
    
    // 添加导航控制器
    [self addChildViewController:navigationVC];
    
    // 添加tabBarItem至数组
    [self.tabBarItems addObject:viewController.tabBarItem];
    
}


@end
