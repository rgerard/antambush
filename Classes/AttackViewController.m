//
//  AttackViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttackViewController.h"
#import "AntAmbushAppDelegate.h"
#import "History.h"
#import "CJSONDeserializer.h"
#import "UIImageAlertView.h"
#import "SettingsViewController.h"
#import "FBTableViewController.h"
#import "WeaponScrollerViewController.h"
#import "MixpanelAPI.h"

static NSString *key = @"AHYFT36395NN3YD86DH";
static NSString *ImageKey = @"imageKey";
static NSString *NameKey = @"nameKey";
static NSString *rootUrl = @"http://www.antambush.com";
//static NSString *rootUrl = @"http://localhost:3000";

@implementation AttackViewController

@synthesize startAttackBtn, scrollPunkdBtn, scrollAttackedBtn, request, fbWrapper, spinner;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
-(id)initWithWrapper:(FacebookWrapper *)wrapper {
	self = [super init];
	if (self) {
		// Custom initialization.
		fbWrapper = [wrapper retain];
	}
	return self;
}

-(void)setSpinningMode:(BOOL)isWaiting detailTxt:(NSString *)detailTxt {
	//when network action, toggle network indicator and activity indicator
	if (isWaiting) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        self.spinner = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.spinner];
		self.spinner.labelText = @"Loading";
		self.spinner.detailsLabelText = detailTxt;
		[self.spinner show:YES];
	} else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.spinner removeFromSuperview];
        [self.spinner release];
        self.spinner = nil;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"View did load!");
	
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel trackFunnel:@"Attack Friend" step:1 goal:@"App Loaded"];
    
	// Create and track a local History object
	attackHistory = [[History alloc] init];
	
	// Create a setting button
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsBtnClick:)];          
	self.navigationItem.leftBarButtonItem = settingsButton;
	[settingsButton release];
	
	// Init the event handlers
	[startAttackBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[scrollPunkdBtn addTarget:self action:@selector(scrollPunkdBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [scrollAttackedBtn addTarget:self action:@selector(scrollAttackedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)serverRequestForAttacks {

    // Cancel any current requests
    [request clearDelegatesAndCancel];
    
	// Check to see if we know who this user is
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *lastAttackId = [prefs stringForKey:@"lastAttackId"];
	NSString *deviceToken = [prefs stringForKey:@"deviceToken"];
	
	if(lastAttackId == nil || [lastAttackId length] == 0) {
		lastAttackId = @"-1";
	}
	
	if(deviceToken == nil || [deviceToken length] == 0) {
		deviceToken = @"-2";
	}
	
	NSString *fbUserID = [prefs stringForKey:@"fbID"];
	
	if(fbWrapper != nil && deviceToken != nil && [fbUserID length] > 0) {
		
		// Ask server if there are any new attacks on this user -- use the FB ID if available, otherwise use email
		NSString *formatUrl;
		
		if([fbUserID length] > 0) {
			formatUrl = [NSString stringWithFormat:@"%@/user_attacks/lookup?fbid=%@&lastid=%@&device_token=%@",rootUrl,fbUserID,lastAttackId,deviceToken];
            NSURL *url = [NSURL URLWithString:formatUrl];
            
            [self setSpinningMode:YES detailTxt:@"Lookup Attacks"];
            self.request = [ASIHTTPRequest requestWithURL:url];
            [self.request setDelegate:self];
            [self.request startAsynchronous];
        }
    }	
}

// Callback from the server request asking for new attacks
-(void)requestFinished:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[self setSpinningMode:NO detailTxt:@""];
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel track:@"ServerRequestSuccess"];
    
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *lastAttackIdStr = [prefs stringForKey:@"lastAttackId"];
	int lastAttackId = [lastAttackIdStr intValue];
	
	// Use when fetching text data
	NSString *responseString = [requestCallback responseString];
	NSLog(@"%@", responseString);
	
	NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	NSArray *attackData = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:&error];
	
	// Iterate over array
	NSEnumerator *e = [attackData objectEnumerator];
	id object;
	int newAttackId = lastAttackId;
	int shownAttacks = 0;
	while ((object = [e nextObject])) {
		NSDictionary *dictionary = (NSDictionary *)object;
		
		NSString *newAttackIdStr = [dictionary objectForKey:@"attack_id"];
		NSString *attackerName = [dictionary objectForKey:@"attacker_name"];
		NSString *attackerFbID = [dictionary objectForKey:@"attacker_fbid"];
		NSString *attackImage = [dictionary objectForKey:@"attack_image"];
		NSString *attackMessage = [dictionary objectForKey:@"message"];
		
		NSLog(@"ID is %@", newAttackIdStr);
		NSLog(@"Name is %@", attackerName);
		NSLog(@"FBID is %@", attackerFbID);
		NSLog(@"Attack image is %@", attackImage);
		NSLog(@"Message is %@", attackMessage);
		
		// Show the attack if it's greater than the last one recorded
		if([newAttackIdStr intValue] > lastAttackId) {
			
			// Record the new largest attack ID -- checking this because multiple attacks could come out of order,
			// so we need to keep track of last attack ID and new largest attack ID
			if([newAttackIdStr intValue] > newAttackId) {
				newAttackId = [newAttackIdStr intValue];
			}
		
			// Get the image to load from a plist file inside our app bundle
			AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSDictionary *numberItem = [appDelegate findAttackInPList:attackImage];
		
			// Only show 3 recent attacks -- we don't want the user being deluged with attacks
			if(numberItem != nil && shownAttacks < 3) {
				
				// Set the current user to attack
				attackHistory.contactFbID = attackerFbID;
				
				// Create a new history object to record this in the DB
				History *newAttack = [[History alloc] init];
				newAttack.serverID = [newAttackIdStr intValue];
				newAttack.contactFbID = attackerFbID;
				newAttack.contactName = attackerName;
				newAttack.attack = attackImage;
				newAttack.message = attackMessage;

				// Add the attack to the DB
				[self addAttack:newAttack sendToServer:NO attackID:newAttackIdStr];
				
				// Release the history object just created
				[newAttack release];
				
				// Popup dialog now
				UIImageAlertView *alert = [[UIImageAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Attacked by %@!", attackerName] message:[NSString stringWithFormat:@"You were attacked with %@! '%@'", [numberItem valueForKey:NameKey], attackMessage] delegate:self cancelButtonTitle:@"Wuss out" otherButtonTitles:@"Attack back",nil];
				[alert setImage:[UIImage imageNamed:[numberItem valueForKey:ImageKey]] attackNameStr:[numberItem valueForKey:NameKey]];
				[alert show];
				[alert release];
				
				shownAttacks++;
			}
		}
	}
	
	// Record the new latest attack id
	if(newAttackId > lastAttackId) {
		[prefs setObject:[NSString stringWithFormat: @"%d", newAttackId] forKey:@"lastAttackId"];
		[prefs synchronize];
	}
	
	// Ask for your list of FB friends
	[self setSpinningMode:YES detailTxt:@"Get Facebook Friends"];
	[fbWrapper getFriendInfo:@selector(facebookFriendsCallback) delegate:self];
}


-(void)requestFailed:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[self setSpinningMode:NO detailTxt:@""];
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel track:@"ServerRequestFailure"];
	
	NSError *error = [requestCallback error];
	NSLog(@"Error request: %@", [error localizedDescription]);
	
	// Ask for your list of FB friends
	[self setSpinningMode:YES detailTxt:@"Get Facebook Friends"];
	[fbWrapper getFriendInfo:@selector(facebookFriendsCallback) delegate:self];
}


// Verify that you're logged in, and then ask for the 'friends' info
-(void) facebookMeCallback {
	if([fbWrapper isLoggedInToFB]) {
		NSLog(@"Asking for friends info");
		[fbWrapper getFriendInfo:@selector(facebookFriendsCallback) delegate:self];
	}
}


-(void) facebookFriendsCallback {
	// Stop the spinner
	[self setSpinningMode:NO detailTxt:@""];
}


-(void)settingsBtnClick:(id)sender{
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel track:@"SettingsButtonClicked"];
    
	//Open the settings page
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	settingsViewController.title = @"Settings";
	[settingsViewController setFbWrapper:fbWrapper];
	[self.navigationController pushViewController:settingsViewController animated:YES];
	[settingsViewController release];		
}


// respond to the Attack button click
-(void)startBtnClick:(UIView*)clickedButton {
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel trackFunnel:@"Attack Friend" step:2 goal:@"Start Button Clicked"];
    [mixpanel track:@"StartAttackClicked"];
    
	FBTableViewController *table = [[FBTableViewController alloc] initWithStyle:UITableViewStylePlain];
	[table setFbWrapper:fbWrapper];
	table.attackHistory = attackHistory;
	[self.navigationController pushViewController:table animated:YES];
	[table release];
}

// respond to the You were punkd button click
-(void)scrollPunkdBtnClick:(UIView*)clickedButton {
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:@"PunkedBtnClicked"];
    
	// Create the "recently attacked by" table
    RecentAttacksViewController *recentPunkdViewController = [[RecentAttacksViewController alloc] init];
	recentPunkdViewController.title = @"Punk'd By";
    recentPunkdViewController.loadAttacksFromMe = NO;
	[self.navigationController pushViewController:recentPunkdViewController animated:YES];
	[recentPunkdViewController release];	
}

// respond to the You recently attacked button click
-(void)scrollAttackedBtnClick:(UIView*)clickedButton {
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:@"AttackedBtnClicked"];
    
	// Create the "recently attacked" table
    RecentAttacksViewController *recentAttackedViewController = [[RecentAttacksViewController alloc] init];
	recentAttackedViewController.title = @"Punk'd By";
    recentAttackedViewController.loadAttacksFromMe = YES;
	[self.navigationController pushViewController:recentAttackedViewController animated:YES];
	[recentAttackedViewController release];	
}

// Responds to people saying they want to invite someone
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];  
	
    if([title isEqualToString:@"Attack back"]) {
        MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
        [mixpanel track:@"Attack_AttackBack"];
        
		NSLog(@"User wants to attack back");
		[self changeToWeaponView];
	} else if([title isEqualToString:@"Wuss out"]) {
        MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
        [mixpanel track:@"Attack_WussOut"];
        
		// Clear out the user to attack if the user says to cancel
		attackHistory.contactFbID = @"";
	}
} 


-(void)changeToWeaponView {
	// Load up the weapon view controller
	WeaponScrollerViewController *weaponViewController = [[WeaponScrollerViewController alloc] init];
	weaponViewController.title = @"Weapon";
	weaponViewController.attackHistory = attackHistory;
	[self.navigationController pushViewController:weaponViewController animated:YES];
	[weaponViewController release];	
}


-(void)addAttack:(History*)historyItem sendToServer:(BOOL)sendToServer attackID:(NSString*)attackID {
	NSLog(@"Adding attack from ViewController!");
	AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSInteger pk = [historyItem insertNewAttack:appDelegate.attacksDatabase];
	
	// Check to make sure it inserted correctly
	if(pk == -1) {
		NSLog(@"Attack didn't insert correctly.  Returning.");
		return;
	}
	
	if(historyItem.serverID == 0) {
		[appDelegate.dbAttacks addObject:historyItem];
	} else {
		[appDelegate.dbAttackedBy addObject:historyItem];
	}
	
	// Clear out the history item
	[attackHistory release];
	attackHistory = [[History alloc] init];
	
	if(sendToServer == YES) {
		
		// Don't send a real URL for now
		NSString *urlToSend = [NSString stringWithFormat:@"%@/user_attacks/get?hash=%@", rootUrl, attackID];
		//NSString *urlToSend = rootUrl;
		
		AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
		NSDictionary *numberItem = [appDelegate findAttackInPList:historyItem.attack];
		NSString *attackStr = @"something";
        NSString *attackImage = @"nothing.jpg";
		
		if(numberItem != nil) {
			attackStr = [numberItem valueForKey:NameKey];
            attackImage = [numberItem valueForKey:ImageKey];
		}
		
		[fbWrapper facebookPublishNote:historyItem.contactFbID message:historyItem.message url:urlToSend attack:attackStr attackImage:attackImage];
		
		/*if([MFMailComposeViewController canSendMail]) {
				
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:@"Attacked!"];
			
			// Set up recipients
			NSArray *toRecipients = [NSArray arrayWithObject:historyItem.contactFbID];
			NSString *emailBody = [NSString stringWithFormat:@"You have been attacked with %@!  The message is: %@.  View this attack at: %@", historyItem.attack, historyItem.message, urlToSend];
			[picker setToRecipients:toRecipients];
			[picker setMessageBody:emailBody isHTML:NO];
				
			[self presentModalViewController:picker animated:YES];
			[picker release];
		} */
	}
}


-(NSString *) obfuscate:(NSString *)string {
	// Create data object from the string
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	// Get pointer to data to obfuscate
	char *dataPtr = (char *) [data bytes];
	
	// Get pointer to key data
	char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
	
	// Points to each char in sequence in the key
	char *keyPtr = keyData;
	int keyIndex = 0;
	
	// For each character in data, xor with current value in key
	for (int x = 0; x < [data length]; x++) {
		// Replace current character in data with 
		// current character xor'd with current key value.
		// Bump each pointer to the next character
		*dataPtr = *dataPtr++ ^ *keyPtr++; 
		
		// If at end of key data, reset count and 
		// set key pointer back to start of key value
		if (++keyIndex == [key length])
			keyIndex = 0, keyPtr = keyData;
	}
	
	return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}


-(void) setFbWrapper:(FacebookWrapper*)wrapper {
	fbWrapper = [wrapper retain];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    if(self.spinner != nil) {
        [self.spinner release];
        self.spinner = nil;
    }
    
	[fbWrapper release];
	
	[request clearDelegatesAndCancel];
	[request release];	
	
	[attackHistory release];
    [super dealloc];
}


@end
