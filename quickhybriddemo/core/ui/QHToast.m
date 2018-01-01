//
//  QHToast.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHToast.h"

#define titleFont [UIFont systemFontOfSize:16]

@interface QHToast ()

/**
 提示信息
 */
@property (nonatomic, copy) NSString *message;

/**
 持续时间
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end

@implementation QHToast
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (NSTimeInterval)duration {
    
    if (!_duration) {
        _duration = 2;
    }
    return _duration;
}


+ (QHToast *)toastMessage:(NSString *)message duration:(NSTimeInterval)duration {
    // 如果message为空，直接返回
    if (message.length == 0) { return nil; }
    
    UIView *contextView = [UIApplication sharedApplication].keyWindow;
    CGSize toastSize = [message boundingRectWithSize:CGSizeMake(contextView.frame.size.width - 20 * 2, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:titleFont} context:nil].size;
    toastSize.width = toastSize.width + 20;
    CGFloat toastX = (contextView.frame.size.width - toastSize.width) / 2;
    CGFloat toastH = toastSize.height + 25;
    CGFloat toastY = contextView.frame.size.height / 2;
    CGFloat toastW = toastSize.width;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(toastX, toastY, toastW, toastH)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:86 / 255.0 green:92 / 255.0 blue:106 / 255.0 alpha:0.95];
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.numberOfLines = 0;
    
    
    QHToast *toast = [[QHToast alloc] initWithFrame:contextView.frame];
    toast.backgroundColor = [UIColor clearColor];
    toast.userInteractionEnabled = YES;
    toast.alpha = 0;
    toast.duration = duration;
    [toast addSubview:label];
    
    return toast;
}

- (void)show {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.frame];
    [btn addTarget:self action:@selector(dismissFromSuperView:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        UIView *contextView = [UIApplication sharedApplication].keyWindow;
        [contextView addSubview:self];
        [contextView addSubview:btn];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:self.duration options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [btn removeFromSuperview];
        }];
    }];
    
}


-(void)dismissFromSuperView:(UIButton *) sender
{
    [UIView commitAnimations];
    [self removeFromSuperview];
    [sender removeFromSuperview];
}

@end
