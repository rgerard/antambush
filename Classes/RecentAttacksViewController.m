//
//  RecentAttacksViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentAttacksViewController.h"
#import "AntAmbushAppDelegate.h"
#import "RecentAttacksTableViewCell.h"
#import "SingleAttackViewController.h"

@implementation RecentAttacksViewController

@synthesize loadAttacksFromMe;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Initialization code.
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if(appDelegate.dbAttacks != nil) {
		
		if(self.loadAttacksFromMe == nil || self.loadAttacksFromMe == NO) {
			NSLog(@"DB count attacked by: %u", appDelegate.dbAttackedBy.count);
			return appDelegate.dbAttackedBy.count;
		} else {
			NSLog(@"DB count you attacked: %u", appDelegate.dbAttacks.count);
			return appDelegate.dbAttacks.count;	
		}
	} else {
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
	RecentAttacksTableViewCell *cell = (RecentAttacksTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[RecentAttacksTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSMutableArray *arrToUse;
	AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if(self.loadAttacksFromMe == nil || self.loadAttacksFromMe == NO) {
		arrToUse = appDelegate.dbAttackedBy;
	} else {
		arrToUse = appDelegate.dbAttacks;	
	}
	
	if(arrToUse != nil) {
		History *item = [arrToUse objectAtIndex:indexPath.row];
		[cell setData:item];
    } else {
		NSLog(@"Array to use is nil!");
	}
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *loadAttacksStr = @"NO";
    if(self.loadAttacksFromMe) {
        loadAttacksStr = @"YES";
    }
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:@"PickedAttackFromHistory" properties:[NSDictionary dictionaryWithObject:loadAttacksStr forKey:@"loadAttackFromMe"]];
    
	// Open the single attack view
	NSLog(@"AttackedBy Table, Row = %d", indexPath.row);
	History *item = [self findAttackDataToUse:indexPath.row loadAttacksFromMe:self.loadAttacksFromMe];
	if(item == nil) {
		NSLog(@"Can't find attack item");
		return;
	}
	
	[self createAttackViewController:item];
}


-(History *) findAttackDataToUse:(int)row loadAttacksFromMe:(BOOL)loadAttacksFromMe {
	NSMutableArray *arrToUse;
	AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
	if(self.loadAttacksFromMe == NO) {
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


-(void)createAttackViewController:(History *)item {
	SingleAttackViewController *detailViewController = [[SingleAttackViewController alloc] init];
	[detailViewController addAttackData:item];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];	
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

