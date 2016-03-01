//
//  UIBarButtonItem+HEFBarButtonItem.m
//  Kenvlang
//
//  Created by 贺恩发 on 16/2/29.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import "UIBarButtonItem+HEFBarButtonItem.h"

@implementation UIBarButtonItem (HEFBarButtonItem)

+ (instancetype)barButtonItemWithBackgroundImage:(UIImage *)backgroundImage
                                highlightedImage:(UIImage *)highlightedImage
                                          target:(id)target
                                          action:(SEL)action
                                forControlEvents:(UIControlEvents)controlEvents {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    if (highlightedImage != nil) {
        
        [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    // 必须要设置控件尺寸，这里选择根据内容自适应
    [button sizeToFit];
    
    //点击事件
    [button addTarget:target action:action forControlEvents:controlEvents];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}
@end
