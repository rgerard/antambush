//
//  History.m
//  PandaAttack
//
//  Created by Ryan Gerard on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "History.h"

static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *checkserver_statement = nil;
static sqlite3_stmt *insertAttack = nil;
static sqlite3_stmt *delete_statement = nil;

@implementation History

@synthesize primaryKey, serverID, contactFbID, contactName, attack, message, timeCreated;

-(id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3*)db {
	
	if(self = [super init]) {
		primaryKey = pk;
		database = db;
		
		// Create the select statement
		if(init_statement == nil) {
			const char *sql = "SELECT serverID,sender,senderName,attack,message,time FROM attacks WHERE id=?";
			if(sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Failed to prepare statement: ", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(init_statement, 1, primaryKey);
		if(sqlite3_step(init_statement) == SQLITE_ROW) {
			self.serverID = sqlite3_column_int(init_statement, 0);
			
			// Protect against crashes from possible null pointers returned from sqlite
			char* tmpContactFbID = (char*)sqlite3_column_text(init_statement, 1);
			char* tmpContactName = (char*)sqlite3_column_text(init_statement, 2);
			char* tmpAttack = (char*)sqlite3_column_text(init_statement, 3);
			char* tmpMessage = (char*)sqlite3_column_text(init_statement, 4);
			
			if(tmpContactFbID != NULL) {
				self.contactFbID = [NSString stringWithUTF8String:tmpContactFbID];
			} else {
				self.contactFbID = @"";
			}
			
			if(tmpContactName != NULL) {
				self.contactName = [NSString stringWithUTF8String:tmpContactName];
			} else {
				self.contactName = @"Unknown";
			}
			
			if(tmpAttack != NULL) {
				self.attack = [NSString stringWithUTF8String:tmpAttack];
			} else {
				self.attack = @"Unknown";
			}
			
			if(tmpMessage != NULL) {
				self.message = [NSString stringWithUTF8String:tmpMessage];
			} else {
				self.message = @"";
			}
			
			self.timeCreated = [NSDate dateWithTimeIntervalSince1970:(int)sqlite3_column_text(init_statement, 5)];
		} else {
			self.serverID = 0;
			self.contactFbID = @"";
			self.contactName = @"Unknown";
			self.attack = @"Unknown";
			self.message = @"";
			self.timeCreated = [NSDate dateWithTimeIntervalSince1970:0];
		}
		
		sqlite3_reset(init_statement);
	}
	
	return self;
}

-(NSInteger)insertNewAttack:(sqlite3*)db {
	
	// Check if this serverID is greater than 0, and has already been inserted to the DB
	if(self.serverID > 0) {
		if(checkserver_statement == nil) {
			const char *sql = "SELECT id FROM attacks WHERE serverID=?";
			if(sqlite3_prepare_v2(db, sql, -1, &checkserver_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"Failed to prepare statement: ", sqlite3_errmsg(database));
			}
		}

		sqlite3_bind_int(checkserver_statement, 1, serverID);
		if(sqlite3_step(checkserver_statement) == SQLITE_ROW) {
			NSLog(@"This serverID has already been inserted to the DB.  Not inserting again.");
			return -1;
		}
	
		sqlite3_reset(checkserver_statement);
	}
	
	// Create the attack statement
	if(insertAttack == nil) {
		const char *sql = "INSERT INTO attacks(serverID,sender,senderName,attack,message,time) VALUES(?,?,?,?,?,?)";
		if(sqlite3_prepare_v2(db, sql, -1, &insertAttack, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error create sql for insert attack: %s", sqlite3_errmsg(db));
		}
	}
	
	// Bind the params
	sqlite3_bind_int(insertAttack, 1, serverID);
	sqlite3_bind_text(insertAttack, 2, [contactFbID UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertAttack, 3, [contactName UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertAttack, 4, [attack UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(insertAttack, 5, [message UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insertAttack, 6, [[NSDate date] timeIntervalSince1970]);
	
	int success = sqlite3_step(insertAttack);
	if(success != SQLITE_ERROR) {
		sqlite3_reset(insertAttack);
		sqlite3_clear_bindings(insertAttack);
		return sqlite3_last_insert_rowid(db);
	}
	
	sqlite3_reset(insertAttack);
	sqlite3_clear_bindings(insertAttack);
	NSAssert1(0, @"Error inserting new attack: %s", sqlite3_errmsg(db));
	return -1;
}

+(void)clearData:(sqlite3*)db {
	if(delete_statement == nil) {
		const char *sql = "DELETE FROM attacks";
		if(sqlite3_prepare_v2(db, sql, -1, &delete_statement, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(db));
	}
	
	if (SQLITE_DONE != sqlite3_step(delete_statement)) {
		NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(db));
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Cleared" message:@"All data cleared! Please restart the app to see the changes." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	sqlite3_reset(delete_statement);
}

- (void)dealloc {
	[contactFbID release];
	[contactName release];
	[attack release];
	[message release];
	[timeCreated release];
    [super dealloc];
}

@end
