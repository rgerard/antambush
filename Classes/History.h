//
//  History.h
//  PandaAttack
//
//  Created by Ryan Gerard on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface History : NSObject {
	sqlite3 *database;
	NSInteger primaryKey;
	NSString *contact;
	NSString *attack;
	NSString *message;
	NSDate *timeCreated;
}

@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, retain) NSString *contact;
@property (nonatomic, retain) NSString *attack;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSDate *timeCreated;

-(id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3*)db;
-(NSInteger)insertNewAttack:(sqlite3*)db;

@end
