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

@implementation AttackViewController

@synthesize recentAttacksTable, startAttackBtn, viewHistoryBtn;

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
	
	recentAttacksTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	recentAttacksTable.delegate = self;
	recentAttacksTable.dataSource = self;
	
	// Create and track a local attackHistory object
	attackHistory = [[History alloc] init];
	
	UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutUser:)];          
	self.navigationItem.rightBarButtonItem = anotherButton;
	[anotherButton release];
	
	// Init the event handlers
	[startAttackBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[viewHistoryBtn addTarget:self action:@selector(viewHistoryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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
		// Fill the History object
		attackHistory.contact = (NSString *)emailAddress;
		
		WeaponScrollerViewController *weaponViewController = [[WeaponScrollerViewController alloc] init];
		weaponViewController.title = @"Weapon";
		weaponViewController.attackHistory = attackHistory;
		[self.navigationController pushViewController:weaponViewController animated:YES];
		[weaponViewController release];		
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
    } 
} 

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
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


//
//  UITableView Functions
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if(appDelegate.dbHistory != nil) {
		NSLog(@"DB count: %u", appDelegate.dbHistory.count);
		return appDelegate.dbHistory.count;
	} else {
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	History *item = [appDelegate.dbHistory objectAtIndex:indexPath.row];
	cell.textLabel.text = item.contact;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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
	[attackHistory release];
	[recentAttacksTable release];
    [super dealloc];
}


@end
