//
//  SigninViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SigninViewController.h"
#import "PandaAttackAppDelegate.h"

@implementation SigninViewController

@synthesize startBtn, inputEmail;

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
	
	// Init the event handlers
	[startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];	
}


// respond to the start button click
-(void)startBtnClick:(UIView*)clickedButton {
	// Save the users email address
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:inputEmail.text forKey:@"userEmail"];
	[prefs synchronize];
	
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate switchFromLoginView];
}


-(IBAction) backgroundTap:(id) sender{
	[self.inputEmail resignFirstResponder];
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
