//
//  QHJSNaviSegmentView.m
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/15.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import "QHJSNaviSegmentView.h"

@interface QHJSNaviSegmentView ()
//@property (nonatomic, strong) NSArray *titles;
//@property (nonatomic, strong) NSMutableArray *btnArray;

@property (nonatomic, strong) UISegmentedControl *segment;
@end

@implementation QHJSNaviSegmentView

- (instancetype)initWithTitleItems:(NSArray *)titles {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        _titles = titles;
        
        self.segment = [[UISegmentedControl alloc] initWithItems:titles];
        self.segment.selectedSegmentIndex = 0;
        [self.segment addTarget:self action:@selector(changeSegValue:) forControlEvents:(UIControlEventValueChanged)];
        [self addSubview:self.segment];
        
        self.frame = self.segment.bounds;
    }
    return self;
}

/**
 点击标题的方法
 */
- (void)changeSegValue:(UISegmentedControl *)sender {
    if (self.titleClickAction) {
        self.titleClickAction(sender.selectedSegmentIndex);
    }
}

//- (void)setSelectTitleItem:(NSInteger)which {
//    for (UIButton *btn in self.btnArray) {
//        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        btn.backgroundColor = [UIColor clearColor];
//    }
//
//    UIButton *selectedBtn = self.btnArray[which];
//    [selectedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    selectedBtn.backgroundColor = [UIColor blueColor];
//}

//- (NSMutableArray *)btnArray {
//    if (!_btnArray) {
//        _btnArray = [NSMutableArray arrayWithCapacity:2];
//    }
//    return _btnArray;
//}

@end
