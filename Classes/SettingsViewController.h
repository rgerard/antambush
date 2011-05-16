//
//  SettingsViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "FacebookWrapper.h"

@interface SettingsViewController : UITableViewController {
	FacebookWrapper *fbWrapper;
}

@property (nonatomic, retain) FacebookWrapper *fbWrapper;

-(void) setFacebookWrapper:(FacebookWrapper*)wrapper;
-(void) facebookLogoutCallback;

@end
