//
//  PowerNotification.m
//  Unplugged
//
//  Created by David Kaminsky on 7/26/12.
//  Copyright (c) 2012 Kaminsky Apps. All rights reserved.
//

#import "PowerHandler.h"

@implementation PowerHandler

@synthesize delegate;

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    self.delegate = nil;
    
    return self;
}

- (void)startMonitoring
{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    NSLog(@"State: %i Charge: %f", device.batteryState, device.batteryLevel);
    [self batteryChanged:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:device];
}

- (UIDeviceBatteryState)checkBatteryState
{
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"State: %i Charge: %f", device.batteryState, device.batteryLevel);
    return device.batteryState;
}

- (void)batteryChanged:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    if([delegate respondsToSelector:@selector(updateBatteryState:)]) {
        [delegate updateBatteryState:device.batteryState];
    }
}
@end
