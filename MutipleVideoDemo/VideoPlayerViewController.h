//
//  VideoPlayerViewController.h
//  MutipleVideoDemo
//
//  Created by CantChat on 14-6-1.
//  Copyright (c) 2014年 CantChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class VideoPlayerView;
@class ViewController;

@interface VideoPlayerViewController : UIViewController

@property (nonatomic, strong) NSURL * playUrl;
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong) VideoPlayerView * playerView;

@property (nonatomic, assign) int num;
@property (nonatomic, assign) BOOL readyToPlay;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL muted;    //default no

@property (nonatomic, strong) ViewController * viewController;
-(void)play;
-(void)pause;

-(void)muteMe;
@end
