//
//  FacebookWrapper.h
//  PandaAttack
//
//  Created by Ryan Gerard on 5/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface FacebookWrapper : NSObject<FBSessionDelegate,FBRequestDelegate,FBDialogDelegate> {
	Facebook *facebook;
	bool isLoggedInToFB;
	NSMutableArray *friends;
	NSMutableDictionary *friendData;
	NSArray *friendDataSortedKeys;
	
	id delegate;
	SEL callback;	
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic) bool isLoggedInToFB;
@property (nonatomic, retain) NSMutableArray *friends;
@property (nonatomic, retain) NSMutableDictionary *friendData;
@property (nonatomic, retain) NSArray *friendDataSortedKeys;
@property (nonatomic, retain) id delegate;
@property (nonatomic) SEL callback;

-(void) facebookLogin:(SEL)appSelector delegate:(id)requestDelegate;
-(void) facebookLogout:(SEL)appSelector delegate:(id)requestDelegate;
-(void) facebookAuthorize:(SEL)appSelector delegate:(id)requestDelegate;
-(void) facebookPublishNote:(NSString *)victim message:(NSString *)message url:(NSString *)url attack:(NSString *)attack;
-(void) getMeInfo:(SEL)appSelector delegate:(id)requestDelegate;
-(void) getFriendInfo:(SEL)appSelector delegate:(id)requestDelegate;
-(void) recordFBUserInfo:(NSDictionary*)info;
-(void) setDelegateCallback:(SEL)appSelector delegate:(id)requestDelegate;
-(BOOL) handleOpenURL:(NSURL *)url;
-(void) sortFriends;

@end
