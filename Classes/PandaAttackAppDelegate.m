//
//  PandaAttackAppDelegate.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PandaAttackAppDelegate.h"
#import "History.h"

@implementation PandaAttackAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize attackViewController;
@synthesize attackNavigationController;
@synthesize dbHistory;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// Init the DB
	[self createEditableCopyOfDatabase];
	[self initializeDatabase];
	
    // Init the controllers
	attackViewController = [[AttackViewController alloc] init];
	attackNavigationController = [[UINavigationController alloc] initWithRootViewController:attackViewController];
	
	// Setup the controller properties
	attackNavigationController.title = @"Attack!";
	
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
	
	// Add the tab bar view to the window
	[window addSubview:attackNavigationController.view];
	
	// Subscribe to orientation changes
	//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

-(void)createEditableCopyOfDatabase {
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"attackHistory.db"];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if(success) {
		return;
	}
	
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"attackHistory.db"];
	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if(!success) {
		NSAssert1(0, @"Failed to create writable database: ", [error localizedDescription]);
	}
}

-(void)initializeDatabase {
	dbHistory = [[NSMutableArray alloc] initWithCapacity:1];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"attackHistory.db"];
	
	if(sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		const char* sql = "SELECT id FROM history";
		sqlite3_stmt *statement;
		
		if(sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
			while(sqlite3_step(statement) == SQLITE_ROW) {
				int primaryKey = sqlite3_column_int(statement, 0);
				History *hist = [[History alloc] initWithPrimaryKey:primaryKey database:database];
				[dbHistory addObject:hist];
				[hist release];
			}
		}
		
		sqlite3_finalize(statement);
	} else {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database: %s", sqlite3_errmsg(database));
	}
}

-(void)addAttack:(History*)historyItem {
	NSLog(@"Adding attack!");
	NSInteger pk = [historyItem insertNewAttack:database];
	History *item = [[History alloc] initWithPrimaryKey:pk database:database];
	[dbHistory addObject:item];
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
	[dbHistory release];
    [viewController release];
	[attackViewController release];
    [window release];
    [super dealloc];
}


@end
