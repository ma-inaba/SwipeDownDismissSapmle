# SwipeDownDismissSapmle
#概要

- Xcode7
- iOS9
- デフォルトミュージックアプリの再生画面のような、下スワイプで閉じられる画面のサンプル

#実装

① ストーリーボードにてモーダルで表示するビューコントローラーのビューを選択し、クリアカラーにする <dr>
② とりあえずViewDidLoad等でジェスチャーをaddする <dr>
 
```
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.mainView addGestureRecognizer:panGesture];
```

③ UIPanGestureRecognizerのメソッドを実装する <dr>

```
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
```

まずtranslationInViewで移動量が取得できるので保持しておく <dr>
if文で「下に下げた場合」「上に上げた場合」「その他」「ドラッグ終了時」を判定し各処理を追加する <dr>
ポイントとしては普通に下にスワイプしても多少は横にずれるのでそれを考慮した以下の判定文 <dr>

```
(-movePoint.y < movePoint.x && movePoint.x < movePoint.y)
```
y座標もx座標の幅と同じ分判定に追加することにより多少横にずれても下と判定する <dr>
(すいません。うまく説明できないです) <dr>
 <dr>
④ if文で分けた各メソッドを実装する <dr>

```
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
```
ここのポイントとしては下に下げる時のアニメーション完了時にDismissするくらいでしょうか・・・ <dr>

⑤最後に以下を実装 <dr>

```
- (UIModalPresentationStyle)modalPresentationStyle {
    
    return UIModalPresentationOverCurrentContext;
}
```

以上
