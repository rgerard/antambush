//
//  Attack.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Attack : NSObject {
	sqlite3 *database;
	NSInteger serverID;
	NSInteger primaryKey;
	NSString *sender;
	NSString *attack;
	NSString *message;
	NSDate *timeCreated;
}

@property (assign, nonatomic, readonly) NSInteger serverID;
@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *attack;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSDate *timeCreated;

-(id)initWithServerID:(NSInteger)servID database:(sqlite3*)db;
-(NSInteger)insertNewAttack:(sqlite3*)db;

@end
