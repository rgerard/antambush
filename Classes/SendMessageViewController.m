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

@synthesize image, inputMessage, attackSMSBtn, attackEmailBtn, attackHistory;

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
	
	self.image.image = [UIImage imageNamed:@"mel-gibson-braveheart.jpg"];
	
	if([self.attackHistory.contactEmail length] == 0) {
		// Disable the email button if there is no email address
		[self.attackEmailBtn setEnabled:NO];
		[self.attackEmailBtn setHidden:YES];
	} else {
		[self.attackEmailBtn addTarget:self action:@selector(attackEmailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
		[self.attackSMSBtn addTarget:self action:@selector(attackSMSBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		// Disable the SMS button if this is a non iPhone 4 user
		[self.attackSMSBtn setEnabled:NO];
		[self.attackSMSBtn setHidden:YES];
	}
	
	// Put up an alert if both email and sms are disabled
	if(self.attackSMSBtn.enabled == NO && self.attackEmailBtn.enabled == NO) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't contact user" message:@"Sorry, this user has no email address, and we can only send SMS messages on the iPhone 4." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


// Responds to people saying they want to invite someone
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];  
	
    if([title isEqualToString:@"Ok"]) {  
		// Pop the stack
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}


// respond to the attack via email button click
-(void)attackEmailBtnClick:(UIView*)clickedButton {
	[self callAppDelegateToAttack:YES];
}


// respond to the attack via sms button click
-(void)attackSMSBtnClick:(UIView*)clickedButton {
	[self callAppDelegateToAttack:NO];
}

-(void)callAppDelegateToAttack:(BOOL)emailAttack {
	// Save the message
	self.attackHistory.message = inputMessage.text;
	
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addAttack:self.attackHistory sendToServer:YES emailAttack:emailAttack];
	
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
	[attackHistory release];	
    [super dealloc];
}


@end
