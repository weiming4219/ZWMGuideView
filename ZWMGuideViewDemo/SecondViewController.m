//
//  SecondViewController.m
//  ZWMGuideViewDemo
//
//  Created by 伟明 on 2017/11/28.
//  Copyright © 2017年 com.zhongzhou. All rights reserved.
//

#import "SecondViewController.h"
#import "ZWMGuideView.h"

@interface SecondViewController ()<ZWMGuideViewDataSource,ZWMGuideViewLayoutDelegate>
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewsArray;
@property (strong, nonatomic) ZWMGuideView *guideView;
@property (strong, nonatomic) NSArray *descriptionArrar;
@end

@implementation SecondViewController
- (ZWMGuideView *)guideView
{
    if (_guideView == nil) {
        _guideView = [[ZWMGuideView alloc] initWithFrame:self.view.bounds];
        _guideView.dataSource = self;
        _guideView.delegate = self;
    }
    return _guideView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"新手引导页";
    self.descriptionArrar = @[@"^^提莫队长正在送命^^！",
                              @"^^我的大屌早已饥渴难耐了^^！",
                              @"^^人人都会打飞机^^！",
                              @"^^我好想射点儿什么^^！",
                              @"^^你的剑就是我的剑^^！",
                              @"^^见识下真正的坑货吧^^！",
                              @"欢迎来到小学生联盟! 小学生还有30秒到达战场！碾碎他们！全军出鸡！"];
    [self.guideView show];
}

- (IBAction)again:(id)sender {
    [self.guideView show];
}

#pragma mark -- ZWMGuideViewDataSource（必须实现的数据源方法）
- (NSInteger)numberOfItemsInGuideMaskView:(ZWMGuideView *)guideMaskView{
    return self.viewsArray.count;

}
- (UIView *)guideMaskView:(ZWMGuideView *)guideMaskView viewForItemAtIndex:(NSInteger)index{
    return self.viewsArray[index];

}
- (NSString *)guideMaskView:(ZWMGuideView *)guideMaskView descriptionLabelForItemAtIndex:(NSInteger)index{
    return self.descriptionArrar[index];
}

#pragma mark -- ZWMGuideViewLayoutDelegate
- (CGFloat)guideMaskView:(ZWMGuideView *)guideMaskView cornerRadiusForItemAtIndex:(NSInteger)index
{
    if (index == self.viewsArray.count-1)
    {
        return 30;
    }
    
    return 5;
}
@end
