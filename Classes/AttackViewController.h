//
//  AttackViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "History.h"

@interface AttackViewController : UIViewController<ABPeoplePickerNavigationControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,UITableViewDelegate,UITableViewDataSource> {
	UIButton *startAttackBtn;
	UIButton *viewHistoryBtn;
	UITableView *recentAttacksTable;
	History *attackHistory;
}

@property (nonatomic, retain) IBOutlet UIButton *startAttackBtn;
@property (nonatomic, retain) IBOutlet UIButton *viewHistoryBtn;
@property (nonatomic, retain) IBOutlet UITableView *recentAttacksTable;

-(void)personBtnClick:(UIView*)clickedButton;
-(void)startBtnClick:(UIView*)clickedButton;
-(void)viewHistoryBtnClick:(UIView*)clickedButton;

@end
