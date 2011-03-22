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

@interface PandaAttackAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PandaAttackViewController *viewController;
	AttackViewController *attackViewController;
	UINavigationController *attackNavigationController;
	
	sqlite3 *historyDatabase;
	NSMutableArray *dbHistory;
	
	sqlite3 *attacksDatabase;
	NSMutableArray *dbAttacks;	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PandaAttackViewController *viewController;
@property (nonatomic, retain) IBOutlet AttackViewController *attackViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *attackNavigationController;
@property (nonatomic, retain) NSMutableArray *dbHistory;
@property (nonatomic, retain) NSMutableArray *dbAttacks;

-(void)startTimer;
-(void)viewSwitch;
-(void)createEditableCopyOfDatabase:(NSString*)fileName;
-(void)initializeHistoryDatabase:(NSString*)fileName;
-(void)initializeAttacksDatabase:(NSString*)fileName;
-(void)addAttack:(History*)historyItem;

@end

