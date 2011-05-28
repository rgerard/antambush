//
//  FacebookWrapper.m
//  PandaAttack
//
//  Created by Ryan Gerard on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookWrapper.h"
#import "FacebookUser.h"

static NSString* kAppId = @"206499529382979";

@implementation FacebookWrapper

@synthesize facebook, isLoggedInToFB, friends;
@synthesize delegate, callback, friendData, friendDataSortedKeys;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
-(id)init {
	self = [super init];
	if (self) {
		// Custom initialization.
		facebook = [[Facebook alloc] initWithAppId:kAppId];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		self.isLoggedInToFB = [prefs boolForKey:@"fbLoggedIn"];
		
		facebook.accessToken    = [[NSUserDefaults standardUserDefaults] stringForKey:@"fbAccessToken"];
		facebook.expirationDate = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:@"fbExpiration"];
		
		// If the facebook session isn't valid anymore, force the user to authorize again
		if ([facebook isSessionValid] == NO) {
			self.isLoggedInToFB = NO;
		}

	}
	return self;
}

-(void) setDelegateCallback:(SEL)appSelector delegate:(id)requestDelegate {
	self.delegate = requestDelegate;
	self.callback = appSelector;
}

-(void) facebookLogin:(SEL)appSelector delegate:(id)requestDelegate {
	[self setDelegateCallback:appSelector delegate:requestDelegate];
	
	if(!self.isLoggedInToFB) {
		[self facebookAuthorize:appSelector delegate:requestDelegate];
	} else {
		NSLog(@"Already logged in to Facebook");
		
		// Call the callback, let it know that the request is done
		if([self.delegate respondsToSelector:self.callback]) {
			[self.delegate performSelector:self.callback];
		}
	}
}

-(void) facebookAuthorize:(SEL)appSelector delegate:(id)requestDelegate {
	[self setDelegateCallback:appSelector delegate:requestDelegate];
	
	// Ask for permission to send the person email as well
	NSArray* permissions =  [[NSArray arrayWithObjects:@"email,publish_stream", nil] retain];
	[facebook authorize:permissions delegate:self];		
}

-(void) facebookLogout:(SEL)appSelector delegate:(id)requestDelegate {
	[self setDelegateCallback:appSelector delegate:requestDelegate];
	
	if(self.isLoggedInToFB) {
		// Logout of Facebook
		[facebook logout:self];
	} else {
		NSLog(@"Already logged out of Facebook");
		
		// Call the callback, let it know that the request is done
		if([self.delegate respondsToSelector:self.callback]) {
			[self.delegate performSelector:self.callback];
		}
	}
}

-(void) getMeInfo:(SEL)appSelector delegate:(id)requestDelegate {
	[self setDelegateCallback:appSelector delegate:requestDelegate];
	
	if(self.isLoggedInToFB) {
		// Set the callback
		self.delegate = requestDelegate;
		self.callback = appSelector;
		
		//Get information about the currently logged in user
		NSLog(@"Making request for FB user");
		[facebook requestWithGraphPath:@"me" andDelegate:self];	
	} else {
		NSLog(@"You are not logged into Facebook");
		
		// Call the callback, let it know that the request is done
		if([self.delegate respondsToSelector:self.callback]) {
			[self.delegate performSelector:self.callback];
		}
	}
}

-(void) getFriendInfo:(SEL)appSelector delegate:(id)requestDelegate {
	[self setDelegateCallback:appSelector delegate:requestDelegate];
	
	if(self.isLoggedInToFB) {
		// Set the callback
		self.delegate = requestDelegate;
		self.callback = appSelector;
		
		//Get information about the current users friends
		NSLog(@"Making request for FB friends");
		[facebook requestWithGraphPath:@"me/friends" andDelegate:self];	
	} else {
		NSLog(@"You are not logged into Facebook");
		
		// Call the callback, let it know that the request is done
		if([self.delegate respondsToSelector:self.callback]) {
			[self.delegate performSelector:self.callback];
		}
	}
}

-(void) recordFBUserInfo:(NSDictionary*)info {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSString *fullName = [info objectForKey:@"name"];
	if(fullName != nil) {
		NSLog(@"Found FB fullname: %@", fullName);
		[prefs setObject:fullName forKey:@"fbFullname"];
	}
	
	NSString *firstName = [info objectForKey:@"first_name"];
	if(firstName != nil) {
		NSLog(@"Found FB firstname: %@", firstName);
		[prefs setObject:firstName forKey:@"fbFirstname"];
	}
	
	NSString *fbID = [info objectForKey:@"id"];
	if(fbID != nil) {
		NSLog(@"Found FB ID: %@", fbID);
		[prefs setObject:fbID forKey:@"fbID"];
	}
	
	NSString *userName = [info objectForKey:@"username"];
	if(userName != nil) {
		NSLog(@"Found FB username: %@", userName);
		[prefs setObject:userName forKey:@"fbUsername"];
	}
	
	[prefs synchronize];
}


//
// FBSessionDelegate
//

-(void) fbDidLogin {
	NSLog(@"FB Logged in!");
	self.isLoggedInToFB = YES;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[facebook accessToken] forKey:@"fbAccessToken"];
	[prefs setObject:[facebook expirationDate] forKey:@"fbExpiration"];
	[prefs setBool:YES forKey:@"fbLoggedIn"];
	[prefs synchronize];
	
	// Call the callback, let it know that the request is done
	if([self.delegate respondsToSelector:self.callback]) {
		[self.delegate performSelector:self.callback];
	}
}


-(void) fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"FB did not login!");
	self.isLoggedInToFB = NO;
	
	// Call the callback, let it know that the request is done
	if([self.delegate respondsToSelector:self.callback]) {
		[self.delegate performSelector:self.callback];
	}
}


-(void) fbDidLogout {
	NSLog(@"Logged out of Facebook");
	
	self.isLoggedInToFB = NO;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:NO forKey:@"fbLoggedIn"];
	[prefs synchronize];
	
	// Call the callback, let it know that the request is done
	if([self.delegate respondsToSelector:self.callback]) {
		[self.delegate performSelector:self.callback];
	}
}


//
// FBRequestDelegate
//

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
-(void) request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Received raw response");
}


/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response.
 */
-(void) request:(FBRequest *)request didLoad:(id)result {
	NSLog(@"FB response received");
	
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	
	if([result objectForKey:@"name"]) {
		// Record the me info
		[self recordFBUserInfo:result];
		
	} else if([result objectForKey:@"data"]) {
		// Record the FB friends list
		NSLog(@"Got list of FB friends");
		
		if ([[result objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
			self.friends = [result objectForKey:@"data"];
			[self sortFriends];
		} else {
			NSLog(@"There was a problem getting the friends list");
		}
	}
	
	// Call the callback, let it know that the request is done
	if([self.delegate respondsToSelector:self.callback]) {
		[self.delegate performSelector:self.callback];
	}
};


/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
-(void) request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Error making FB request: %@", error);
	
	// Call the callback, let it know that the request is done
	if([self.delegate respondsToSelector:self.callback]) {
		[self.delegate performSelector:self.callback];
	}
};


-(BOOL) handleOpenURL:(NSURL *)url {
	NSLog(@"FB opening URL!");
    return [facebook handleOpenURL:url];
}


-(void) facebookPublishNote:(NSString *)victim message:(NSString *)message url:(NSString *)url attack:(NSString *)attack {
	NSMutableDictionary* attachment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								victim, @"to",
								@"Attacked!", @"name",
								[NSString stringWithFormat:@"You just got ambushed by %@", attack], @"caption",
								@"You know what it is", @"description",
								message,  @"message",
								url, @"link", nil];
	
	[facebook dialog:@"feed" andParams:attachment andDelegate:self];
}

////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
	NSLog(@"Publish success");
}

// Organize the friend list into a dictionary that maps a letter to an array of FB User object.  For instance, 'A' -> NSArray of FB Users
-(void) sortFriends {
	NSLog(@"Sorting friends");
	self.friendData = [[NSMutableDictionary alloc] init];
	
	for(int i=0; i < [self.friends count]; i++) {
		NSDictionary *dict = [self.friends objectAtIndex:i];
		NSString *name = [dict objectForKey:@"name"];
		NSString *fbID = [dict objectForKey:@"id"];
		unichar letter = [name characterAtIndex:0];
		NSString *firstLetter = [NSString stringWithCharacters:&letter length:1];
		
		// If the dictionary has not seen this letter yet, create a new array for the dictionary to track
		if ([self.friendData objectForKey:firstLetter] == nil) {
			NSMutableArray *nameArr = [[NSMutableArray alloc] init];
			[self.friendData setObject:nameArr forKey:firstLetter];
		}
		
		// Create a FB User object
		FacebookUser *user = [[FacebookUser alloc] init];
		user.fbName = name;
		user.fbID = fbID;
						  
		// Take out the array, add the user object, and put the array back into the dictionary
		NSMutableArray *nameArr = [self.friendData objectForKey:firstLetter];
		[nameArr addObject:user];
		[self.friendData setObject:nameArr forKey:firstLetter];
	}
	
	// Clear out the old friend list
	[self.friends removeAllObjects];
	
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"fbName" ascending:YES] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	
	// Put the friends back in, sorted
	NSArray* keys = [self.friendData allKeys];
	self.friendDataSortedKeys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	for (int i = 0; i < [self.friendDataSortedKeys count]; i++) {
		NSString* key = [self.friendDataSortedKeys objectAtIndex:i];
		NSMutableArray* nameArr = [self.friendData objectForKey:key];
		
		// Sort the array
		nameArr = [nameArr sortedArrayUsingDescriptors:sortDescriptors];

		// Add each name back to the array
		for(int j=0; j < [nameArr count]; j++) {
			[self.friends addObject:[nameArr objectAtIndex:j]];
		}
		
		[self.friendData setObject:nameArr forKey:key];
	}
}


-(void)dealloc {
	[facebook release];
    [super dealloc];
}

@end
