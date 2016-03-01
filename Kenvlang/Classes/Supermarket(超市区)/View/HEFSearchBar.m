//
//  HEFSearchBar.m
//  Kenvlang
//
//  Created by 贺恩发 on 16/2/29.
//  Copyright © 2016年 kknx. All rights reserved.
//

#import "HEFSearchBar.h"

@implementation HEFSearchBar

-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if (self) {
        
        // 设置字体
        self.font = [UIFont systemFontOfSize:14];
        
        // 设置左边的view
        [self LeftView];
    }
    
    return self;
}

- (instancetype)init {
    // 设置frame
    CGFloat width = HEFMainScreenBounds.size.width - 110;
    CGFloat height = 30;
    CGFloat X = (HEFMainScreenBounds.size.width - width) * 0.5;
    CGFloat Y = 7;
    CGRect frame = CGRectMake(X, Y, width, height);
    
    return [self initWithFrame:frame];
}

// 设置左边的view
- (void)LeftView{
    
    // initWithImage:默认UIImageView的尺寸跟图片一样
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_search_bar"]];
    
    
    self.leftView = leftImageView;
    //  注意：一定要设置，想要显示搜索框左边的视图，一定要设置左边视图的模式
    self.leftViewMode = UITextFieldViewModeAlways;

}

/*
// 设置右边的view
- (void)setRightView {
    // 创建按钮
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"audio_nav_icon"] forState:UIControlStateNormal];
    [rightButton sizeToFit];
    // 将imageView宽度
    rightButton.frameWidth += 10;
    //居中
    rightButton.contentMode = UIViewContentModeCenter;
    
    
    self.rightView = rightButton;
    //  注意：一定要设置，想要显示搜索框左边的视图，一定要设置左边视图的模式
    self.rightViewMode = UITextFieldViewModeAlways;
}

*///待后续升级可能用
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
