//
//  SecondViewController.m
//  SwipeDownDismissSample
//
//  Created by inaba masaya on 2015/11/25.
//  Copyright © 2015年 inaba masaya. All rights reserved.
//

#import "SecondViewController.h"

static const CGFloat kMovePointBorderLine = 100.0f;     // 画面の上からこの値までで指を離した場合は上に戻す
static const NSTimeInterval kOriginalFrameAnimationSpeed = 0.1f;    // 上に戻す時のアニメーションスピード
static const NSTimeInterval kDismissAnimationSpeed = 0.3f;      // 下に下げてDismissする時のアニメーションスピード

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // パンジェスチャーを生成してaddする
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.mainView addGestureRecognizer:panGesture];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer {
    
    // 移動量
    CGPoint movePoint = [recognizer translationInView:self.mainView];
    
    // 下に下げる際にx座標が多少横にずれても下と判定する
    if (movePoint.y > 0 && (-movePoint.y < movePoint.x && movePoint.x < movePoint.y)) { //下に下げた場合
        self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, movePoint.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
    } else if (movePoint.y < 0 && self.mainView.frame.origin.y > 0) {   //上に上げた場合
        // 上に上げた時にすでにy座標が100以下の場合はそれ以上操作させずに元に戻す
        if (movePoint.y < kMovePointBorderLine) {
            [self animateOriginalFrame];
            return;
        }
        self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, movePoint.y, self.mainView.frame.size.width, self.mainView.frame.size.height);
    } else {
        // 下に下げたが横に移動した等は全て元に戻す
        [self animateOriginalFrame];
        return;
    }
    
    // ドラッグが終わり次第場所によってDismissするか元に戻すか判定する
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (movePoint.y > kMovePointBorderLine) {
            [self animateDismissViewController];
        } else {
            [self animateOriginalFrame];
        }
    }
}

// 元に戻すアニメーションメソッド
- (void)animateOriginalFrame {
    
    [UIView animateWithDuration:kOriginalFrameAnimationSpeed delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        // 初期値に戻す
        self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, 0, self.mainView.frame.size.width, self.mainView.frame.size.height);
    } completion:^(BOOL finished) {

    }];
}

// ViewControllerを下に下げてからDismissするメソッド
- (void)animateDismissViewController {
    
    [UIView animateWithDuration:kDismissAnimationSpeed delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        // 下に下げる
        self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.size.height, self.mainView.frame.size.width, self.mainView.frame.size.height);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

// UIViewControllerの背景を透過させる
- (UIModalPresentationStyle)modalPresentationStyle {
    
    return UIModalPresentationOverCurrentContext;
}


@end
