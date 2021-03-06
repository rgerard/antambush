//
//  SendMessageViewController.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SendMessageViewController.h"
#import "AntAmbushAppDelegate.h"
#import "MixpanelAPI.h"

static NSString *rootUrl = @"http://www.antambush.com";
//static NSString *rootUrl = @"http://localhost:3000";

@implementation SendMessageViewController

@synthesize image, inputMessage, attackBtn, attackHistory, formRequest, spinner;

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
	[self.attackBtn addTarget:self action:@selector(attackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)setSpinningMode:(BOOL)isWaiting detailTxt:(NSString *)detailTxt {
	//when network action, toggle network indicator and activity indicator
	if (isWaiting) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        self.spinner = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.spinner];
		self.spinner.labelText = @"Loading";
		self.spinner.detailsLabelText = detailTxt;
		[self.spinner show:YES];
	} else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.spinner removeFromSuperview];
        [self.spinner release];
        self.spinner = nil;
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
-(void)attackBtnClick:(UIView*)clickedButton {
    NSString *hasMessage = @"true";
    if(inputMessage.text.length == 0) {
        hasMessage = @"false";
    }
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel trackFunnel:@"Attack Friend" step:5 goal:@"Attack Sent" properties:[NSDictionary dictionaryWithObject:hasMessage forKey:@"hasMessage"]];
    [mixpanel track:@"FriendAttacked" properties:[NSDictionary dictionaryWithObject:hasMessage forKey:@"hasMessage"]];
    
	[self.inputMessage resignFirstResponder];
	[self callAppDelegateToAttack];
}


-(void)callAppDelegateToAttack {
	// Save the message
	self.attackHistory.message = inputMessage.text;
	
    // Make sure to cancel any current running requests
	[self.formRequest clearDelegatesAndCancel];
    
	// Start the spinner
	[self setSpinningMode:YES detailTxt:@"Sending Attack"];

	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *deviceToken = [prefs stringForKey:@"deviceToken"];
	NSString *userFbID = [prefs stringForKey:@"fbID"];
	
	int attackCount = 1;
	
	if([prefs integerForKey:@"attackCount"]) {
		attackCount = [prefs integerForKey:@"attackCount"];
		attackCount++;
	}
	
	[prefs setInteger:attackCount forKey:@"attackCount"];
	[prefs synchronize];
	
	// If this is nil or empty string, the backend won't process it
	if(deviceToken == nil || [deviceToken length] == 0) {
		deviceToken = @"-2";
	}
	
	// Send the data to the backend
    NSString *name = [prefs stringForKey:@"fbFullname"];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user_attacks/createFromPhone", rootUrl]];
	self.formRequest = [ASIFormDataRequest requestWithURL:url];
	[self.formRequest setPostValue:userFbID forKey:@"user_attack[attacker_fbid]"];
    [self.formRequest setPostValue:name forKey:@"user_attack[attacker_name]"];
	[self.formRequest setPostValue:self.attackHistory.contactFbID forKey:@"user_attack[victim_fbid]"];
	[self.formRequest setPostValue:self.attackHistory.contactName forKey:@"user_attack[victim_name]"];
	[self.formRequest setPostValue:self.attackHistory.attack forKey:@"user_attack[attack_name]"];
	[self.formRequest setPostValue:self.attackHistory.message forKey:@"user_attack[message]"];
	[self.formRequest setPostValue:deviceToken forKey:@"device_token"];
	[self.formRequest setDelegate:self];
	[self.formRequest startAsynchronous];
}

// Callback from the server request asking for new attacks
-(void)requestFinished:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[self setSpinningMode:NO detailTxt:@""];
	
	// Grab the URL returned in the response string
	NSString *responseString = [requestCallback responseString];
	NSLog(@"Response ID: %@", responseString);
	self.attackHistory.serverID = 0;
	
	AntAmbushAppDelegate *appDelegate = (AntAmbushAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate addAttack:self.attackHistory sendToServer:YES attackID:responseString];
	
	// Pop the stack
	[self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)requestFailed:(ASIHTTPRequest *)requestCallback {
	// Stop the spinner
	[self setSpinningMode:NO detailTxt:@""];
	
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
    
    if(self.spinner != nil) {
        [self.spinner release];
        self.spinner = nil;
    }
    
	// Cleaning up
	[self.formRequest clearDelegatesAndCancel];
	[self.formRequest release];
	
    [super dealloc];
}


@end
