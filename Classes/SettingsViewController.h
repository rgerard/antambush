//
//  SettingsViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface SettingsViewController : UITableViewController<FBSessionDelegate> {
	Facebook *facebook;
}

@property (nonatomic, retain) Facebook *facebook;

@end
