//
//  AnimationImageView.h
//  Snap
//
//  Created by ZhangJingshun on 14/12/18.
//  Copyright (c) 2014年 SengLed. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, SFAudioPlayStatus) {
    notBegin = 1,
    animationing,
    animationStop,
    animationPause
};

@interface SLAnimationImageView : UIImageView

@property (nonatomic, assign) SFAudioPlayStatus status;

/**
 开始动画
 */
- (void)startAnimating;

/**
 停止动画
 */
- (void)stopAnimating;

/**
 暂停动画
 */
- (void)pauseAnimation;

//恢复动画
- (void)resumeAnimation;

@end
