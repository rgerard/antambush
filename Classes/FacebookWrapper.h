//
//  FacebookWrapper.h
//  PandaAttack
//
//  Created by Ryan Gerard on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface FacebookWrapper : NSObject<FBSessionDelegate,FBRequestDelegate> {
	Facebook *facebook;
	bool isLoggedInToFB;
	NSArray *friends;
	
	id delegate;
	SEL callback;	
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic) bool isLoggedInToFB;
@property (nonatomic, retain) NSArray *friends;
@property (nonatomic, retain) id delegate;
@property (nonatomic) SEL callback;

-(void) facebookLogin:(SEL)appSelector delegate:(id)requestDelegate;
-(void) facebookLogout:(SEL)appSelector delegate:(id)requestDelegate;
-(void) getMeInfo:(SEL)appSelector delegate:(id)requestDelegate;
-(void) getFriendInfo:(SEL)appSelector delegate:(id)requestDelegate;
-(void) recordFBUserInfo:(NSDictionary*)info;
-(void) setDelegateCallback:(SEL)appSelector delegate:(id)requestDelegate;
-(BOOL) handleOpenURL:(NSURL *)url;

@end
