//
//  FacebookWrapper.m
//  PandaAttack
//
//  Created by Ryan Gerard on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookWrapper.h"
#import "FacebookUser.h"
#import "MixpanelAPI.h"

static NSString* kAppId = @"206499529382979";

@implementation FacebookWrapper

@synthesize facebook, isLoggedInToFB, friends, fbPermissions;
@synthesize delegate, callback, friendData, friendDataSortedKeys;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
-(id)init {
	self = [super init];
	if (self) {
		// Custom initialization.
		facebook = [[Facebook alloc] initWithAppId:kAppId];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		self.isLoggedInToFB = [prefs boolForKey:@"fbLoggedIn"];
		
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"fbAccessToken"];
		NSDate *exp = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:@"fbExpiration"];
        
        if (token != nil && exp != nil && [token length] > 2) {
			facebook.accessToken = token;
            facebook.expirationDate = exp;
		} 
		
		// If the facebook session isn't valid anymore, force the user to authorize again
		if ([facebook isSessionValid] == NO) {
			self.isLoggedInToFB = NO;
		}
		
		// Ask for permission to send the person email as well
		self.fbPermissions =  [[NSArray arrayWithObjects:@"email,publish_stream,offline_access", nil] retain];

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
	[facebook authorize:fbPermissions delegate:self];		
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
	
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:@"FacebookLoginSuccess"];
    
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
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:@"FacebookLoginFailure"];
	
	// Call the callback, let it know that the request is done
	if([self.delegate respondsToSelector:self.callback]) {
		[self.delegate performSelector:self.callback];
	}
}


-(void) fbDidLogout {
	NSLog(@"Logged out of Facebook");
	self.isLoggedInToFB = NO;
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:@"FacebookLogoutSuccess"];
    
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:NO forKey:@"fbLoggedIn"];
    [prefs setObject:@"" forKey:@"fbAccessToken"];
	[prefs setObject:nil forKey:@"fbExpiration"];
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
	
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    [mixpanel track:@"FacebookRequestFailure"];
    
	// Call the callback, let it know that the request is done
	if([self.delegate respondsToSelector:self.callback]) {
		[self.delegate performSelector:self.callback];
	}
};


-(BOOL) handleOpenURL:(NSURL *)url {
	NSLog(@"FB opening URL!");
    return [facebook handleOpenURL:url];
}


-(void) facebookPublishNote:(NSString *)victim message:(NSString *)message url:(NSString *)url attack:(NSString *)attack attackImage:(NSString *)attackImage {
	
    // Get ME info
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *fbid = [prefs stringForKey:@"fbID"];
    NSString *image = [NSString stringWithFormat:@"http://www.antambush.com/images/%@", attackImage];

    if(fbid != nil && fbid.length > 0) {
        NSMutableDictionary* attachment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                kAppId, @"app_id",
                                fbid, @"from",
								victim, @"to",
								@"Attacked!", @"name",
								[NSString stringWithFormat:@"You just got ambushed by %@", attack], @"caption",
								@"You know what it is", @"description",
								message,  @"message",
                                image, @"picture",
								url, @"link", nil];
	
        [facebook dialog:@"stream.publish" andParams:attachment andDelegate:self];
    }
}


////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
	NSLog(@"Publish success");
}

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url {
	NSLog(@"Publish dialogCompleteWithUrl %@", url);
    NSString* urlStr = [url absoluteString];
    
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
    if([urlStr rangeOfString:@"post_id"].location == NSNotFound) {
        [mixpanel trackFunnel:@"Attack Friend" step:6 goal:@"Posted to Facebook" properties:[NSDictionary dictionaryWithObject:@"false" forKey:@"didPost"]];
        [mixpanel track:@"FacebookPostSkip"];
    } else {
        [mixpanel trackFunnel:@"Attack Friend" step:6 goal:@"Posted to Facebook" properties:[NSDictionary dictionaryWithObject:@"true" forKey:@"didPost"]];
        [mixpanel track:@"FacebookPostSuccess"];
    }
}

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
	NSLog(@"Publish dialogDidNotCompleteWithUrl");
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog {
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel trackFunnel:@"Attack Friend" step:6 goal:@"Posted to Facebook" properties:[NSDictionary dictionaryWithObject:@"false" forKey:@"didPost"]];
    [mixpanel track:@"FacebookPostCancelled"];
    
	NSLog(@"Publish dialogDidNotComplete");
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    MixpanelAPI *mixpanel = [MixpanelAPI sharedAPI];
	[mixpanel trackFunnel:@"Attack Friend" step:6 goal:@"Posted to Facebook" properties:[NSDictionary dictionaryWithObject:@"false" forKey:@"didPost"]];
    [mixpanel track:@"FacebookPostFailed"];
    
	NSLog(@"Publish didFailWithError: %@", error);
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
			[nameArr release];
		}
		
		// Create a FB User object
		FacebookUser *user = [[FacebookUser alloc] init];
		user.fbName = name;
		user.fbID = fbID;
						  
		// Take out the array, add the user object, and put the array back into the dictionary
		NSMutableArray *nameArr = [self.friendData objectForKey:firstLetter];
		[nameArr addObject:user];
		[self.friendData setObject:nameArr forKey:firstLetter];
		[user release];
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
		[nameArr sortUsingDescriptors:sortDescriptors];

		// Add each name back to the array
		for(int j=0; j < [nameArr count]; j++) {
			[self.friends addObject:[nameArr objectAtIndex:j]];
		}
		
		[self.friendData setObject:nameArr forKey:key];
	}
}


-(void)dealloc {
	[fbPermissions release];
	[facebook release];
    [super dealloc];
}

@end
