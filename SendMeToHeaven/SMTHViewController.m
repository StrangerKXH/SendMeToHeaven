//
//  SMTHViewController.m
//  SendMeToHeaven
//
//  Created by Kevin He on 2014-04-24.
//  Copyright (c) 2014 Kevin He. All rights reserved.
//

#import "SMTHViewController.h"
#import "AppDelegate.h"

static const NSTimeInterval accelerometerMin = 0.01;

@interface SMTHViewController ()

@property (nonatomic) BOOL timerStarted;
@property (nonatomic) CFTimeInterval startTime;
@property (nonatomic) CFTimeInterval bestTime;

@end

@implementation SMTHViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    self.highScoreLabel.text = [NSString stringWithFormat:@"Highscore: %fm",[[userDefaults objectForKey:@"HighScore"] doubleValue]];
    [self startUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startUpdates
{
    NSTimeInterval updateInterval = accelerometerMin;
    
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    SMTHViewController * __weak weakSelf = self;
    self.timerStarted = NO;
    if ([mManager isAccelerometerAvailable] == YES) {
        [mManager setAccelerometerUpdateInterval:updateInterval];
        [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
            
            if(ABS(accelerometerData.acceleration.x) + ABS(accelerometerData.acceleration.y) + ABS(accelerometerData.acceleration.z) < 0.3f){
                if(!weakSelf.timerStarted){
                    weakSelf.startTime = CACurrentMediaTime();
                    weakSelf.timerStarted = YES;
                }
            } else {
                if(weakSelf.timerStarted){
                    CFTimeInterval endTime = CACurrentMediaTime() - self.startTime;
                    weakSelf.timerStarted = NO;
                    double displacement = [self calculateDisplacement:endTime];
                    weakSelf.recentScoreLabel.text = [NSString stringWithFormat:@"%fm",displacement];
                    if(endTime > self.bestTime){
                        weakSelf.bestTime = endTime;
                        weakSelf.highScoreLabel.text = [NSString stringWithFormat:@"Highscore: %fm",displacement];
                        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:[NSNumber numberWithDouble:displacement] forKey:@"HighScore"];
                    }
                }
            }
        }];
    }
}

-(float)calculateDisplacement:(CFTimeInterval) time
{
    CFTimeInterval halfTime = time/2;
    float d = 0;
    float v = 9.81 * halfTime;
    d = v/2 * halfTime;
    return d;
}

- (void)stopUpdates
{
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    if ([mManager isAccelerometerActive] == YES) {
        [mManager stopAccelerometerUpdates];
    }
}


@end
