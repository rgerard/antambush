//
//  SigninViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SigninViewController.h"
#import "AntAmbushAppDelegate.h"

@implementation SigninViewController

@synthesize facebookBtn, fbWrapper;

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

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
-(id)initWithWrapper:(FacebookWrapper *)wrapper {
	self = [super init];
	if (self) {
		// Custom initialization.
		fbWrapper = [wrapper retain];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Init the event handlers
	[facebookBtn addTarget:self action:@selector(facebookBtnClick:) forControlEvents:UIControlEventTouchUpInside];	
}


-(void) setFbWrapper:(FacebookWrapper*)wrapper {
	fbWrapper = [wrapper retain];
}


// respond to the start button click
-(void)facebookBtnClick:(UIView*)clickedButton {
	NSLog(@"Asking FB for permission");
	
	// Ask for permission to send the person email as well
	[fbWrapper facebookLogin:@selector(facebookLoginCallback) delegate:self];
}

// Verify that you're logged in, and then ask for the 'me' info
-(void) facebookLoginCallback {
	// Close this view
	NSLog(@"Closing the signin view");
	AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate switchFromLoginView];
}


-(IBAction) backgroundTap:(id) sender{
	//[self.inputEmail resignFirstResponder];
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
	[fbWrapper release];
    [super dealloc];
}


@end
