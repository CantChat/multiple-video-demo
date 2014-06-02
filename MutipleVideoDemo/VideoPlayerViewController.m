//
//  VideoPlayerViewController.m
//  MutipleVideoDemo
//
//  Created by CantChat on 14-6-1.
//  Copyright (c) 2014年 CantChat. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "VideoPlayerView.h"
#import "ViewController.h"

@interface VideoPlayerViewController ()

@end

//Asset keys
NSString * const kpTracks = @"tracks";
NSString * const kpPlayable = @"playable";

//PlayerItem keys
NSString * const kpStatus = @"status";
NSString * const kpCurrentItem	= @"currentItem";

static void * MutlpleVideoDemoCurrentItemObservationContext = &MutlpleVideoDemoCurrentItemObservationContext;
static void * MutlpleVideoDemoStatusObservationContext = &MutlpleVideoDemoStatusObservationContext;


@implementation VideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    VideoPlayerView * playerView = [[VideoPlayerView alloc] init];
    self.view = playerView;
    self.playerView = playerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - URL
- (void)setPlayUrl:(NSURL *)playUrl{
    _playUrl = playUrl;
    
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_playUrl options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kpTracks, kpPlayable, nil];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
}


#pragma mark - Player Initialzation

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    for (NSString *thisKey in requestedKeys) {
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed) {
			return;
		}
	}
    
    if (!asset.playable) {
        return;
    }
	
	if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kpStatus];
		
    }
	
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self
                      forKeyPath:kpStatus
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MutlpleVideoDemoStatusObservationContext];
    
    if (![self player]) {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        [self.player addObserver:self
                      forKeyPath:kpCurrentItem
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MutlpleVideoDemoCurrentItemObservationContext];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidPlayToEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
    }
    
    if (self.player.currentItem != self.playerItem) {
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
    }
}

#pragma mark - Key Valye Observing

- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
	if (context == MutlpleVideoDemoStatusObservationContext) {
    
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        //The current state feedback
        if (status == AVPlayerStatusReadyToPlay) {
            [self.player play];
            self.readyToPlay = YES;
            
            [self.viewController controlMediaVolume];
            
        } else {
            self.readyToPlay = NO;
            
        }
        
	} else if (context == MutlpleVideoDemoCurrentItemObservationContext) {
        
        AVPlayerItem * newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        if (newPlayerItem) {
            [self.playerView setPlayer:self.player];
            [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
        }
        
	} else {
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
        
	}
}

#pragma mark - Playing Control
-(void)play
{
    [self.player play];
    self.isPlaying = YES;
}

-(void)pause
{
    [self.player pause];
    self.isPlaying = NO;
}

-(void)muteMe
{
    if (self.player) {
        self.player.muted = YES;

    }
    self.muted = YES;
}


//Playback did finish, reset the player
-(void)playerItemDidPlayToEnd:(NSNotification *)notification
{
    if (notification.object == self.playerItem) {
        self.readyToPlay = NO;
        self.isPlaying = NO;
        [self removeAllObserver];
        
//        //Reset the url, to perform initialization of player
//        self.playUrl = _playUrl;
    }
}

//free the player & remove observer
-(void)removeAllObserver
{
    [self.playerItem removeObserver:self forKeyPath:kpStatus];
    [self.player removeObserver:self forKeyPath:kpCurrentItem];

    self.player = nil;
    self.playerItem = nil;
}

@end
