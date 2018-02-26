//
//  QHJSDatePickViewController.m
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/12.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import "QHJSDatePickViewController.h"

#define btnWidth 50
#define btnHeight 44
#define viewHeight 260

@interface QHJSDatePickViewController ()
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) UIDatePicker *datePicker;
@end

@implementation QHJSDatePickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //动画效果
    [UIView animateWithDuration:0.25 delay:0 options:7 animations:^{
        CGRect frame = self.containerView.frame;
        frame.origin.y = CGRectGetHeight(self.view.frame) - viewHeight;
        self.containerView.frame = frame;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //动画效果
    [UIView animateWithDuration:0.25 delay:0 options:7 animations:^{
        CGRect frame = self.containerView.frame;
        frame.origin.y = CGRectGetHeight(self.view.frame);
        self.containerView.frame = frame;
        [self.view layoutIfNeeded];
    } completion:nil];
}

//初始化view
- (void)initView {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), viewHeight)];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    _containerView = containerView;
    
    //取消和确定按钮
    UIButton *cancelBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    cancelBtn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
    [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancelBtn addTarget:self action:@selector(clickCancelButton:) forControlEvents:(UIControlEventTouchUpInside)];
    [containerView addSubview:cancelBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
    okBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - btnWidth, 0, btnWidth, btnHeight);
    [okBtn setTitle:@"确认" forState:(UIControlStateNormal)];
    [okBtn addTarget:self action:@selector(clickOKButton:) forControlEvents:(UIControlEventTouchUpInside)];
    [containerView addSubview:okBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 8, 0, CGRectGetMinX(okBtn.frame) - CGRectGetMaxX(cancelBtn.frame) - 8 * 2, btnHeight)];
    titleLabel.text = self.titleStr;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:17];
    [containerView addSubview:titleLabel];
    
    //datepicker
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(cancelBtn.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(containerView.frame) - CGRectGetHeight(cancelBtn.frame))];
    _datePicker = datePicker;
    
    NSString *format = @"";
    if (self.datePickerMode == QHJSDatePickerModeTime) {
        datePicker.datePickerMode = UIDatePickerModeTime;
        format = @"HH:mm";
    } else if (self.datePickerMode == QHJSDatePickerDate) {
        datePicker.datePickerMode = UIDatePickerModeDate;
        format = @"yyyy-MM-dd";
    } else if (self.datePickerMode == QHJSDatePickerDateAndTime) {
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        format = @"yyyy-MM-dd HH:mm";
    }
    if (self.defaultDateTime) {
        NSDate *defauleDate = [self dateFromString:self.defaultDateTime withFormat:format];
        [datePicker setDate:defauleDate];
    }
    
    [containerView addSubview:datePicker];
}

//点击取消按钮
- (void)clickCancelButton:(id)sender {
    [self dismiss];
}

//点击确认按钮
- (void)clickOKButton:(id)sender {
    NSString *format = @"";
    if (self.datePickerMode == QHJSDatePickerModeTime) {
        format = @"HH:mm";
    } else if (self.datePickerMode == QHJSDatePickerDate) {
        format = @"yyyy-MM-dd";
    } else if (self.datePickerMode == QHJSDatePickerDateAndTime) {
        format = @"yyyy-MM-dd HH:mm";
    }
    NSString *timeStr = [self stringFromDate:self.datePicker.date withFormat:format];
    self.selectBlock(timeStr);
    [self dismiss];
}

- (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSDate *)dateFromString:(NSString *)dateStr withFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
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
