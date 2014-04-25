//
//  HFIPViewController.m
//  SendMeToHeaven
//
//  Created by Kevin He on 2014-04-24.
//  Copyright (c) 2014 Kevin He. All rights reserved.
//

#import "HFIPViewController.h"
#import "APLGraphView.h"
#import "AppDelegate.h"

@interface HFIPViewController ()
@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UILabel *zLabel;
@property (weak, nonatomic) IBOutlet UISlider *updateIntervalSlider;

@property (weak, nonatomic) IBOutlet APLGraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *updateIntervalLabel;

@end

static const NSTimeInterval deviceMotionMin = 0.01;

@implementation HFIPViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.updateIntervalSlider.value = 0.0f;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startUpdatesWithSliderValue:(int)(self.updateIntervalSlider.value * 100)];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopUpdates];
}


#pragma mark - Responding to events

- (IBAction)takeSliderValueFrom:(UISlider *)sender
{
    [self startUpdatesWithSliderValue:(int)(sender.value * 100)];
}


- (void)setLabelValueX:(double)x y:(double)y z:(double)z
{
    self.xLabel.text = [NSString stringWithFormat:@"x: %f", x];
    self.yLabel.text = [NSString stringWithFormat:@"y: %f", y];
    self.zLabel.text = [NSString stringWithFormat:@"z: %f", z];
}

- (void)setLabelValueRoll:(double)roll pitch:(double)pitch yaw:(double)yaw
{
    self.xLabel.text = [NSString stringWithFormat:@"roll: %f", roll];
    self.yLabel.text = [NSString stringWithFormat:@"pitch: %f", pitch];
    self.zLabel.text = [NSString stringWithFormat:@"yaw: %f", yaw];
}


- (void)startUpdatesWithSliderValue:(int)sliderValue
{
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = deviceMotionMin + delta * sliderValue;
    
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    HFIPViewController * __weak weakSelf = self;
    
    if ([mManager isDeviceMotionAvailable] == YES) {
        [mManager setDeviceMotionUpdateInterval:updateInterval];
        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            
            [weakSelf.graphView addX:deviceMotion.gravity.x y:deviceMotion.gravity.y z:deviceMotion.gravity.z];
            [weakSelf setLabelValueX:deviceMotion.gravity.x y:deviceMotion.gravity.y z:deviceMotion.gravity.z];
            
        }];
    }
    
    self.updateIntervalLabel.text = [NSString stringWithFormat:@"%f", updateInterval];
}


- (void)stopUpdates
{
    CMMotionManager *mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    if ([mManager isDeviceMotionActive] == YES) {
        [mManager stopDeviceMotionUpdates];
    }
}

@end
