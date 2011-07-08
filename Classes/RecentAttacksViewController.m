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

@implementation RecentAttacksViewController

@synthesize loadAttacksFromMe;
@synthesize delegate;
@synthesize attackSelector;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Initialization code.
}

-(void) setDelegateCallback:(SEL)appSelector delegate:(id)requestDelegate {
	self.delegate = requestDelegate;
	self.attackSelector = appSelector;
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

	// Call the callback to open the new attack screen
	if([self.delegate respondsToSelector:self.attackSelector]) {
		[self.delegate performSelector:self.attackSelector withObject:indexPath];
	}
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

