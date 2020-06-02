//
//  AnimationImageView.m
//  Snap
//
//  Created by ZhangJingshun on 14/12/18.
//  Copyright (c) 2014年 SengLed. All rights reserved.
//

#import "SLAnimationImageView.h"


@implementation SLAnimationImageView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _status = notBegin;
    }
    return self;
}

//nib 文件加载调用此方法 
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _status = notBegin;
    }
    return self;
}

- (void)startAnimating{
    if ([self.layer animationKeys]) {
        [self.layer removeAllAnimations];
    }
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 6;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    self.layer.speed = 1;

    _status = animationing;

}

- (void)stopAnimating{
    if ([self.layer animationKeys]) {
        [self.layer removeAllAnimations];
    }
    _status = animationStop;
}

//暂停动画
- (void)pauseAnimation {
    //1.取出当前时间，转成动画暂停的时间
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    //2.设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
    self.layer.timeOffset = pauseTime;
    
    //3.将动画的运行速度设置为0， 默认的运行速度是1.0
    self.layer.speed = 0;
    _status = animationPause;
}

//恢复动画
- (void)resumeAnimation {
    if (_status == animationPause) {
        //1.将动画的时间偏移量作为暂停的时间点
        CFTimeInterval pauseTime = self.layer.timeOffset;
        
        //2.计算出开始时间
        CFTimeInterval begin = CACurrentMediaTime() - pauseTime;
        
        [self.layer setTimeOffset:0];
        [self.layer setBeginTime:begin];
        
        self.layer.speed = 1;
        return;
    }
    
    [self startAnimating];
}


@end
