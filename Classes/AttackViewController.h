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
#import "ASIFormDataRequest.h"
#import "RecentAttacksViewController.h"
#import "ContactListPicker.h"

@interface AttackViewController : UIViewController<UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate> {
	UIButton *startAttackBtn;
	UIActivityIndicatorView *spinner;
	History *attackHistory;
	ASIHTTPRequest *request;
	ASIFormDataRequest *formRequest;
	RecentAttacksViewController *recentAttacksViewController;
	RecentAttacksViewController *recentlyAttackedByViewController;
	ContactListPicker *contactList;
}

@property (nonatomic, retain) IBOutlet UIButton *startAttackBtn;
@property (nonatomic, retain) IBOutlet UIButton *viewHistoryBtn;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) ASIFormDataRequest *formRequest;
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
-(void)addAttack:(History*)historyItem sendToServer:(BOOL)sendToServer emailAttack:(BOOL)emailAttack;

@end
