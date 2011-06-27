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
#import "FacebookWrapper.h"
#import "MBProgressHUD.h"

@interface AttackViewController : UIViewController<UIAlertViewDelegate,MFMailComposeViewControllerDelegate> {
	UIButton *startAttackBtn;
    UIButton *scrollPunkdBtn;
    UIButton *scrollAttackedBtn;
	MBProgressHUD *spinner;
	History *attackHistory;
	ASIHTTPRequest *request;
	FacebookWrapper *fbWrapper;
}

@property (nonatomic, retain) IBOutlet UIButton *startAttackBtn;
@property (nonatomic, retain) IBOutlet UIButton *scrollPunkdBtn;
@property (nonatomic, retain) IBOutlet UIButton *scrollAttackedBtn;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) FacebookWrapper *fbWrapper;

-(id) initWithWrapper:(FacebookWrapper *)wrapper;
-(void) startBtnClick:(UIView*)clickedButton;
-(void) scrollPunkdBtnClick:(UIView*)clickedButton;
-(void) scrollAttackedBtnClick:(UIView*)clickedButton;
-(void) changeToWeaponView;
-(void) attackPickedFromAttackedByTableCallback:(NSIndexPath *)attackRow;
-(void) attackPickedFromAttackedTableCallback:(NSIndexPath *)attackRow;
-(History *) findAttackDataToUse:(int)row loadAttacksFromMe:(BOOL)loadAttacksFromMe;
-(void) createAttackViewController:(History *)item;
-(void) addAttack:(History*)historyItem sendToServer:(BOOL)sendToServer attackID:(NSString*)attackID;
-(void) setFbWrapper:(FacebookWrapper*)wrapper;
-(void) serverRequestForAttacks;
-(void) facebookMeCallback;
-(void) facebookFriendsCallback;
-(NSString *) obfuscate:(NSString *)string;
-(void) setSpinningMode:(BOOL)isWaiting detailTxt:(NSString *)detailTxt;

@end
