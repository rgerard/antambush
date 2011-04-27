//
//  SingleAttackViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SingleAttackViewController.h"
#import "PandaAttackAppDelegate.h"

static NSString *ImageKey = @"imageKey";
static NSString *NameKey = @"nameKey";

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
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSDictionary *numberItem = [appDelegate findAttackInPList:self.attackData.attack];
	
	if(numberItem != nil) {
		self.attackImage.image = [UIImage imageNamed:[numberItem valueForKey:ImageKey]];
	}
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
