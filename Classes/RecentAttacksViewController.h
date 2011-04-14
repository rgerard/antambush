//
//  RecentAttacksViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RecentAttacksViewController : UITableViewController {
	BOOL loadAttacksFromMe;
}

@property (nonatomic) BOOL loadAttacksFromMe;

@end
