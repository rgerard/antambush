//
//  PandaAttackAppDelegate.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PandaAttackAppDelegate.h"
#import "History.h"

static NSString *ImageKey = @"imageKey";
static NSString *NameKey = @"nameKey";

@implementation PandaAttackAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize attackViewController;
@synthesize attackNavigationController;
@synthesize userEmail;
@synthesize signinViewController;
@synthesize dbAttacks, dbAttackedBy;
@synthesize attacksDatabase;
@synthesize fbWrapper;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// Init the DB
	[self createEditableCopyOfDatabase:@"recentAttacks.db"];
	[self initializeAttacksDatabase:@"recentAttacks.db"];	
	
	// Check to see if we know who this user is
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	self.userEmail = [prefs stringForKey:@"userEmail"];
	
	// Init the Facebook Wrapper
	fbWrapper = [[FacebookWrapper alloc] init];
	
    // Init the controllers
	signinViewController = [[SigninViewController alloc] initWithWrapper:fbWrapper];
	attackViewController = [[AttackViewController alloc] initWithWrapper:fbWrapper];
	attackViewController.title = @"Panda Attack";
	attackViewController.view.backgroundColor = [[[UIColor alloc] initWithRed:0.1 green:0.2 blue:0.6 alpha:0.5] autorelease];
	
	// Setup the controller properties
	attackNavigationController = [[UINavigationController alloc] initWithRootViewController:attackViewController];
	attackNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
	
	[self startTimer];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)startTimer {
	SEL methodSelector = @selector(viewSwitch);
	
	// 2 second timer that will call the tabBarSwitch method
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:methodSelector userInfo:nil repeats:NO];
}

/*
 Switches over to the Tab Bar Controller's View
 */
- (void)viewSwitch {
	
	// Remove the opening view controller
	[viewController.view removeFromSuperview];
	
	// Check for a user email or FB ID -- prompt for signin view if not present
	if([self.userEmail length] == 0 && ![self.fbWrapper isLoggedInToFB]) {
		[window addSubview:signinViewController.view];
	} else {
		// Add the tab bar view to the window
		[window addSubview:attackNavigationController.view];
	}
	
	// Subscribe to orientation changes
	//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}


/*
 Switches from login view to the main view
 */
- (void)switchFromLoginView {
	// Get the users email address
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	self.userEmail = [prefs stringForKey:@"userEmail"];
	
	// Remove the signin view controller
	[signinViewController.view removeFromSuperview];
	
	// Add the tab bar view to the window
	[window addSubview:attackNavigationController.view];
	
	// Subscribe to orientation changes
	//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}


-(void)createEditableCopyOfDatabase:(NSString*)dbFileName {
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbFileName];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if(success) {
		NSLog(@"DB at %@", writableDBPath);
		return;
	}
	
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbFileName];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if(!success) {
		NSAssert1(0, @"Failed to create writable database: ", [error localizedDescription]);
	}
}

-(void)initializeAttacksDatabase:(NSString*)dbFileName {
	dbAttacks = [[NSMutableArray alloc] initWithCapacity:1];
	dbAttackedBy = [[NSMutableArray alloc] initWithCapacity:1];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFileName];
	
	if(sqlite3_open([path UTF8String], &attacksDatabase) == SQLITE_OK) {
		
		// Get all attacks made by you
		const char* sql_me = "SELECT id FROM attacks WHERE serverID=0";
		sqlite3_stmt *statement_me;
		
		if(sqlite3_prepare_v2(attacksDatabase, sql_me, -1, &statement_me, NULL) == SQLITE_OK) {
			while(sqlite3_step(statement_me) == SQLITE_ROW) {
				int primaryKey = sqlite3_column_int(statement_me, 0);
				History *hist = [[History alloc] initWithPrimaryKey:primaryKey database:attacksDatabase];
				[dbAttacks addObject:hist];
				[hist release];
			}
		}
		sqlite3_finalize(statement_me);
		
		// Get all attacks made on you
		const char* sql = "SELECT id FROM attacks WHERE serverID > 0";
		sqlite3_stmt *statement;
		
		if(sqlite3_prepare_v2(attacksDatabase, sql, -1, &statement, NULL) == SQLITE_OK) {
			while(sqlite3_step(statement) == SQLITE_ROW) {
				int primaryKey = sqlite3_column_int(statement, 0);
				History *hist = [[History alloc] initWithPrimaryKey:primaryKey database:attacksDatabase];
				[dbAttackedBy addObject:hist];
				[hist release];
			}
		}
		sqlite3_finalize(statement);
	} else {
		sqlite3_close(attacksDatabase);
		NSAssert1(0, @"Failed to open database: %s", sqlite3_errmsg(attacksDatabase));
	}
}

-(void)addAttack:(History*)historyItem sendToServer:(BOOL)sendToServer emailAttack:(BOOL)emailAttack attackID:(NSString*)attackID {
	NSLog(@"Adding attack from AppDelegate!");
	[self.attackViewController addAttack:historyItem sendToServer:sendToServer emailAttack:emailAttack attackID:attackID];
}

// Given an image name, find the attack item in the local plist of attacks
-(NSDictionary*)findAttackInPList:(NSString*)imageNameToFind {
	
	// Prep the image list
	NSString *path = [[NSBundle mainBundle] pathForResource:@"iphone_contents" ofType:@"plist"];
	NSArray *contentList = [NSArray arrayWithContentsOfFile:path];	
	NSDictionary *plistItem;
	
	// Get the image to load from a plist file inside our app bundle	
	bool found = false;
	for(int i=0; i < [contentList count]; i++) {
		plistItem = [contentList objectAtIndex:i];
		NSString *imageKey = [plistItem valueForKey:ImageKey];
		
		if([imageKey isEqualToString:imageNameToFind]) {
			found = true;
			break;
		}
	}
	
	if(found) {
		return plistItem;
	} else {
		return nil;
	}
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	return [self.fbWrapper handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[fbWrapper release];
	[dbAttacks release];
	[dbAttackedBy release];
    [viewController release];
	[attackViewController release];
    [window release];
    [super dealloc];
}


@end
