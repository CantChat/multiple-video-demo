//
//  ViewController.m
//  MutipleVideoDemo
//
//  Created by CantChat on 14-6-1.
//  Copyright (c) 2014年 CantChat. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerViewController.h"
#import "VideoPlayerView.h"

@interface ViewController ()
{
    NSMutableArray * playerArray;
    UIView * videoView;
    NSURL * url;
    NSMutableArray * iconArray;
}
@end

//Change this number if you want to play more videos.
#define VideoCount 6

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define playIconTag 123

NSString * const kpReadyToPlay = @"readyToPlay";
static void * MutlpleVideoDemoReadyToPlayObservationContext = &MutlpleVideoDemoReadyToPlayObservationContext;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;

    NSLog(@"SCREEN_HEIGHT= %f, SCREEN_WIDTH = %f", SCREEN_HEIGHT, SCREEN_WIDTH);
    CGSize videoSize = CGSizeMake(SCREEN_HEIGHT*0.48f, SCREEN_WIDTH*0.48f);
    
    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"NFS14.m4v" ofType:nil]];
    
    UIScrollView * backScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
    backScroll.backgroundColor = [UIColor clearColor];
    backScroll.contentSize = CGSizeMake(self.view.bounds.size.height, (VideoCount/2+VideoCount%2)*(SCREEN_WIDTH*0.5f));
    [self.view addSubview:backScroll];
    
    
    videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backScroll.contentSize.width, backScroll.contentSize.height)];
    videoView.backgroundColor = [UIColor clearColor];
    [backScroll addSubview:videoView];
    
    playerArray = [[NSMutableArray alloc] init];
    iconArray = [[NSMutableArray alloc] init];
    for (int c = 0; c<VideoCount; c++) {
        CGRect rect = CGRectMake((c%2)*(SCREEN_HEIGHT*0.5f), c/2*(SCREEN_WIDTH*0.5f), videoSize.width, videoSize.height);
        
        //The player!!!
        VideoPlayerViewController * videoPlayer = [[VideoPlayerViewController alloc] init];
        videoPlayer.num = c;
        videoPlayer.view.frame = rect;
        [videoView addSubview:videoPlayer.view];
        [playerArray addObject:videoPlayer];
        
        //Playing control gesture.
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAndPause:)];
        UIView * touchView = [[UIView alloc] initWithFrame:rect];
        touchView.backgroundColor = [UIColor blackColor];
        touchView.tag = c;
        [backScroll addSubview:touchView];
        [touchView addGestureRecognizer:tap];
        
        UIImageView * playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        playIcon.image = [UIImage imageNamed:@"video_play.png"];
        playIcon.tag = playIconTag;
        playIcon.center = CGPointMake(touchView.frame.size.width/2, touchView.frame.size.height/2);
        [touchView addSubview:playIcon];
        [iconArray addObject:playIcon];
        
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Playing Control
-(void)playAndPause:(UITapGestureRecognizer *)sender
{
    VideoPlayerViewController * videoPlayer = [playerArray objectAtIndex:sender.view.tag];
    
    //Play/Pause
    if ([videoPlayer readyToPlay]) {
        if (!videoPlayer.isPlaying) {
            [videoPlayer play];
            ((UIImageView *)[iconArray objectAtIndex:sender.view.tag]).hidden = YES;
            
        } else {
            [videoPlayer pause];
            ((UIImageView *)[iconArray objectAtIndex:sender.view.tag]).hidden = NO;
        }
        
    } else {
        videoPlayer.playUrl = url;
        [videoPlayer play];
        sender.view.backgroundColor = [UIColor clearColor];
        
        [videoPlayer addObserver:self
                      forKeyPath:kpReadyToPlay
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MutlpleVideoDemoReadyToPlayObservationContext];
    }
    
}

//Player mute control
-(void)controlMediaVolume
{
    @synchronized (self) {
        for (int i = 0; i<[playerArray count]; i++) {
            VideoPlayerViewController * player = [playerArray objectAtIndex:i];
            if (i == 0) {
                player.player.muted = NO;
                player.muted = NO;
                    
            } else {
                [player muteMe];

            }
        }
    }
}


- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    //If current player is ready to play, display the icon.
    if (context == MutlpleVideoDemoReadyToPlayObservationContext) {
        if (((VideoPlayerViewController *)object).readyToPlay) {
            [((VideoPlayerViewController *)object) play];
            ((UIImageView *)[iconArray objectAtIndex:((VideoPlayerViewController *)object).num]).superview.backgroundColor = [UIColor clearColor];
            ((UIImageView *)[iconArray objectAtIndex:((VideoPlayerViewController *)object).num]).hidden = YES;
            
        } else {
            
        }
    }
}
@end
