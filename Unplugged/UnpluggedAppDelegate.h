//
//  UnpluggedAppDelegate.h
//  Unplugged
//
//  Created by David Kaminsky on 7/26/12.
//  Copyright (c) 2012 Kaminsky Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PowerHandler.h"

@interface UnpluggedAppDelegate : UIResponder <UIApplicationDelegate, PowerHandlerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PowerHandler* powerHandler;
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (assign, nonatomic) BOOL background;
@property (assign, nonatomic) BOOL sentNotification;
@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) UIDeviceBatteryState lastBatteryState;
@property (assign, nonatomic) BOOL jobExpired;

@end
