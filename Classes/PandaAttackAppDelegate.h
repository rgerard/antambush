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
#import "SigninViewController.h"
#import	"FacebookWrapper.h"

@interface PandaAttackAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PandaAttackViewController *viewController;
	SigninViewController *signinViewController;
	AttackViewController *attackViewController;
	UINavigationController *attackNavigationController;
	NSString *userEmail;
	FacebookWrapper *fbWrapper;
	
	sqlite3 *attacksDatabase;
	NSMutableArray *dbAttacks;
	NSMutableArray *dbAttackedBy;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PandaAttackViewController *viewController;
@property (nonatomic, retain) IBOutlet SigninViewController *signinViewController;
@property (nonatomic, retain) IBOutlet AttackViewController *attackViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *attackNavigationController;
@property (nonatomic, retain) NSMutableArray *dbAttacks;
@property (nonatomic, retain) NSMutableArray *dbAttackedBy;
@property (nonatomic, retain) NSString *userEmail;
@property (nonatomic, retain) FacebookWrapper *fbWrapper;
@property (nonatomic) sqlite3 *attacksDatabase;

-(void)startTimer;
-(void)viewSwitch;
-(void)switchFromLoginView;
-(void)createEditableCopyOfDatabase:(NSString*)fileName;
-(void)initializeAttacksDatabase:(NSString*)fileName;
-(void)addAttack:(History*)historyItem sendToServer:(BOOL)sendToServer emailAttack:(BOOL)emailAttack attackID:(NSString*)attackID;
-(NSDictionary*)findAttackInPList:(NSString*)imageNameToFind;

@end

