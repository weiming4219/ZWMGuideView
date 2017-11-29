//
//  ZWMGuideView.h
//  ZWMGuideViewDemo
//
//  Created by 伟明 on 2017/11/28.
//  Copyright © 2017年 com.zhongzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZWMGuideView;

@protocol ZWMGuideViewDataSource <NSObject>
@required
/**
 Item的个数
 */
- (NSInteger)numberOfItemsInGuideMaskView:(ZWMGuideView *)guideMaskView;

/**
 每个Item对应的的view
 */
- (UIView *)guideMaskView:(ZWMGuideView *)guideMaskView viewForItemAtIndex:(NSInteger)index;

/**
 每个Item对应的的描述
 */
- (NSString *)guideMaskView:(ZWMGuideView *)guideMaskView descriptionLabelForItemAtIndex:(NSInteger)index;

@optional
/**
 描述文字的颜色：默认白色
 */
- (UIColor *)guideMaskView:(ZWMGuideView *)guideMaskView colorForDescriptionLabelAtIndex:(NSInteger)index;

/**
 描述文字的大小：默认15
 */
- (UIFont *)guideMaskView:(ZWMGuideView *)guideMaskView fontForDescriptionLabelAtIndex:(NSInteger)index;

@end


@protocol ZWMGuideViewLayoutDelegate <NSObject>
@optional

/**
 每个Item的蒙版的圆角:默认为5
 */
- (CGFloat)guideMaskView:(ZWMGuideView *)guideMaskView cornerRadiusForItemAtIndex:(NSInteger)index;

/**
 每个Item与蒙版的边距:默认为(-8, -8, -8, -8)
 */
- (UIEdgeInsets)guideMaskView:(ZWMGuideView *)guideMaskView insetsForItemAtIndex:(NSInteger)index;

/**
 每个Item的子视图的间距：默认为 10（子视图包括当前的view、arrowImage、textLabel）
 */
- (CGFloat)guideMaskView:(ZWMGuideView *)guideMaskView spaceForSubviewsAtIndex:(NSInteger)index;

/**
 每个Item的文字与左右边框的间距：默认为 50
 */
- (CGFloat)guideMaskView:(ZWMGuideView *)guideMaskView horizontalSpaceForDescriptionLabelAtIndex:(NSInteger)index;
@end

@interface ZWMGuideView : UIView
@property (strong, nonatomic) UIImage *arrowImage;
@property (strong, nonatomic) UIColor *maskBackgroundColor;
@property (assign, nonatomic) CGFloat maskAlpha;
@property (weak, nonatomic) id <ZWMGuideViewDataSource> dataSource;
@property (weak, nonatomic) id <ZWMGuideViewLayoutDelegate> delegate;

- (void)show;
@end
