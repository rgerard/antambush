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
#import "ASIHTTPRequest.h"
#import "RecentAttacksViewController.h"

@interface AttackViewController : UIViewController<ABPeoplePickerNavigationControllerDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate> {
	UIButton *startAttackBtn;
	UIButton *viewHistoryBtn;
	UIActivityIndicatorView *spinner;
	NSString *currentUserToAttack;	
	History *attackHistory;
	ASIHTTPRequest *request;
	RecentAttacksViewController *recentAttacksViewController;
}

@property (nonatomic, retain) IBOutlet UIButton *startAttackBtn;
@property (nonatomic, retain) IBOutlet UIButton *viewHistoryBtn;
@property (nonatomic, retain) NSString *currentUserToAttack;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) RecentAttacksViewController *recentAttacksViewController;

-(void)personBtnClick:(UIView*)clickedButton;
-(void)startBtnClick:(UIView*)clickedButton;
-(void)viewHistoryBtnClick:(UIView*)clickedButton;
-(void)changeToWeaponView;

@end
