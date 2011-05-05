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

@synthesize image, inputMessage, attackSMSBtn, attackEmailBtn, attackHistory, formRequest, emailAttack;

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
	
	// Init the spinner
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[spinner setCenter:CGPointMake(self.view.frame.size.width/2.0, (self.view.frame.size.height-150)/2.0)]; 
	
	self.image.image = [UIImage imageNamed:@"mel-gibson-braveheart.jpg"];
	
	if([self.attackHistory.contactEmail length] == 0 || ![MFMailComposeViewController canSendMail]) {
		// Disable the email button if there is no email address, or if the device can't send email
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
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't contact user" message:@"Sorry, either this user has no email address, this device can't send email, or we can't send an SMS messages due to device limitations. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
	self.emailAttack = YES;
	[self callAppDelegateToAttack];
}


// respond to the attack via sms button click
-(void)attackSMSBtnClick:(UIView*)clickedButton {
	self.emailAttack = NO;
	[self callAppDelegateToAttack];
}

-(void)callAppDelegateToAttack {
	// Save the message
	self.attackHistory.message = inputMessage.text;
	
	// Start the spinner
	[self.view addSubview:spinner];
	[spinner startAnimating];
	
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	// Send the data to the backend
	//NSURL *url = [NSURL URLWithString:@"http://hollow-river-123.heroku.com/user_attacks/createFromPhone"];
	NSURL *url = [NSURL URLWithString:@"http://localhost:3000/user_attacks/createFromPhone"];
	self.formRequest = [ASIFormDataRequest requestWithURL:url];
	[self.formRequest setPostValue:appDelegate.userEmail forKey:@"user_attack[attacker_email]"];
	[self.formRequest setPostValue:self.attackHistory.contactEmail forKey:@"user_attack[victim_email]"];
	[self.formRequest setPostValue:self.attackHistory.contactName forKey:@"user_attack[victim_name]"];
	[self.formRequest setPostValue:self.attackHistory.attack forKey:@"user_attack[attack_name]"];
	[self.formRequest setPostValue:self.attackHistory.message forKey:@"user_attack[message]"];
	[self.formRequest setDelegate:self];
	[self.formRequest startAsynchronous];
}

// Callback from the server request asking for new attacks
-(void)requestFinished:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[spinner stopAnimating];
	[spinner removeFromSuperview];
	
	// Grab the URL returned in the response string
	NSString *responseString = [requestCallback responseString];
	NSLog(@"Response ID: %@", responseString);
	
	PandaAttackAppDelegate *appDelegate = (PandaAttackAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addAttack:self.attackHistory sendToServer:YES emailAttack:self.emailAttack attackID:responseString];
	
	// Pop the stack
	[self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)requestFailed:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[spinner stopAnimating];
	[spinner removeFromSuperview];
	
	NSError *error = [requestCallback error];
	NSLog(@"Error request: %@", [error localizedDescription]);
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

-(void)viewWillDisappear:(BOOL)animated { 
	[self.formRequest clearDelegatesAndCancel];
}

- (void)dealloc {
	[self.attackHistory release];
	
	// Cleaning up
	[self.formRequest clearDelegatesAndCancel];
	[self.formRequest release];
	
    [super dealloc];
}


@end
