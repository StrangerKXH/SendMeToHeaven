//
//  AppDelegate.h
//  SendMeToHeaven
//
//  Created by Kevin He on 2014-04-24.
//  Copyright (c) 2014 Kevin He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CMMotionManager *sharedManager;

@end
