//
//  AttackViewController.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "History.h"
#import "ASIHTTPRequest.h"
#import "RecentAttacksViewController.h"
#import "ContactListPicker.h"

@interface AttackViewController : UIViewController<UIAlertViewDelegate,MFMailComposeViewControllerDelegate> {
	UIButton *startAttackBtn;
	UIActivityIndicatorView *spinner;
	NSString *currentUserToAttack;	
	History *attackHistory;
	ASIHTTPRequest *request;
	RecentAttacksViewController *recentAttacksViewController;
	RecentAttacksViewController *recentlyAttackedByViewController;
	ContactListPicker *contactList;
}

@property (nonatomic, retain) IBOutlet UIButton *startAttackBtn;
@property (nonatomic, retain) IBOutlet UIButton *viewHistoryBtn;
@property (nonatomic, retain) NSString *currentUserToAttack;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) RecentAttacksViewController *recentAttacksViewController;
@property (nonatomic, retain) RecentAttacksViewController *recentlyAttackedByViewController;
@property (nonatomic, retain) ContactListPicker *contactList;

-(void)personBtnClick:(UIView*)clickedButton;
-(void)startBtnClick:(UIView*)clickedButton;
-(void)changeToWeaponView;
-(void)personPickedCallback;
-(void)attackPickedFromAttackedByTableCallback:(NSIndexPath *)attackRow;
-(void)attackPickedFromAttackedTableCallback:(NSIndexPath *)attackRow;
-(History *) findAttackDataToUse:(int)row loadAttacksFromMe:(BOOL)loadAttacksFromMe;
-(void)createAttackViewController:(History *)item;

@end
