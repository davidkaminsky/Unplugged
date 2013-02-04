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
@synthesize jobExpired;
@synthesize batteryFullNotificationDisplayed;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Starting app");
    
    self.powerHandler = [[PowerHandler alloc] init];
    self.lastBatteryState = UIDeviceBatteryStateUnknown;
    
    UIApplication* app = [UIApplication sharedApplication];
    
    self.expirationHandler = ^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
        self.bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
        NSLog(@"Expired");
        self.jobExpired = YES;
        while(self.jobExpired) {
            // spin while we wait for the task to actually end.
            [NSThread sleepForTimeInterval:1];
        }
        // Restart the background task so we can run forever.
        [self startBackgroundTask];
    };
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
    
    // Assume that we're in background at first since we get no notification from device that we're in background when
    // app launches immediately into background (i.e. when powering on the device or when the app is killed and restarted)
    [self monitorBatteryStateInBackground];
    
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
    NSLog(@"Entered background");
    [self monitorBatteryStateInBackground];
}

- (void)monitorBatteryStateInBackground
{
    NSLog(@"Monitoring battery state");
    self.background = YES;
    self.lastBatteryState = UIDeviceBatteryStateUnknown;
    [self startBackgroundTask];
}

- (void)startBackgroundTask
{
    NSLog(@"Restarting task");
    // Start the long-running task.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // When the job expires it still keeps running since we never exited it. Thus have the expiration handler
        // set a flag that the job expired and use that to exit the while loop and end the task.
        while(self.background && !self.jobExpired)
        {
            [self updateBatteryState:[self.powerHandler checkBatteryState]];
            [NSThread sleepForTimeInterval:1];
        }
        
        self.jobExpired = NO;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    NSLog(@"App is active");
    self.background = NO;
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
    if([self shouldNotifyUnplugged:batteryState])
    {
        [self notifyUnpluggedCharger];
    }
    else if([self shouldNotifyBatteryFull:batteryState]) {
        [self notifyBatteryFull];
        self.batteryFullNotificationDisplayed = YES;
    }
    else
    {
        // Should get here after it fails to show unplugged notification due to the fact that
        // the battery full notification was displayed.
        self.batteryFullNotificationDisplayed = NO;
    }
    
    self.lastBatteryState = batteryState;
}

- (BOOL)shouldNotifyUnplugged:(UIDeviceBatteryState)batteryState
{
    return ((batteryState != UIDeviceBatteryStateCharging && batteryState != UIDeviceBatteryStateFull) && batteryState != self.lastBatteryState && self.lastBatteryState != UIDeviceBatteryStateUnknown && !self.batteryFullNotificationDisplayed);
}

- (BOOL)shouldNotifyBatteryFull:(UIDeviceBatteryState)batteryState
{
    return (batteryState == UIDeviceBatteryStateFull && batteryState != self.lastBatteryState && self.lastBatteryState != UIDeviceBatteryStateUnknown);
}

- (void)notifyUnpluggedCharger
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = @"Please unplug charger.";
    localNotif.alertAction = @"Reminder";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication]presentLocalNotificationNow:localNotif];
}

- (void)notifyBatteryFull
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = @"Battery fully charged. Please unplug charger.";
    localNotif.alertAction = @"Attention";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication]presentLocalNotificationNow:localNotif];
}

@end
