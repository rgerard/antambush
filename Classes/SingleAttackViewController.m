//
//  SingleAttackViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingleAttackViewController.h"
#import "AntAmbushAppDelegate.h"
#import "WeaponScrollerViewController.h"

static NSString *ImageKey = @"imageKey";

@implementation SingleAttackViewController

@synthesize attackerLabel, attackImage, messageLabel, attackBackBtn, attackData;

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
	
	self.attackerLabel.text = self.attackData.contactName;
	self.messageLabel.text = [NSString stringWithFormat:@"\"%@\"", self.attackData.message];
	
	// Get the image to load from a plist file inside our app bundle
	AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSDictionary *numberItem = [appDelegate findAttackInPList:self.attackData.attack];
	
	if(numberItem != nil) {
		self.attackImage.image = [UIImage imageNamed:[numberItem valueForKey:ImageKey]];
	}
	
	// Init the event handlers
	[attackBackBtn addTarget:self action:@selector(attackBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}


// respond to the Attack button click
-(void)attackBackBtnClick:(UIView*)clickedButton {
	
	// Set data on the History object
	NSLog(@"Person picked is %@, with ID %@", attackData.contactName, attackData.contactFbID);
	
	// Load up the weapon view controller
	WeaponScrollerViewController *weaponViewController = [[WeaponScrollerViewController alloc] init];
	weaponViewController.title = @"Weapon";
	weaponViewController.attackHistory = attackData;
	[self.navigationController pushViewController:weaponViewController animated:YES];
	[weaponViewController release];	
}


-(void) addAttackData:(History *)item {
	self.attackData = [item retain];
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
	[attackerLabel release];
	[attackImage release];
	[messageLabel release];
	[attackBackBtn release];
	[attackData release];
	
    [super dealloc];
}


@end
