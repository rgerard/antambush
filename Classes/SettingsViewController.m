//
//  SettingsViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "PandaAttackAppDelegate.h"
#import "History.h"

@implementation SettingsViewController

@synthesize fbWrapper;

#pragma mark -
#pragma mark View lifecycle


-(void) viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) setFbWrapper:(FacebookWrapper*)wrapper {
	fbWrapper = [wrapper retain];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if(indexPath.section == 0) {
		if(self.fbWrapper.isLoggedInToFB) {
			cell.textLabel.text = @"Logout";
		} else {
			cell.textLabel.text = @"Login";
		}
	} else if(indexPath.section == 1) {
		cell.textLabel.text = @"Clear Data";
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	// Logout User from App
	if(indexPath.section == 0) {
		NSLog(@"Clearing out known user data for logout");
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:@"" forKey:@"userEmail"];
		[prefs setObject:@"" forKey:@"fbID"];
		[prefs setObject:@"" forKey:@"fbFullname"];
		[prefs setObject:@"" forKey:@"fbFirstname"];
		[prefs setObject:@"" forKey:@"fbUsername"];
		[prefs setObject:@"" forKey:@"fbLoggedIn"];
		[prefs setObject:@"" forKey:@"lastAttackId"];
		[prefs synchronize];
		
		// Logout of FB if logged in
		if(self.fbWrapper.isLoggedInToFB) {
			NSLog(@"Logging out of Facebook");
			[self.fbWrapper facebookLogout:@selector(facebookLogoutCallback) delegate:self];
		} else {
			NSLog(@"Login to Facebook");
			[self facebookLoginClick];
		}
	} else if(indexPath.section == 1) {
		// Delete all data from the local database
		PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
		[History clearData:appDelegate.attacksDatabase];
	}
}


// respond to the start button click
-(void)facebookLoginClick {
	NSLog(@"Asking FB for permission");
	
	// Ask for permission to send the person email as well
	[fbWrapper facebookLogin:@selector(facebookLoginCallback) delegate:self];
}

// Verify that you're logged in, and then ask for the 'me' info
-(void) facebookLoginCallback {
	if([fbWrapper isLoggedInToFB]) {
		NSLog(@"Asking for me info");
		[fbWrapper getMeInfo:@selector(facebookMeCallback) delegate:self];
	}
}

// Verify that you're logged in, and then ask for the 'friends' info
-(void) facebookMeCallback {
	if([fbWrapper isLoggedInToFB]) {
		NSLog(@"Asking for friends info");
		[fbWrapper getFriendInfo:@selector(facebookFriendsCallback) delegate:self];
	}
}

-(void) facebookFriendsCallback {
	// Close this view
	NSLog(@"Got friends, closing this view");
	[self.tableView reloadData];
}

-(void) facebookLogoutCallback {
	NSLog(@"Logged out of Facebook");
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[fbWrapper release];
    [super dealloc];
}


@end

