//
//  QHJSDeviceInfo.m
//  QuickHybridDemo
//
//  Created by 管浩 on 2019/3/6.
//  Copyright © 2019年 com.quickhybrid. All rights reserved.
//

#import "QHJSDeviceInfo.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"
#import <sys/utsname.h>

@implementation QHJSDeviceInfo

//获取设备id
+ (NSString *)getDeviceId {
    NSString *userName = @"DeviceID";
    NSString *serviceName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    NSError *error = nil;
    NSString *uuid = [SFHFKeychainUtils getPasswordForUsername:userName andServiceName:serviceName error:&error];
    if (uuid.length > 0) {
        return uuid;
    } else {
        [SFHFKeychainUtils storeUsername:userName andPassword:[self createUUID] forServiceName:serviceName updateExisting:YES error:&error];
        uuid = [SFHFKeychainUtils getPasswordForUsername:userName andServiceName:serviceName error:&error];
        if (uuid == nil) {
            uuid = @"";
        }
        return uuid;
    }
}

/**
 生成uuid
 */
+ (NSString *)createUUID {
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    CFRelease(uuidObject);
    return uuidStr;
}

//获取网络状态
+ (NSNumber *)getNetWorkType {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    NSInteger net = -1;
    switch (internetStatus) {
        case ReachableViaWiFi:
            net = 1;
            break;
        case ReachableViaWWAN:
            net = 0;
            break;
        case NotReachable:
            net = -1;
        default:
            break;
    }
    return @(net);
}

//获取设备整体状态
+ (NSDictionary *)getDeviceInfo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[self UAInfo] forKey:@"uaInfo"];
    [dic setObject:[self getScreenPixel] forKey:@"pixel"];
    [dic setObject:[self getDeviceId] forKey:@"deviceId"];
    [dic setObject:[self getNetWorkType] forKey:@"netWorkType"];
    return dic;
}

+ (NSString *)UAInfo {
    NSString *systemName = [UIDevice currentDevice].systemName;
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return [NSString stringWithFormat:@"%@ %@", platform, systemName];
}

+ (NSString *)getScreenPixel {
    CGRect nativeBounds = [UIScreen mainScreen].nativeBounds;
    return [NSString stringWithFormat:@"%.0f*%.0f", nativeBounds.size.width, nativeBounds.size.height];
}

+ (NSString *)allDeviceScreenPixel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"480*320";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"480*320";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"480*320";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"960*640";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"960*640";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"960*640";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"960*640";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"1136*640";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"1136*640";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"1136*640";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"1136*640";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"1136*640";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"1136*640";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"1920*1080";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"1334*750";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"1334*750";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"1920*1080";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"1136*640";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"1334*750";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"1920*1080";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"480*320";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"480*320";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"480*320";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"960*640";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"1136*640";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"1024*768";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,7"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,8"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad4,9"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad5,1"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad5,2"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad5,3"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad5,4"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad6,3"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad6,4"])   return @"2048*1536";
    
    if ([platform isEqualToString:@"iPad6,7"])   return @"2732*2048";
    
    if ([platform isEqualToString:@"iPad6,8"])   return @"2732*2048";
    
    //    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    //    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return @"";
}

@end
