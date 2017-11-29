//
//  ZWMGuideView.m
//  ZWMGuideViewDemo
//
//  Created by 伟明 on 2017/11/28.
//  Copyright © 2017年 com.zhongzhou. All rights reserved.
//

#import "ZWMGuideView.h"

typedef NS_ENUM(NSInteger, ZWMGuideMaskItemRegion)
{
    ZWMGuideMaskItemRegionLeftTop = 0,
    ZWMGuideMaskItemRegionLeftBottom,
    ZWMGuideMaskItemRegionRightTop,
    ZWMGuideMaskItemRegionRightBottom
};

@interface ZWMGuideView()
@property (strong, nonatomic) UIImageView *arrowImgView;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) CAShapeLayer *maskLayer;
@property (assign, nonatomic) NSInteger currentIndex;
@end

@implementation ZWMGuideView
{
    NSInteger _count; //记录items总数
}
#pragma mark - 懒加载
- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer)
    {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (UIView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _maskView;
}

- (UILabel *)textLabel
{
    if (!_textLabel)
    {
        _textLabel = [UILabel new];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (UIImageView *)arrowImgView
{
    if (!_arrowImgView)
    {
        _arrowImgView = [UIImageView new];
    }
    return _arrowImgView;
}

#pragma mark - Init Method
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    /// 添加子视图
    [self addSubview:self.maskView];
    [self addSubview:self.arrowImgView];
    [self addSubview:self.textLabel];
    
    /// 设置默认数据
    self.backgroundColor     = [UIColor clearColor];
    self.maskBackgroundColor = [UIColor blackColor];
    self.maskAlpha  = .7f;
    self.arrowImage = [UIImage imageNamed:@"arrow"];
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont systemFontOfSize:15];
}


#pragma mark - Setter Method
- (void)setArrowImage:(UIImage *)arrowImage
{
    _arrowImage = arrowImage;
    self.arrowImgView.image = arrowImage;
}

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor
{
    _maskBackgroundColor = maskBackgroundColor;
    self.maskView.backgroundColor = maskBackgroundColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha
{
    _maskAlpha = maskAlpha;
    self.maskView.alpha = maskAlpha;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self showMask];
    [self configureItemsFrame];
}

#pragma mark - Privite Method

/**
 *  显示蒙板
 */
- (void)showMask
{
    CGPathRef fromPath = self.maskLayer.path;
    
    /// 更新 maskLayer 的 尺寸
    self.maskLayer.frame = self.bounds;
    self.maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGFloat maskCornerRadius = 5;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMaskView:cornerRadiusForItemAtIndex:)])
    {
        maskCornerRadius = [self.delegate guideMaskView:self cornerRadiusForItemAtIndex:self.currentIndex];
    }
    
    /// 获取可见区域的路径(开始路径)
    UIBezierPath *visualPath = [UIBezierPath bezierPathWithRoundedRect:[self obtainVisualFrame] cornerRadius:maskCornerRadius];
    
    /// 获取终点路径
    UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    [toPath appendPath:visualPath];
    
    /// 遮罩的路径
    self.maskLayer.path = toPath.CGPath;
    self.maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.layer.mask = self.maskLayer;
    
    /// 开始移动动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.duration  = 0.3;
    anim.fromValue = (__bridge id _Nullable)(fromPath);
    anim.toValue   = (__bridge id _Nullable)(toPath.CGPath);
    [self.maskLayer addAnimation:anim forKey:NULL];
}

/**
 *  设置 items 的 frame
 */
- (void)configureItemsFrame
{
    // 文字颜色
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(guideMaskView:colorForDescriptionLabelAtIndex:)])
    {
        self.textLabel.textColor = [self.dataSource guideMaskView:self colorForDescriptionLabelAtIndex:self.currentIndex];
    }
    // 文字字体
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(guideMaskView:fontForDescriptionLabelAtIndex:)])
    {
        self.textLabel.font = [self.dataSource guideMaskView:self fontForDescriptionLabelAtIndex:self.currentIndex];
    }
    
    // 描述文字
    NSString *desc = [self.dataSource guideMaskView:self descriptionLabelForItemAtIndex:self.currentIndex];
    self.textLabel.text = desc;
    
    /// 每个 item 的文字与左右边框间的距离
    CGFloat descInsetsX = 50;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMaskView:horizontalSpaceForDescriptionLabelAtIndex:)])
    {
        descInsetsX = [self.delegate guideMaskView:self horizontalSpaceForDescriptionLabelAtIndex:self.currentIndex];
    }
    
    /// 每个 item 的子视图（当前介绍的子视图、箭头、描述文字）之间的间距
    CGFloat space = 10;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMaskView:spaceForSubviewsAtIndex:)])
    {
        space = [self.delegate guideMaskView:self spaceForSubviewsAtIndex:self.currentIndex];
    }
    
    /// 设置 文字 与 箭头的位置
    CGRect textRect, arrowRect;
    CGSize imgSize   = self.arrowImgView.image.size;
    CGFloat maxWidth = self.bounds.size.width - descInsetsX * 2;
    CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName : self.textLabel.font}
                                          context:NULL].size;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    /// 获取 item 的 方位
    ZWMGuideMaskItemRegion itemRegion = [self obtainVisualRegion];
    
    switch (itemRegion)
    {
        case ZWMGuideMaskItemRegionLeftTop:
        {
            /// 左上
            transform = CGAffineTransformMakeScale(-1, 1);
            arrowRect = CGRectMake(CGRectGetMidX([self obtainVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMaxY([self obtainVisualFrame]) + space,
                                   imgSize.width,
                                   imgSize.height);
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self obtainVisualFrame]))
            {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX;
            }
            
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);
            break;
        }
        case ZWMGuideMaskItemRegionRightTop:
        {
            /// 右上
            arrowRect = CGRectMake(CGRectGetMidX([self obtainVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMaxY([self obtainVisualFrame]) + space,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self obtainVisualFrame]))
            {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);
            break;
        }
        case ZWMGuideMaskItemRegionLeftBottom:
        {
            /// 左下
            transform = CGAffineTransformMakeScale(-1, -1);
            arrowRect = CGRectMake(CGRectGetMidX([self obtainVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMinY([self obtainVisualFrame]) - space - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self obtainVisualFrame]))
            {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
            break;
        }
        case ZWMGuideMaskItemRegionRightBottom:
        {
            /// 右下
            transform = CGAffineTransformMakeScale(1, -1);
            arrowRect = CGRectMake(CGRectGetMidX([self obtainVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMinY([self obtainVisualFrame]) - space - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self obtainVisualFrame]))
            {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
            break;
        }
    }
    
    /// 图片 和 文字的动画
    [UIView animateWithDuration:0.3 animations:^{
        self.arrowImgView.transform = transform;
        self.arrowImgView.frame = arrowRect;
        self.textLabel.frame = textRect;
    }];
}

/**
 *  获取可见的视图的frame
 */
- (CGRect)obtainVisualFrame
{
    if (self.currentIndex >= _count)
    {
        return CGRectZero;
    }
    
    UIView *view = [self.dataSource guideMaskView:self viewForItemAtIndex:self.currentIndex];
    
    CGRect visualRect = [self convertRect:view.frame fromView:view.superview];
    
    /// 每个 item 的 view 与蒙板的边距
    UIEdgeInsets maskInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMaskView:insetsForItemAtIndex:)])
    {
        [self.delegate guideMaskView:self insetsForItemAtIndex:self.currentIndex];
    }
    
    visualRect.origin.x += maskInsets.left;
    visualRect.origin.y += maskInsets.top;
    visualRect.size.width  -= (maskInsets.left + maskInsets.right);
    visualRect.size.height -= (maskInsets.top + maskInsets.bottom);
    
    return visualRect;
}

/**
 *  获取可见区域的方位
 */
- (ZWMGuideMaskItemRegion)obtainVisualRegion
{
    /// 可见区域的中心坐标
    CGPoint visualCenter = CGPointMake(CGRectGetMidX([self obtainVisualFrame]),
                                       CGRectGetMidY([self obtainVisualFrame]));
    /// self.view 的中心坐标
    CGPoint viewCenter   = CGPointMake(CGRectGetMidX(self.bounds),
                                       CGRectGetMidY(self.bounds));
    
    if ((visualCenter.x <= viewCenter.x)    &&
        (visualCenter.y <= viewCenter.y))
    {
        /// 当前显示的视图在左上角
        return ZWMGuideMaskItemRegionLeftTop;
    }
    
    if ((visualCenter.x > viewCenter.x)     &&
        (visualCenter.y <= viewCenter.y))
    {
        /// 当前显示的视图在右上角
        return ZWMGuideMaskItemRegionRightTop;
    }
    
    if ((visualCenter.x <= viewCenter.x)    &&
        (visualCenter.y > viewCenter.y))
    {
        /// 当前显示的视图在左下角
        return ZWMGuideMaskItemRegionLeftBottom;
    }
    
    /// 当前显示的视图在右下角
    return ZWMGuideMaskItemRegionRightBottom;
}


#pragma mark - Public Method

/**
 *  显示
 */
- (void)show
{
    if (self.dataSource)
    {
        _count = [self.dataSource numberOfItemsInGuideMaskView:self];
    }
    
    /// 如果当前没有可以显示的 item 的数量
    if (_count < 1)  return;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.alpha = 0;
    
    [UIView animateWithDuration:.3f animations:^{
        
        self.alpha = 1;
    }];
    
    /// 从 0 开始进行显示
    self.currentIndex = 0;
}

#pragma mark - Action Method

/**
 *  隐藏
 */
- (void)hide
{
    [UIView animateWithDuration:.3f animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /**
     *  如果当前下标不是最后一个，则移到下一个介绍的视图
     *  如果当前下标是最后一个，则直接返回
     */
    if (self.currentIndex < _count-1)
    {
        self.currentIndex ++;
    }
    else
    {
        [self hide];
    }
}

@end
