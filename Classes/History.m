//
//  History.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "History.h"

static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *insertAttack = nil;

@implementation History

@synthesize primaryKey, serverID, contact, attack, message, timeCreated;

-(id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3*)db {
	
	if(self = [super init]) {
		primaryKey = pk;
		database = db;
		
		// Create the select statement
		if(init_statement == nil) {
			const char *sql = "SELECT serverID,sender,attack,message,time FROM attacks WHERE id=?";
			if(sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Failed to prepare statement: ", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(init_statement, 1, primaryKey);
		if(sqlite3_step(init_statement) == SQLITE_ROW) {
			self.serverID = sqlite3_column_int(init_statement, 1);
			self.contact = [NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement, 1)];
			self.attack = [NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement, 2)];
			self.message = [NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement, 3)];
			self.timeCreated = [NSDate dateWithTimeIntervalSince1970:(int)sqlite3_column_text(init_statement, 4)];
		} else {
			self.serverID = -1;
			self.contact = @"Unknown";
			self.attack = @"Unknown";
			self.message = @"Unknown";
			self.timeCreated = [NSDate dateWithTimeIntervalSince1970:0];
		}
		
		sqlite3_reset(init_statement);
	}
	
	return self;
}

-(NSInteger)insertNewAttack:(sqlite3*)db {
	
	// Create the attack statement
	if(insertAttack == nil) {
		const char *sql = "INSERT INTO history(serverID,sender,attack,message,time) VALUES(?,?,?,?,?)";
		if(sqlite3_prepare_v2(db, sql, -1, &insertAttack, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error create sql for insert attack: %s", sqlite3_errmsg(db));
		}
	}
	
	// Bind the params
	sqlite3_bind_int(insertAttack, 1, serverID);
	sqlite3_bind_text(insertAttack, 2, [contact UTF8String], -1, SQLITE_TRANSIENT);
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
