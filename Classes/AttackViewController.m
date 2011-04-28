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
#import "CJSONDeserializer.h"
#import "UIImageAlertView.h"
#import "SingleAttackViewController.h"

static NSString *ImageKey = @"imageKey";
static NSString *NameKey = @"nameKey";

@implementation AttackViewController

@synthesize recentAttacksViewController, recentlyAttackedByViewController, startAttackBtn, viewHistoryBtn, request, formRequest, contactList;

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
	
	// Create and track a local History object
	attackHistory = [[History alloc] init];
	
	// Create the contact list picker object
	self.contactList = [[ContactListPicker alloc] init];
	[self.contactList setDelegateCallback:@selector(personPickedCallback) delegate:self];
	
	// Create a logout button
	UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutUser:)];          
	self.navigationItem.rightBarButtonItem = anotherButton;
	[anotherButton release];
	
	// Init the event handlers
	[startAttackBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	
	// Create the "recently attacked by" table
	CGRect recentlyAttackedByViewFrame = CGRectMake(15,100,290,150);
	self.recentlyAttackedByViewController = [[RecentAttacksViewController alloc] init];
	self.recentlyAttackedByViewController.loadAttacksFromMe = NO;
	[self.recentlyAttackedByViewController setDelegateCallback:@selector(attackPickedFromAttackedByTableCallback:) delegate:self];
	[self.recentlyAttackedByViewController.view setFrame:recentlyAttackedByViewFrame];
	[self.view addSubview:self.recentlyAttackedByViewController.view];		
	
	// Create the recent attacks table
	CGRect recentAttacksViewFrame = CGRectMake(15,250,290,150);
	self.recentAttacksViewController = [[RecentAttacksViewController alloc] init];
	self.recentAttacksViewController.loadAttacksFromMe = YES;
	[self.recentAttacksViewController setDelegateCallback:@selector(attackPickedFromAttackedTableCallback:) delegate:self];
	[self.recentAttacksViewController.view setFrame:recentAttacksViewFrame];
	[self.view addSubview:self.recentAttacksViewController.view];
	
	// Check to see if we know who this user is
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
		
		// Ask server if there are any new attacks on this user
		NSString *formatUrl = [NSString stringWithFormat:@"http://hollow-river-123.heroku.com/user_attacks/lookup?email=%@&lastid=%@",userEmail,lastAttackId];
		NSURL *url = [NSURL URLWithString:formatUrl];
		self.request = [ASIHTTPRequest requestWithURL:url];
		[self.request setDelegate:self];
		[self.request startAsynchronous];
	}
}

// Callback from the server request asking for new attacks
-(void)requestFinished:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[spinner stopAnimating];
	[spinner removeFromSuperview];
	
	// If this is from a POST request, return
	if(requestCallback.requestMethod == @"POST") {
		return;
	}
	
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
	while (object = [e nextObject]) {
		NSDictionary *dictionary = (NSDictionary *)object;
		
		NSString *newAttackIdStr = [dictionary objectForKey:@"attack_id"];
		NSString *attackerName = [dictionary objectForKey:@"attacker_name"];
		NSString *attackerEmail = [dictionary objectForKey:@"attacker_email"];
		NSString *attackImage = [dictionary objectForKey:@"attack_image"];
		NSString *attackMessage = [dictionary objectForKey:@"message"];
		
		NSLog(@"ID is %@", newAttackIdStr);
		NSLog(@"Name is %@", attackerName);
		NSLog(@"Email is %@", attackerEmail);
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
			PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
			NSDictionary *numberItem = [appDelegate findAttackInPList:attackImage];
		
			if(numberItem != nil) {
				// Determine which name/email to use
				NSString *nameToUse = attackerName;
				if([nameToUse isEqualToString:@"Unknown"]) {
					nameToUse = attackerEmail;
				}
				
				// Set the current user to attack
				attackHistory.contact = attackerEmail;
				
				// Create a new history object to record this in the DB
				History *newAttack = [[History alloc] init];
				newAttack.serverID = [newAttackIdStr intValue];
				newAttack.contact = attackerEmail;
				newAttack.contactName = attackerName;
				newAttack.attack = attackImage;
				newAttack.message = attackMessage;

				// Add the attack to the DB
				[self addAttack:newAttack sendToServer:NO emailAttack:YES];
				
				// Release the history object just created
				[newAttack release];
				
				// Popup dialog now
				UIImageAlertView *alert = [[UIImageAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Attacked by %@!", nameToUse] message:[NSString stringWithFormat:@"You were attacked with %@, who said '%@'", [numberItem valueForKey:NameKey], attackMessage] delegate:self cancelButtonTitle:@"Wuss out" otherButtonTitles:@"Attack back",nil];
				[alert setImage:[UIImage imageNamed:[numberItem valueForKey:ImageKey]] attackNameStr:[numberItem valueForKey:NameKey]];
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


-(void) personPickedCallback {
	// If emails aren't empty, grab the first email address of the person picked, and then load the weapon view
	if([contactList.personEmails count] > 0) {
		// Fill the History object
		attackHistory.contact = [contactList.personEmails objectAtIndex:0];
		attackHistory.contactName = contactList.personPickedName;
		attackHistory.smsAttack = NO;
		NSLog(@"Person picked is %@", attackHistory.contact);
	} else if([contactList.personNumbers count] > 0) {
		attackHistory.contact = [contactList.personNumbers objectAtIndex:0];
		attackHistory.contactName = contactList.personPickedName;
		attackHistory.smsAttack = YES;
		NSLog(@"Person picked is %@", attackHistory.contact);
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User missing data" message:@"This user doesn't have any email addresses or phone numbers.  We can't send the attack." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	[self changeToWeaponView];
}


-(void) attackPickedFromAttackedTableCallback:(NSIndexPath *)attackRow {
	// Open the single attack view
	NSLog(@"Attacked Table, Row = %d", attackRow.row);
	History *item = [self findAttackDataToUse:attackRow.row loadAttacksFromMe:YES];
	if(item == nil) {
		NSLog(@"Can't find attack item");
		return;
	}
	
	[self createAttackViewController:item];
}


-(void) attackPickedFromAttackedByTableCallback:(NSIndexPath *)attackRow {
	// Open the single attack view
	NSLog(@"AttackedBy Table, Row = %d", attackRow.row);
	History *item = [self findAttackDataToUse:attackRow.row loadAttacksFromMe:NO];
	if(item == nil) {
		NSLog(@"Can't find attack item");
		return;
	}
	
	[self createAttackViewController:item];
}


-(void)createAttackViewController:(History *)item {
	SingleAttackViewController *detailViewController = [[SingleAttackViewController alloc] init];
	[detailViewController addAttackData:item];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];	
}


-(History *) findAttackDataToUse:(int)row loadAttacksFromMe:(BOOL)loadAttacksFromMe {
	NSMutableArray *arrToUse;
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	if(loadAttacksFromMe == NO) {
		arrToUse = appDelegate.dbAttackedBy;
	} else {
		arrToUse = appDelegate.dbAttacks;	
	}
	
	if(arrToUse != nil) {
		History *item = [arrToUse objectAtIndex:row];
		return item;
    } else {
		NSLog(@"Array to use is nil!");
		return nil;
	}
}


-(void)logoutUser:(id)sender{
	// Clear the users email address
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:@"" forKey:@"userEmail"];
	[prefs synchronize];
}


// respond to the Attack button click
-(void)startBtnClick:(UIView*)clickedButton {
	[contactList openContactList];
}


-(void)changeToWeaponView {
	WeaponScrollerViewController *weaponViewController = [[WeaponScrollerViewController alloc] init];
	weaponViewController.title = @"Weapon";
	weaponViewController.attackHistory = attackHistory;
	[self.navigationController pushViewController:weaponViewController animated:YES];
	[weaponViewController release];	
}


// Responds to people saying they want to invite someone
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
		NSLog(@"User wants to attack back");
		[self changeToWeaponView];
	} else if([title isEqualToString:@"Wuss out"]) {
		// Clear out the user to attack if the user says to cancel
		attackHistory.contact = @"";
	}
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


-(void)addAttack:(History*)historyItem sendToServer:(BOOL)sendToServer emailAttack:(BOOL)emailAttack {
	NSLog(@"Adding attack!");
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSInteger pk = [historyItem insertNewAttack:appDelegate.attacksDatabase];
	
	// Check to make sure it inserted correctly
	if(pk == -1) {
		NSLog(@"Attack didn't insert correctly.  Returning.");
		return;
	}
	
	History *item = [[History alloc] initWithPrimaryKey:pk database:appDelegate.attacksDatabase];
	
	if(item.serverID == 0) {
		[appDelegate.dbAttacks addObject:item];
	} else {
		[appDelegate.dbAttackedBy addObject:item];
	}
	
	if(sendToServer == YES) {
		if(emailAttack == YES) {
			// Start the spinner
			[self.view addSubview:spinner];
			[spinner startAnimating];
			
			// Send the data to the backend
			NSURL *url = [NSURL URLWithString:@"http://hollow-river-123.heroku.com/user_attacks/createFromPhone"];
			formRequest = [ASIFormDataRequest requestWithURL:url];
			[formRequest setPostValue:appDelegate.userEmail forKey:@"user_attack[attacker_email]"];
			[formRequest setPostValue:item.contact forKey:@"user_attack[victim_email]"];
			[formRequest setPostValue:item.contactName forKey:@"user_attack[victim_name]"];
			[formRequest setPostValue:item.attack forKey:@"user_attack[attack_name]"];
			[formRequest setPostValue:item.message forKey:@"user_attack[message]"];
			[formRequest setDelegate:self];
			[formRequest startAsynchronous];
		} else {
			// Send an SMS instead
			MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
			if([MFMessageComposeViewController canSendText]) {
				controller.body = [NSString stringWithFormat:@"You just got attacked with %@!", item.attack];
				controller.recipients = [NSArray arrayWithObjects:item.contact, nil];
				controller.messageComposeDelegate = self;
				[self presentModalViewController:controller animated:YES];
			}
			[controller release];
		}
	}
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
			NSLog(@"Failed");
			break;
		case MessageComposeResultSent:
			break;
		default:
			break;
	}
	
	[self dismissModalViewControllerAnimated:YES];
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
	[contactList release];
	[recentAttacksViewController release];
	
	[request clearDelegatesAndCancel];
	[request release];	
	
	[formRequest clearDelegatesAndCancel];
	[formRequest release];
	
	[attackHistory release];
    [super dealloc];
}


@end
