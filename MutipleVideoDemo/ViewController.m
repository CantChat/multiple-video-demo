//
//  ViewController.m
//  MutipleVideoDemo
//
//  Created by CantChat on 14-6-1.
//  Copyright (c) 2014年 CantChat. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerViewController.h"

@interface ViewController ()
{
    NSMutableArray * playerArray;
    UIView * videoView;
    NSURL * url;
    NSMutableArray * iconArray;
}
@end

#define VideoCount 4
#define videoSize CGSizeMake(484,272)
#define playIconTag 123

NSString * const kpReadyToPlay = @"readyToPlay";
static void * MutlpleVideoDemoReadyToPlayObservationContext = &MutlpleVideoDemoReadyToPlayObservationContext;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;

    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"NFS14.m4v" ofType:nil]];
    
    videoView = [[UIView alloc] initWithFrame:self.view.bounds];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:videoView];
    
    playerArray = [[NSMutableArray alloc] init];
    iconArray = [[NSMutableArray alloc] init];
    for (int c = 0; c<VideoCount; c++) {
        CGRect rect = CGRectMake((c%2)*(videoSize.width+30), c/2*(videoSize.height+30), videoSize.width, videoSize.height);
        
        //The player!!!
        VideoPlayerViewController * videoPlayer = [[VideoPlayerViewController alloc] init];
        videoPlayer.playUrl = url;
        videoPlayer.num = c;
        videoPlayer.view.frame = rect;
        [videoView addSubview:videoPlayer.view];
        [playerArray addObject:videoPlayer];
        
        [videoPlayer addObserver:self
                          forKeyPath:kpReadyToPlay
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:MutlpleVideoDemoReadyToPlayObservationContext];
        
        //Playing control gesture.
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAndPause:)];
        UIView * touchView = [[UIView alloc] initWithFrame:rect];
        touchView.backgroundColor = [UIColor clearColor];
        touchView.tag = c;
        [self.view addSubview:touchView];
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
        
    }
    
}

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    //If current player is ready to play, display the icon.
    if (context == MutlpleVideoDemoReadyToPlayObservationContext) {
        if (((VideoPlayerViewController *)object).readyToPlay) {
            ((UIImageView *)[iconArray objectAtIndex:((VideoPlayerViewController *)object).num]).hidden = NO;
            
        }
    }
}
@end
