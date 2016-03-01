//
//  UIBarButtonItem+HEFBarButtonItem.h
//  Kenvlang
//
//  Created by 贺恩发 on 16/2/29.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (HEFBarButtonItem)


/**
 *  快速创建一个UIBarButtonItem对象
 *
 *  @param backgroundImage  背景图片
 *  @param highlightedImage 高亮图片
 *  @param title            标题
 *  @param titleFont        标题字体大小
 *  @param target           动作目标
 *  @param action           动作
 *  @param controlEvents    事件类型
 *
 *  @return 一个UIBarButtonItem对象
 */
+ (instancetype)barButtonItemWithBackgroundImage:(UIImage *)backgroundImage
                                highlightedImage:(UIImage *)highlightedImage
                                           title:(NSString *)title
                                       titleFont:(CGFloat)fontSize
                                          target:(id)target
                                          action:(SEL)action
                                forControlEvents:(UIControlEvents)controlEvents;

@end
