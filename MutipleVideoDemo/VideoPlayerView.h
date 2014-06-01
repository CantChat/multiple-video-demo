//
//  VideoPlayerView.h
//  MutipleVideoDemo
//
//  Created by CantChat on 14-6-1.
//  Copyright (c) 2014年 CantChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@interface VideoPlayerView : UIView

@property (nonatomic, strong) AVPlayer * player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
