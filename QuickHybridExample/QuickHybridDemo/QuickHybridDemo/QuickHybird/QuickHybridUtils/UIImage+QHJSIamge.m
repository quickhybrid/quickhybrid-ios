//
//  UIImage+QHJSIamge.m
//  QuickHybridDemo
//
//  Created by guanhao on 2019/2/22.
//  Copyright © 2019年 com.quickhybrid. All rights reserved.
//

#import "UIImage+QHJSIamge.h"

@implementation UIImage (QHJSIamge)

+ (UIImage *)imageNamed:(NSString *)imageName inBundleName:(NSString *)bundleName {
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    
    NSString *imagePath = [bundlePath stringByAppendingPathComponent:imageName];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end
