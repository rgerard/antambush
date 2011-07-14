//
//  RecentAttacksViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"
#import "MixpanelAPI.h"

@interface RecentAttacksViewController : UITableViewController {
	BOOL loadAttacksFromMe;
	id delegate;
	SEL attackSelector;
}

@property (nonatomic) BOOL loadAttacksFromMe;

-(History *) findAttackDataToUse:(int)row loadAttacksFromMe:(BOOL)loadAttacksFromMe;
-(void) createAttackViewController:(History *)item;

@end
