//
//  PandaAttackAppDelegate.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PandaAttackViewController.h"
#import "AttackViewController.h"
#import <sqlite3.h>
#import "ASIFormDataRequest.h"
#import "SigninViewController.h"

@interface PandaAttackAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PandaAttackViewController *viewController;
	SigninViewController *signinViewController;
	AttackViewController *attackViewController;
	UINavigationController *attackNavigationController;
	NSString *userEmail;
	
	sqlite3 *attacksDatabase;
	NSMutableArray *dbAttacks;
	
	ASIFormDataRequest *request;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PandaAttackViewController *viewController;
@property (nonatomic, retain) IBOutlet SigninViewController *signinViewController;
@property (nonatomic, retain) IBOutlet AttackViewController *attackViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *attackNavigationController;
@property (nonatomic, retain) NSMutableArray *dbAttacks;
@property (nonatomic, retain) NSString *userEmail;

-(void)startTimer;
-(void)viewSwitch;
-(void)switchFromLoginView;
-(void)createEditableCopyOfDatabase:(NSString*)fileName;
-(void)initializeAttacksDatabase:(NSString*)fileName;
-(void)addAttack:(History*)historyItem;

@end

