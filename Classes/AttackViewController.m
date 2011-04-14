//
//  AttackViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttackViewController.h"
#import "WeaponScrollerViewController.h"
#import "PandaAttackAppDelegate.h"
#import "History.h"
#import "AttackHistoryViewController.h"
#import "CJSONDeserializer.h"
#import "UIImageAlertView.h"

@implementation AttackViewController

@synthesize recentAttacksViewController, recentlyAttackedByViewController, startAttackBtn, viewHistoryBtn, request, currentUserToAttack;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Init the spinner
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[spinner setCenter:CGPointMake(self.view.frame.size.width/2.0, (self.view.frame.size.height-150)/2.0)]; 
	
	// Create and track a local attackHistory object
	attackHistory = [[History alloc] init];
	
	// Create a logout button
	UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutUser:)];          
	self.navigationItem.rightBarButtonItem = anotherButton;
	[anotherButton release];
	
	// Init the event handlers
	[startAttackBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[viewHistoryBtn addTarget:self action:@selector(viewHistoryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	
	// Create the recent attacks table
	CGRect recentAttacksViewFrame = CGRectMake(100,100,200,150);
	self.recentAttacksViewController = [[RecentAttacksViewController alloc] init];
	self.recentAttacksViewController.loadAttacksFromMe = YES;
	[self.recentAttacksViewController.view setFrame:recentAttacksViewFrame];
	[self.view addSubview:self.recentAttacksViewController.view];

	CGRect recentlyAttackedByViewFrame = CGRectMake(100,250,200,150);
	self.recentlyAttackedByViewController = [[RecentAttacksViewController alloc] init];
	self.recentlyAttackedByViewController.loadAttacksFromMe = NO;
	[self.recentlyAttackedByViewController.view setFrame:recentlyAttackedByViewFrame];
	[self.view addSubview:self.recentlyAttackedByViewController.view];
	
	// Check to see if we know who this user is
	self.currentUserToAttack = @"";
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *userEmail = [prefs stringForKey:@"userEmail"];
	NSString *lastAttackId = [prefs stringForKey:@"lastAttackId"];
	if(lastAttackId == nil) {
		lastAttackId = @"-1";
	}
	
	if([userEmail length] > 0) {
		// Start the spinner
		[self.view addSubview:spinner];
		[spinner startAnimating];
		
		NSString *formatUrl = [NSString stringWithFormat:@"http://localhost:3000/user_attacks/lookup?email=%@&lastid=%@",userEmail,lastAttackId];
		NSURL *url = [NSURL URLWithString:formatUrl];
		self.request = [ASIHTTPRequest requestWithURL:url];
		[self.request setDelegate:self];
		[self.request startAsynchronous];
	}
}


-(void)requestFinished:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[spinner stopAnimating];
	[spinner removeFromSuperview];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *lastAttackIdStr = [prefs stringForKey:@"lastAttackId"];
	int lastAttackId = [lastAttackIdStr intValue];
	
	// Use when fetching text data
	NSString *responseString = [requestCallback responseString];
	NSLog(@"%@", responseString);
	
	NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	NSArray *attackData = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:&error];
	
	// Prep the image list
	NSString *ImageKey = @"imageKey";
	NSString *NameKey = @"nameKey";
	NSString *path = [[NSBundle mainBundle] pathForResource:@"iphone_contents" ofType:@"plist"];
	NSArray *contentList = [NSArray arrayWithContentsOfFile:path];	
	
	// Iterate over array
	NSEnumerator *e = [attackData objectEnumerator];
	id object;
	int newAttackId = lastAttackId;
	while (object = [e nextObject]) {
		NSDictionary *dictionary = (NSDictionary *)object;
		NSLog(@"ID is %@", [dictionary objectForKey:@"attack_id"]);
		NSLog(@"Name is %@", [dictionary objectForKey:@"attacker_name"]);
		NSLog(@"Email is %@", [dictionary objectForKey:@"attacker_email"]);
		NSLog(@"Attack image is %@", [dictionary objectForKey:@"attack_image"]);
		NSLog(@"Message is %@", [dictionary objectForKey:@"message"]);
		
		NSString *newAttackIdStr = [dictionary objectForKey:@"attack_id"];
		NSString *attackerName = [dictionary objectForKey:@"attacker_name"];
		NSString *attackerEmail = [dictionary objectForKey:@"attacker_email"];
		NSString *attackImage = [dictionary objectForKey:@"attack_image"];
		NSString *attackMessage = [dictionary objectForKey:@"message"];
		
		// Show the attack if it's greater than the last one recorded
		if([newAttackIdStr intValue] > lastAttackId) {
			
			// Record the new largest attack ID -- checking this because multiple attacks could come out of order,
			// so we need to keep track of last attack ID and new largest attack ID
			if([newAttackIdStr intValue] > newAttackId) {
				newAttackId = [newAttackIdStr intValue];
			}
		
			// Get the image to load from a plist file inside our app bundle
			NSDictionary *numberItem;
			bool found = false;
			for(int i=0; i < [contentList count]; i++) {
				numberItem = [contentList objectAtIndex:i];
				NSString *imageKey = [numberItem valueForKey:ImageKey];
				
				if([imageKey isEqualToString:attackImage]) {
					found = true;
					break;
				}
			}
		
			if(found) {
				// Determine which name/email to use
				NSString *nameToUse = attackerName;
				if([nameToUse isEqualToString:@"Unknown"]) {
					nameToUse = attackerEmail;
				}
				
				// Set the current user to attack
				self.currentUserToAttack = attackerEmail;
				
				// Create a new history object to record this in the DB
				History *newAttack = [[History alloc] init];
				newAttack.serverID = [newAttackIdStr intValue];
				newAttack.contact = attackerEmail;
				newAttack.attack = attackImage;
				newAttack.message = attackMessage;

				// Add the attack to the DB
				PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
				[appDelegate addAttack:newAttack sendToServer:NO];
				
				// Popup dialog now
				UIImageAlertView *alert = [[UIImageAlertView alloc] initWithTitle:@"Attacked!" message:[NSString stringWithFormat:@"You were attacked by %@, who said '%@'", nameToUse, attackMessage] delegate:self cancelButtonTitle:@"Wuss out" otherButtonTitles:@"Attack back",nil];
				[alert setImage:[UIImage imageNamed:[numberItem valueForKey:ImageKey]]];
				[alert show];
				[alert release];
			}
		}
	}
	
	// Record the new latest attack id
	//if(newAttackId > lastAttackId) {
	//	[prefs setObject:[NSString stringWithFormat: @"%d", newAttackId] forKey:@"lastAttackId"];
	//	[prefs synchronize];
	//}
}


-(void)requestFailed:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[spinner stopAnimating];
	[spinner removeFromSuperview];
	
	NSError *error = [requestCallback error];
	NSLog(@"Error request: %@", [error localizedDescription]);
}


-(void)logoutUser:(id)sender{
	// Clear the users email address
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:@"" forKey:@"userEmail"];
	[prefs synchronize];
}


// respond to the Attack button click
-(void)startBtnClick:(UIView*)clickedButton {
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	
    [self presentModalViewController:picker animated:YES];
    [picker release];
}


// respond to the View History button click
-(void)viewHistoryBtnClick:(UIView*)clickedButton {
	AttackHistoryViewController *historyViewController = [[AttackHistoryViewController alloc] init];
	historyViewController.title = @"History";
	[self.navigationController pushViewController:historyViewController animated:YES];
	[historyViewController release];	
}
	

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
	
	// Popup dialog now asking to input email address
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Want to add?" message:@"Couldn't find the person you're looking for?  Do you want to input their email address now?" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Hell yeah!",nil];
	[alert show];
	[alert release];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	bool startGame = false;
	
    NSString* name = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	NSLog(@"%s",name);
	if([name isEqualToString:@"zahra"]) {
		startGame = true;
	}
	NSLog(@"%s",name);
	
	ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
	CFStringRef emailAddress;
	for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
		emailAddress = ABMultiValueCopyValueAtIndex(email, i);
		NSLog(@"%s",emailAddress);
	}
	
    [self dismissModalViewControllerAnimated:YES];
	
	if(startGame) {
		self.currentUserToAttack = (NSString *)emailAddress;
		[self changeToWeaponView];	
	} else {
		// Popup dialog now
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't find" message:@"We can't find Maryam!  Want to invite?" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Hell yeah!",nil];
		[alert show];
		[alert release];
	}
	
	[name release];
	CFRelease(emailAddress);
	
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];  
	
    if([title isEqualToString:@"Hell yeah!"]) {  
        NSLog(@"Please invite");
		
		if([MFMailComposeViewController canSendMail]) {
		
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			[picker setSubject:@"Hello iPhone!"];
		
			// Set up recipients
			NSArray *toRecipients = [NSArray arrayWithObject:@"ryan.gerard@gmail.com"];
			NSString *emailBody = @"Nice  to See you!";
			[picker setToRecipients:toRecipients];
			[picker setMessageBody:emailBody isHTML:NO];
		
			[self presentModalViewController:picker animated:YES];
			[picker release];
		} else {
			NSLog(@"Device can't send mail!");
		}
    } else if([title isEqualToString:@"Attack back"]) {
		NSLog(@"Uesr wants to attack back");
		[self changeToWeaponView];
	}
} 

-(void)changeToWeaponView {
	// Fill the History object
	attackHistory.contact = self.currentUserToAttack;
	
	WeaponScrollerViewController *weaponViewController = [[WeaponScrollerViewController alloc] init];
	weaponViewController.title = @"Weapon";
	weaponViewController.attackHistory = attackHistory;
	[self.navigationController pushViewController:weaponViewController animated:YES];
	[weaponViewController release];	
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
	switch (result) {
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

// respond to the ask button click
-(void)personBtnClick:(UIView*)clickedButton {
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFErrorRef anError;
	
	ABRecordRef aRecord = ABPersonCreate();
	ABRecordSetValue(aRecord, kABPersonFirstNameProperty, CFSTR("zahra"), &anError);
	ABRecordSetValue(aRecord, kABPersonLastNameProperty, CFSTR("ghofraniha"), &anError);
	
	ABMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(email, @"zahra.ghofraniha@gmail.com", kABHomeLabel, NULL);
	ABMultiValueAddValueAndLabel(email, @"zahrag@google.com", kABWorkLabel, NULL);
	
	ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
	
	ABAddressBookAddRecord(addressBook, aRecord, &anError);
	ABAddressBookSave(addressBook, &anError);
	
	CFRelease(aRecord);
	CFRelease(addressBook);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
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
	[recentAttacksViewController release];
	[currentUserToAttack release];
	[request clearDelegatesAndCancel];
	[request release];	
	[attackHistory release];
    [super dealloc];
}


@end
