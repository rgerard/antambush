//
//  FBTableViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FBTableViewController.h"
#import "FacebookUser.h"
#import "WeaponScrollerViewController.h"

@implementation FBTableViewController

@synthesize fbWrapper, attackHistory;

#pragma mark -
#pragma mark View lifecycle

-(void) setFbWrapper:(FacebookWrapper*)wrapper {
	fbWrapper = [wrapper retain];
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
    return [self.fbWrapper.friendData count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSString* key = [self.fbWrapper.friendDataSortedKeys objectAtIndex:section];
	NSMutableArray* nameArr = [self.fbWrapper.friendData objectForKey:key];
	
	return [nameArr count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString* key = [self.fbWrapper.friendDataSortedKeys objectAtIndex:section];
	return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return self.fbWrapper.friendDataSortedKeys;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSString* key = [self.fbWrapper.friendDataSortedKeys objectAtIndex:indexPath.section];
	NSMutableArray* nameArr = [self.fbWrapper.friendData objectForKey:key];
	FacebookUser* user = [nameArr objectAtIndex:indexPath.row];
    cell.textLabel.text = user.fbName;
	
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Get data on the user picked
	NSString* key = [self.fbWrapper.friendDataSortedKeys objectAtIndex:indexPath.section];
	NSMutableArray* nameArr = [self.fbWrapper.friendData objectForKey:key];
	FacebookUser* user = [nameArr objectAtIndex:indexPath.row];
	
	// Set data on the History object
	attackHistory.contactName = user.fbName;
	attackHistory.contactFbID = user.fbID;
	NSLog(@"Person picked is %@, with ID %@", attackHistory.contactName, attackHistory.contactFbID);
	
	// Load up the weapon view controller
	WeaponScrollerViewController *weaponViewController = [[WeaponScrollerViewController alloc] init];
	weaponViewController.title = @"Weapon";
	weaponViewController.attackHistory = attackHistory;
	[self.navigationController pushViewController:weaponViewController animated:YES];
	[weaponViewController release];	
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
    [super dealloc];
}


@end

