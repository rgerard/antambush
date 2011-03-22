//
//  Attack.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Attack.h"

static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *insertAttack = nil;

@implementation Attack

@synthesize primaryKey, serverID, sender, attack, message, timeCreated;

-(id)initWithServerID:(NSInteger)servID database:(sqlite3*)db {
	
	if(self = [super init]) {
		serverID = servID;
		database = db;
		
		// Create the select statement
		if(init_statement == nil) {
			const char *sql = "SELECT id,sender,attack,message,time FROM attacks WHERE serverID=?";
			if(sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Failed to prepare statement: ", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(init_statement, 1, primaryKey);
		if(sqlite3_step(init_statement) == SQLITE_ROW) {
			primaryKey = (NSInteger)sqlite3_column_text(init_statement, 0);
			sender = [NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement, 1)];
			attack = [NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement, 2)];
			message = [NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement, 3)];
			timeCreated = [NSDate dateWithTimeIntervalSince1970:(int)sqlite3_column_text(init_statement, 4)];
		} else {
			primaryKey = 0;
			sender = @"Unknown";
			attack = @"Unknown";
			message = @"Unknown";
			timeCreated = [NSDate dateWithTimeIntervalSince1970:0];
		}
		
		sqlite3_reset(init_statement);
	}
	
	return self;
}

-(NSInteger)insertNewAttack:(sqlite3*)db {
	
	// Create the attack statement
	if(insertAttack == nil) {
		const char *sql = "INSERT INTO attacks(serverID,sender,attack,message,time) VALUES(?,?,?,?,?)";
		if(sqlite3_prepare_v2(db, sql, -1, &insertAttack, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error create sql for insert attack: %s", sqlite3_errmsg(db));
		}
	}
	
	// Bind the params
	sqlite3_bind_int(insertAttack, 1, serverID);
	sqlite3_bind_text(insertAttack, 2, [sender UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertAttack, 3, [attack UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertAttack, 4, [message UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertAttack, 5, [[NSDate date] timeIntervalSince1970]);
	
	int success = sqlite3_step(insertAttack);
	if(success != SQLITE_ERROR) {
		return sqlite3_last_insert_rowid(db);
	}
	
	NSAssert1(0, @"Error inserting new attack: %s", sqlite3_errmsg(db));
	return -1;
}


@end
