//
//  SendMessageViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SendMessageViewController.h"
#import "PandaAttackAppDelegate.h"

@implementation SendMessageViewController

@synthesize image, inputMessage, attackBtn, attackHistory;

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
	
	image.image = [UIImage imageNamed:@"mel-gibson-braveheart.jpg"];
	
	// Init the event handlers
	[attackBtn addTarget:self action:@selector(attackBtnClick:) forControlEvents:UIControlEventTouchUpInside];	
}


// respond to the ask button click
-(void)attackBtnClick:(UIView*)clickedButton {
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addAttack:attackHistory];
	
	// Pop the stack
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction) backgroundTap:(id) sender{
	[self.inputMessage resignFirstResponder];
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
    [super dealloc];
}


@end
