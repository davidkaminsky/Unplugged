//
//  PowerNotification.h
//  Unplugged
//
//  Created by David Kaminsky on 7/26/12.
//  Copyright (c) 2012 Kaminsky Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PowerHandlerDelegate;

@interface PowerHandler : NSObject
@property (nonatomic, weak) id<PowerHandlerDelegate> delegate;
- (id)init;
- (void)startMonitoring;
- (void)batteryChanged:(NSNotification *)notification;
- (UIDeviceBatteryState)checkBatteryState;
@end

@protocol PowerHandlerDelegate <NSObject>

@optional
- (void)updateBatteryState:(UIDeviceBatteryState)batteryState;
@end