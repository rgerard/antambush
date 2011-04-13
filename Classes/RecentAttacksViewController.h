//
//  RecentAttacksViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecentAttacksViewController : UITableViewController {
	UITableView *recentAttacksTable;
}

@property (nonatomic, retain) IBOutlet UITableView *recentAttacksTable;

@end
