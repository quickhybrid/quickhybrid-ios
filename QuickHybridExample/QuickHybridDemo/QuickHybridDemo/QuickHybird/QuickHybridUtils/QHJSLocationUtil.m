//
//  QHJSLocationUtil.m
//  QuickHybridDemo
//
//  Created by guanhao on 2019/3/6.
//  Copyright © 2019年 com.quickhybrid. All rights reserved.
//

#import "QHJSLocationUtil.h"

@interface QHJSLocationUtil () <CLLocationManagerDelegate>
/** 回调 */
@property (nonatomic, copy) locationBlock locationBlock;
/** 定位服务 */
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation QHJSLocationUtil

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        //定位不通知最小变化距离
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        //定位精度，HundredMeters 0.3s左右获取  NearestTenMeters 10s左右  Best更长
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //定位不通知最小变化角度
        _locationManager.headingFilter = kCLHeadingFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)startUpdateLocation:(locationBlock)locationBlock {
    self.locationBlock = locationBlock;
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        self.locationBlock(nil, @"手机GPS未打开");
        return;
    }
    
    //开启定位权限
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        //未开启定位时，先请求权限
        [self.locationManager requestWhenInUseAuthorization];
        return;
    }
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        self.locationBlock(nil, @"应用定位权限未打开");
        return;
    }
    
    //开始定位
    if (@available(iOS 9.0, *)) {
        [self.locationManager requestLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark --- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocationCoordinate2D coordinate = locations.lastObject.coordinate;
    NSLog(@"%f   %f", coordinate.longitude, coordinate.latitude);
    self.locationBlock(locations.lastObject, nil);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
    self.locationBlock(nil, error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //开始定位
    if (@available(iOS 9.0, *)) {
        [self.locationManager requestLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

//发送网络请求到百度，获取位置详细信息
+ (void)getBaiduLocationInfoInLocation:(CLLocationCoordinate2D)CLLocationCoordinate2D complete:(responseBlock)complete {
    //使用百度提供的云逆地理编码接口
    NSString *location = [NSString stringWithFormat:@"%f,%f", CLLocationCoordinate2D.latitude, CLLocationCoordinate2D.longitude];
    NSString *ak = @"请输入你的ak";
    NSString *geotable_id = @"使用云存储服务，存储自定义数据时生成的数据表ID";
    
//    NSString *url = [NSString stringWithFormat:@"http://api.map.baidu.com/cloudrgc/v1?location=%@&geotable_id=%@&coord_type=gcj02ll&ak=%@", location, geotable_id, ak];
    NSString *url = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder/v2/?location=%@&output=json&pois=1&ak=%@", location, ak];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            complete(nil, error);
        } else {
            NSError *jsonError = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                //json解析错误
                complete(nil, jsonError);
            } else {
                //回调请求结果
                complete(result, nil);
            }
        }
    }];
    [task resume];
}

- (void)dealloc {
    NSLog(@"<QHJSLocationUtil>dealloc");
}

@end
