//
//  AntAmbushAppDelegate.h
//  AntAmbush
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AntAmbushViewController.h"
#import "AttackViewController.h"
#import <sqlite3.h>
#import "SigninViewController.h"
#import	"FacebookWrapper.h"
#import "LocalyticsSession.h"

@interface AntAmbushAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AntAmbushViewController *viewController;
	SigninViewController *signinViewController;
	AttackViewController *attackViewController;
	UINavigationController *attackNavigationController;
	NSString *userFbID;
	FacebookWrapper *fbWrapper;
	
	sqlite3 *attacksDatabase;
	NSMutableArray *dbAttacks;
	NSMutableArray *dbAttackedBy;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AntAmbushViewController *viewController;
@property (nonatomic, retain) IBOutlet SigninViewController *signinViewController;
@property (nonatomic, retain) IBOutlet AttackViewController *attackViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *attackNavigationController;
@property (nonatomic, retain) NSMutableArray *dbAttacks;
@property (nonatomic, retain) NSMutableArray *dbAttackedBy;
@property (nonatomic, retain) NSString *userFbID;
@property (nonatomic, retain) FacebookWrapper *fbWrapper;
@property (nonatomic) sqlite3 *attacksDatabase;

-(void)switchFromLoginView;
-(void)createEditableCopyOfDatabase:(NSString*)fileName;
-(void)initializeAttacksDatabase:(NSString*)fileName;
-(void)clearAttacksDB;
-(void)addAttack:(History*)historyItem sendToServer:(BOOL)sendToServer attackID:(NSString*)attackID;
-(NSDictionary*)findAttackInPList:(NSString*)imageNameToFind;

@end

