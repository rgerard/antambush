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
	id delegate;
	SEL attackSelector;
}

@property (nonatomic) BOOL loadAttacksFromMe;
@property (nonatomic, retain) id delegate;
@property (nonatomic) SEL attackSelector;

-(void) setDelegateCallback:(SEL)appSelector delegate:(id)requestDelegate;

@end
