//
//  UnpluggedViewController.m
//  Unplugged
//
//  Created by David Kaminsky on 7/26/12.
//  Copyright (c) 2012 Kaminsky Apps. All rights reserved.
//

#import "UnpluggedViewController.h"

@implementation UnpluggedViewController

@synthesize powerHandler;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.powerHandler = [[PowerHandler alloc] init];
    self.powerHandler.delegate = self;
    [self.powerHandler startMonitoring];
}

- (void)viewDidUnload
{
    [self setChargingStatusLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark PowerHandler Delegate

- (void)updateBatteryState:(UIDeviceBatteryState)batteryState
{
    if(batteryState == UIDeviceBatteryStateCharging)
    {
        self.chargingStatusLabel.text = @"Charging";
    }
    else if(batteryState == UIDeviceBatteryStateFull)
    {
        self.chargingStatusLabel.text = @"Battery Full";
    }
    else
    {
        self.chargingStatusLabel.text = @"Unplugged";
    }
}

@end
