//
//  UnpluggedAppDelegate.m
//  Unplugged
//
//  Created by David Kaminsky on 7/26/12.
//  Copyright (c) 2012 Kaminsky Apps. All rights reserved.
//

#import "UnpluggedAppDelegate.h"

@implementation UnpluggedAppDelegate

@synthesize window = _window;
@synthesize powerHandler;
@synthesize bgTask;
@synthesize background;
@synthesize sentNotification;
@synthesize expirationHandler;
@synthesize lastBatteryState;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.powerHandler = [[PowerHandler alloc] init];
    self.lastBatteryState = UIDeviceBatteryStateUnknown;
    
    UIApplication* app = [UIApplication sharedApplication];
    
    self.expirationHandler = ^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
        self.bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
    };
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.background = YES;
    self.lastBatteryState = UIDeviceBatteryStateUnknown;
    
    UIApplication*    app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.background)
        {
            [self updateBatteryState:[self.powerHandler checkBatteryState]];
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    self.background = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark PowerHandler Delegate

- (void)updateBatteryState:(UIDeviceBatteryState)batteryState
{
    if((batteryState != UIDeviceBatteryStateCharging && batteryState != UIDeviceBatteryStateFull) && batteryState != self.lastBatteryState && self.lastBatteryState != UIDeviceBatteryStateUnknown)
    {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.fireDate=[NSDate date];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        localNotif.alertBody = @"Please unplug your charger.";
        localNotif.alertAction = @"Reminder";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication]presentLocalNotificationNow:localNotif];
    }
    
    self.lastBatteryState = batteryState;
}

@end
