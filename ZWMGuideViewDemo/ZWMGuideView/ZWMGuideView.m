//
//  ZWMGuideView.m
//  ZWMGuideViewDemo
//
//  Created by 伟明 on 2017/11/28.
//  Copyright © 2017年 com.zhongzhou. All rights reserved.
//

#import "ZWMGuideView.h"

#define ZWMNormal_RectMargin -4
#define ZWMNormal_TextSpace 15
#define ZWMNormal_ViewSpace 8
#define ZWMNormal_CornerRadius 5


typedef NS_ENUM(NSInteger, ZWMGuideMaskItemRegion)
{
    ZWMGuideMaskItemRegionLeftTop = 0,
    ZWMGuideMaskItemRegionLeftBottom,
    ZWMGuideMaskItemRegionRightTop,
    ZWMGuideMaskItemRegionRightBottom,
    ZWMGuideMaskItemRegionLeft,
    ZWMGuideMaskItemRegionRight
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
    
    CGFloat maskCornerRadius = ZWMNormal_CornerRadius;
    
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
    self.textLabel.text = desc?:@"";
    
    /// 每个 item 的文字与左右边框间的距离
    CGFloat descInsetsX = ZWMNormal_TextSpace;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMaskView:horizontalSpaceForDescriptionLabelAtIndex:)])
    {
        descInsetsX = [self.delegate guideMaskView:self horizontalSpaceForDescriptionLabelAtIndex:self.currentIndex];
    }
    
    /// 每个 item 的子视图（当前介绍的子视图、箭头、描述文字）之间的间距
    CGFloat space = ZWMNormal_ViewSpace;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMaskView:spaceForSubviewsAtIndex:)])
    {
        space = [self.delegate guideMaskView:self spaceForSubviewsAtIndex:self.currentIndex];
    }
    
    /// 设置 文字 与 箭头的位置
    CGRect textRect, arrowRect;
    CGSize imgSize   = self.arrowImgView.image.size;
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect obtainFrame = [self obtainVisualFrame];
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = self.textLabel.lineBreakMode; // NSLineBreakByWordWrapping;
    NSDictionary *attrs = @{NSFontAttributeName : self.textLabel.font, NSParagraphStyleAttributeName : paragraphStyle};

    /// 获取 item 的 方位
    ZWMGuideMaskItemRegion itemRegion = [self obtainVisualRegion];

    switch (itemRegion)
    {
        case ZWMGuideMaskItemRegionLeftTop:
        {
            /// 左上
            transform = CGAffineTransformMakeScale(-1, 1);
            arrowRect = CGRectMake(CGRectGetMidX(obtainFrame) - imgSize.width * 0.5,
                                   CGRectGetMaxY(obtainFrame) + space,
                                   imgSize.width, imgSize.height);

            CGFloat maxWidth = CGRectGetWidth(self.bounds) - descInsetsX * 2;
            CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:NULL].size;

            // 文字位置左下方.
            CGFloat x = CGRectGetMidX(obtainFrame) - textSize.width * 0.5;
            if (x<descInsetsX) {
                x = descInsetsX;
            }
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);

            CGFloat disHeight = CGRectGetHeight(self.bounds) - CGRectGetMaxY(textRect)-space;
            if (disHeight< 0) {
                if (-disHeight <= space*2) {
                    arrowRect.origin.y += disHeight/2;
                    textRect.origin.y += disHeight;
                }else{
                    arrowRect = CGRectZero;
                    if (CGRectGetMaxY(obtainFrame)+space +textSize.height <= CGRectGetHeight(self.bounds)) {
                        textRect.origin.y = CGRectGetMaxY(obtainFrame)+space;
                    }else{
                        textRect.origin.y = CGRectGetMaxY(obtainFrame);
                    }
                }
            }
            
        } break;
        case ZWMGuideMaskItemRegionRightTop:
        {
            /// 右上
            arrowRect = CGRectMake(CGRectGetMidX(obtainFrame) - imgSize.width * 0.5,
                                   CGRectGetMaxY(obtainFrame) + space,
                                   imgSize.width, imgSize.height);

            CGFloat maxWidth = CGRectGetWidth(self.bounds) - descInsetsX * 2;
            CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:NULL].size;

            CGFloat x = CGRectGetMidX(obtainFrame)-textSize.width/2;
            if (x+textSize.width >CGRectGetWidth(self.bounds)-descInsetsX) {
                x = CGRectGetWidth(self.bounds)-descInsetsX-textSize.width;
            }
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);

            CGFloat disHeight = CGRectGetHeight(self.bounds) - CGRectGetMaxY(textRect)-space;
            if (disHeight< 0) {
                if (-disHeight <= space*2) {
                    arrowRect.origin.y += disHeight/2;
                    textRect.origin.y += disHeight;
                }else{
                    arrowRect = CGRectZero;
                    if (CGRectGetMaxY(obtainFrame)+space +textSize.height <= CGRectGetHeight(self.bounds)) {
                        textRect.origin.y = CGRectGetMaxY(obtainFrame)+space;
                    }else{
                        textRect.origin.y = CGRectGetMaxY(obtainFrame);
                    }
                }
            }
            
        } break;
        case ZWMGuideMaskItemRegionLeftBottom:
        {
            /// 左下
            transform = CGAffineTransformMakeScale(-1, -1);
            arrowRect = CGRectMake(CGRectGetMidX(obtainFrame) - imgSize.width * 0.5,
                                   CGRectGetMinY(obtainFrame) - space - imgSize.height,
                                   imgSize.width, imgSize.height);

            CGFloat maxWidth = CGRectGetWidth(self.bounds) - descInsetsX * 2;
            CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:NULL].size;

            CGFloat x = CGRectGetMidX(obtainFrame) - textSize.width * 0.5;
            if (x<descInsetsX) {
                x = descInsetsX;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);

            CGFloat disWidth = textRect.origin.y;
            if (disWidth< 0) {
                arrowRect.origin.x -= disWidth;
                textRect.origin.x -= disWidth;
            }
            
            CGFloat disHeight = CGRectGetHeight(self.bounds) - CGRectGetMinY(textRect)-space - textSize.height;
            if (disHeight< 0) {
                if (-disHeight <= space*2) {
                    arrowRect.origin.y -= disHeight/2;
                    textRect.origin.y -= disHeight;
                }else{
                    arrowRect = CGRectZero;
                    if (CGRectGetMinY(obtainFrame)-space -textSize.height >= 0) {
                        textRect.origin.y = CGRectGetMinY(obtainFrame)-space;
                    }else{
                        textRect.origin.y = CGRectGetMinY(obtainFrame);
                    }
                }
            }
            
        } break;
        case ZWMGuideMaskItemRegionRightBottom:
        {
            /// 右下
            transform = CGAffineTransformMakeScale(1, -1);
            arrowRect = CGRectMake(CGRectGetMidX(obtainFrame) - imgSize.width * 0.5,
                                   CGRectGetMinY(obtainFrame) - space - imgSize.height,
                                   imgSize.width, imgSize.height);

            CGFloat maxWidth = CGRectGetWidth(self.bounds) - descInsetsX * 2;
            CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:NULL].size;

            CGFloat x = CGRectGetMidX(obtainFrame) - textSize.width/2;
            if (x+textSize.width > CGRectGetWidth(self.bounds) - descInsetsX) {
                x = descInsetsX;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
            
            CGFloat disHeight = CGRectGetHeight(self.bounds) - CGRectGetMinY(textRect)-space - textSize.height;
            if (disHeight< 0) {
                if (-disHeight <= space*2) {
                    arrowRect.origin.y -= disHeight/2;
                    textRect.origin.y -= disHeight;
                }else{
                    arrowRect = CGRectZero;
                    if (CGRectGetMinY(obtainFrame)-space -textSize.height >= 0) {
                        textRect.origin.y = CGRectGetMinY(obtainFrame)-space;
                    }else{
                        textRect.origin.y = CGRectGetMinY(obtainFrame);
                    }
                }
            }
           
        } break;

        case ZWMGuideMaskItemRegionLeft: {

            transform = CGAffineTransformMakeRotation(M_PI*1.5); // 旋转 270
            arrowRect = CGRectMake(CGRectGetMaxX(obtainFrame) + space,
                                   CGRectGetMidY(obtainFrame) -imgSize.height/2,
                                   imgSize.width, imgSize.height);

            CGFloat maxWidth = CGRectGetWidth(self.bounds) - CGRectGetMaxX(arrowRect) - space - descInsetsX;
            CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:NULL].size;

            CGFloat x = CGRectGetMaxX(arrowRect) + space;
            textRect = CGRectMake(x, CGRectGetMidY(obtainFrame)-textSize.height/2, textSize.width, textSize.height);

            if (textSize.height > CGRectGetHeight(self.bounds)-descInsetsX*2) {
                if (textSize.height <= CGRectGetHeight(self.bounds)) {
                    textRect.origin.y = (CGRectGetHeight(self.bounds)-textSize.height)/2;
                }else{
                    textRect.origin.y = 0;
                }
            }else{
                if (CGRectGetMinY(textRect)<descInsetsX) {
                    textRect.origin.y = descInsetsX;
                }else if(CGRectGetHeight(self.bounds)-CGRectGetMaxY(textRect) < descInsetsX){
                    textRect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect) - descInsetsX;
                }
            }
            
        } break;
            
        case ZWMGuideMaskItemRegionRight: {
            transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1), M_PI*0.5); // 旋转 90
            arrowRect = CGRectMake(CGRectGetMinX(obtainFrame)-imgSize.width-space,
                                   CGRectGetMidY(obtainFrame),
                                   imgSize.width, imgSize.height);

            CGFloat maxWidth = CGRectGetMinX(arrowRect) - space - descInsetsX;
            CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:NULL].size;

            CGFloat x = CGRectGetMinX(arrowRect) - space - textSize.width;
            
            textRect = CGRectMake(x, CGRectGetMidY(obtainFrame)-textSize.height/2, textSize.width, textSize.height);

            if (textSize.height > CGRectGetHeight(self.bounds)-descInsetsX*2) {
                if (textSize.height <= CGRectGetHeight(self.bounds)) {
                    textRect.origin.y = (CGRectGetHeight(self.bounds)-textSize.height)/2;
                }else{
                    textRect.origin.y = 0;
                }
            }else{
                if (CGRectGetMinY(textRect)<descInsetsX) {
                    textRect.origin.y = descInsetsX;
                }else if(CGRectGetHeight(self.bounds)-CGRectGetMaxY(textRect) < descInsetsX){
                    textRect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect) - descInsetsX;
                }
            }
           
        } break;
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

    CGRect visualRect = CGRectZero;
    if ([view isKindOfClass:[UIView class]]) {
        visualRect = [self convertRect:view.frame fromView:view.superview];
    }else if ([view isKindOfClass:[NSValue class]]){
        visualRect = [((NSValue *)view) CGRectValue];
    }else{
        CGRectMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2, 1, 1);
    }
    
    /// 每个 item 的 view 与蒙板的边距
    UIEdgeInsets maskInsets = UIEdgeInsetsMake(ZWMNormal_RectMargin,ZWMNormal_RectMargin,ZWMNormal_RectMargin,ZWMNormal_RectMargin);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMaskView:insetsForItemAtIndex:)])
    {
        maskInsets = [self.delegate guideMaskView:self insetsForItemAtIndex:self.currentIndex];
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
    CGRect obtainFrame = [self obtainVisualFrame];
    /// 可见区域的中心坐标
    CGPoint visualCenter = CGPointMake(CGRectGetMidX(obtainFrame), CGRectGetMidY(obtainFrame));
    /// self.view 的中心坐标
    CGPoint viewCenter   = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    if ((visualCenter.x <= viewCenter.x)    && (visualCenter.y <= viewCenter.y))
    {
        CGFloat spaceX = CGRectGetWidth(self.bounds)-CGRectGetMaxX(obtainFrame);
        CGFloat spaceY = CGRectGetHeight(self.bounds)-CGRectGetMaxY(obtainFrame);
        if (spaceX >= spaceY) {
            return ZWMGuideMaskItemRegionLeft;
        }
        /// 当前显示的视图在左上角
        return ZWMGuideMaskItemRegionLeftTop;
    }
    
    if ((visualCenter.x > viewCenter.x)     && (visualCenter.y <= viewCenter.y))
    {
        CGFloat spaceX = CGRectGetMinX(obtainFrame);
        CGFloat spaceY = CGRectGetHeight(self.bounds)-CGRectGetMaxY(obtainFrame);
        if (spaceX >= spaceY) {
            return ZWMGuideMaskItemRegionRight;
        }
        /// 当前显示的视图在右上角
        return ZWMGuideMaskItemRegionRightTop;
    }
    
    if ((visualCenter.x <= viewCenter.x)    && (visualCenter.y > viewCenter.y))
    {
        CGFloat spaceX = CGRectGetWidth(self.bounds)-CGRectGetMaxX(obtainFrame);
        CGFloat spaceY = CGRectGetMinY(obtainFrame);
        if (spaceX >= spaceY) {
            return ZWMGuideMaskItemRegionLeft;
        }
        /// 当前显示的视图在左下角
        return ZWMGuideMaskItemRegionLeftBottom;
    }

    CGFloat spaceX = CGRectGetMinX(obtainFrame);
    CGFloat spaceY = CGRectGetMinY(obtainFrame);
    if (spaceX >= spaceY) {
        return ZWMGuideMaskItemRegionRight;
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
    if([self.dataSource respondsToSelector:@selector(guideMaskViewWillHide:)]){
        [self.dataSource guideMaskViewWillHide:self];
    }
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
