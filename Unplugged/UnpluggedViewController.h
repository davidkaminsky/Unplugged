//
//  UnpluggedViewController.h
//  Unplugged
//
//  Created by David Kaminsky on 7/26/12.
//  Copyright (c) 2012 Kaminsky Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PowerHandler.h"

@interface UnpluggedViewController : UIViewController <PowerHandlerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *chargingStatusLabel;
@property (strong, nonatomic) PowerHandler* powerHandler;

@end
