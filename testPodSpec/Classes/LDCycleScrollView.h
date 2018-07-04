//
//  LDCycleScrollView.h
//  QTTableKit
//
//  Created by cxs on 2018/4/19.
//  Copyright © 2018年 Leo Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LDCycleScrollViewDirection) {
    LDCycleScrollViewDirectionVertical,   //  垂直滚动
    LDCycleScrollViewDirectionHorizontal      // 水平滚动
};
@interface LDCycleItem : NSObject
@property(nonatomic, strong) UIImage *image;   //本地图片
@property (nonatomic, copy) void(^didSelectedBlock)(void);
@end

/**
 轮播效果：
 
 */

@interface LDCycleScrollView : UIView

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame items:(NSArray<LDCycleItem *> *)itemsArray direction:(LDCycleScrollViewDirection)direction;

/** 自动滚动间隔时间,默认2s */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

@end

