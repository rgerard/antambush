//
//  FBTableViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookWrapper.h"
#import "History.h"

@interface FBTableViewController : UITableViewController {
	FacebookWrapper *fbWrapper;
	History *attackHistory;
}

@property (nonatomic, retain) FacebookWrapper *fbWrapper;
@property (nonatomic, retain) History *attackHistory;

-(void) setFbWrapper:(FacebookWrapper*)wrapper;

@end
