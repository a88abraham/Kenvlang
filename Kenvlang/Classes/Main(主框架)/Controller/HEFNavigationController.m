//
//  HEFNavigationController.m
//  Kenvlang
//
//  Created by 贺恩发 on 16/1/26.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import "HEFNavigationController.h"

#define HEFNavigationBarTitleFont  [UIFont systemFontOfSize:18] //标题字体大小
#define HEFNavigationBarButtonFont [UIFont systemFontOfSize:14] //Tabbar字体大小
#define HEFKeyWindow [UIApplication sharedApplication].keyWindow


@interface HEFNavigationController ()<UINavigationControllerDelegate>

@end

@implementation HEFNavigationController

+ (void)initialize{
    //1.获取当前类下全局的UIBarButtonItem
    UIBarButtonItem *allNavigationItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[HEFNavigationController class]]];
    //设置按钮标题颜色、字体
    NSMutableDictionary *textAttributeForButton = [NSMutableDictionary dictionary];
    textAttributeForButton[NSForegroundColorAttributeName] = [UIColor yellowColor];
    textAttributeForButton[NSFontAttributeName] = HEFNavigationBarButtonFont;
    [allNavigationItem setTitleTextAttributes:textAttributeForButton forState:UIControlStateNormal];
    
    //2.获取当前类下全局的NavigationBar
    UINavigationBar *allNavigationBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]];

    //设置标题字体
    NSMutableDictionary *textAttributeForTitle = [NSMutableDictionary dictionary];
    textAttributeForTitle[NSFontAttributeName] = HEFNavigationBarTitleFont;
    [allNavigationBar setTitleTextAttributes:textAttributeForTitle];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航条背景图片
    [self.navigationBar setBackgroundImage:[UIImage stretchableImageNamed:@"tabbar_selected"] forBarMetrics:UIBarMetricsDefault];
    
    // 设置UINavigationControllerDelegate为self
    self.delegate = self;
}

#pragma mark - 实现delegate中的方法
// 清除系统tabBarButton上的badgeView (每次导航控制器跳转时显示VC前都会调用)
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
    
    //获取主窗口的根控制器tabBarController
    UITabBarController *tabBarController = (UITabBarController *)HEFKeyWindow.rootViewController;
    
    
    // 移除系统tabBarButton上的badgeView
    for (UIView *view in tabBarController.tabBar.subviews) {
        
        for (UIView *subview in view.subviews) {
            
            if ([subview isKindOfClass: NSClassFromString(@"_UIBadgeView")]) {
                
                [subview removeFromSuperview];
            }
        }
    }
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
