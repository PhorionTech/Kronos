
//  TCCHelper.m
//  TCCKronosExtension




#import "TCCHelper.h"

#import "Utils.h"

#import "FMDB.h"

@implementation TCCHelper {
    FMDatabase* _db;
    NSString* _user;
}

+ (id)shared
{
    static TCCHelper* helper = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] initWithUser:getConsoleUser()];
    });

    return helper;
}

- (instancetype)initWithUser:(NSString*)user
{
    self = [super init];
    if (self) {
        _user = user;
        
        // Create in memory database for this
        _db = [FMDatabase databaseWithPath:nil];
        if (![_db open]) {
            NSLog(@"Error: couldn't create in-memory db.");
            return nil;
        }
        
        // Create tables everytime, since it's in memory and not persistent
        [_db executeUpdate: @"CREATE TABLE access (    source TEXT NOT NULL, service        TEXT        NOT NULL,     client         TEXT        NOT NULL,     client_type    INTEGER     NOT NULL,     auth_value     INTEGER     NOT NULL,     auth_reason    INTEGER     NOT NULL,     auth_version   INTEGER     NOT NULL,     csreq          BLOB,     policy_id      INTEGER,     indirect_object_identifier_type    INTEGER,     indirect_object_identifier         TEXT NOT NULL DEFAULT 'UNUSED',     indirect_object_code_identity      BLOB,     flags          INTEGER,     last_modified  INTEGER     NOT NULL DEFAULT (CAST(strftime('%s','now') AS INTEGER)),     PRIMARY KEY (source, service, client, client_type, indirect_object_identifier))"];
        
        // Start with a refresh of both dbs
        [self refresh];

    }
    return self;
}

- (BOOL)refresh {
    BOOL result = YES;
    
    // Start with a refresh of both dbs
    if (![self refreshUserDatabase]) {
        NSLog(@"Error: failed to refresh user database");
        result = NO;
    }
    
    if (![self refreshSystemDatabase]) {
        NSLog(@"Error: failed to refresh system database");
        result = NO;
    }
    
    return result;
}

- (BOOL)refreshUserDatabase {
    [_db executeUpdate:@"DELETE FROM access WHERE source = 'userTCCDatabase'"];
    
    NSString* userTCCDatabasePath = [NSString stringWithFormat:@"/Users/%@/Library/Application Support/com.apple.TCC/TCC.db", _user];
    NSLog(@"Querying TCC database at: %@", userTCCDatabasePath);
    
    FMDatabase* userTCCDatabase = [FMDatabase databaseWithPath:userTCCDatabasePath];
    
    if (![userTCCDatabase open]) {
        NSLog(@"Error: failed to open database at %@", userTCCDatabasePath);
        return NO;
    }
    
    FMResultSet* results = [userTCCDatabase executeQuery:@"SELECT * FROM access"];
        
    while ([results next]) {
        BOOL success = [_db executeUpdate:@"INSERT INTO access (source, service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
         @"userTCCDatabase",
         [results stringForColumn:@"service"],
         [results stringForColumn:@"client"],
         @([results intForColumn:@"client_type"]),
         @([results intForColumn:@"auth_value"]),
         @([results intForColumn:@"auth_reason"]),
         @([results intForColumn:@"auth_version"]),
         [results dataForColumn:@"csreq"],
         @([results intForColumn:@"policy_id"]),
         @([results intForColumn:@"indirect_object_identifier_type"]),
         [results stringForColumn:@"indirect_object_identifier"],
         [results dataForColumn:@"indirect_object_code_identity"],
         @([results intForColumn:@"flags"]),
         @([results intForColumn:@"last_modified"])
        ];
        
        if (!success) {
            NSLog(@"Error: failed to add record to database");
        }
    }
    
    [userTCCDatabase close];
    
    return YES;
}

- (BOOL)refreshSystemDatabase {
    [_db executeUpdate:@"DELETE FROM access WHERE source = 'systemTCCDatabase'"];
    
    NSString* systemTCCDatabasePath = @"/Library/Application Support/com.apple.TCC/TCC.db";
    NSLog(@"Querying TCC database at: %@", systemTCCDatabasePath);
    
    FMDatabase* systemTCCDatabase = [FMDatabase databaseWithPath:systemTCCDatabasePath];
    
    if (![systemTCCDatabase open]) {
        NSLog(@"Error: failed to open database at %@", systemTCCDatabasePath);
        return NO;
    }
    
    FMResultSet* results = [systemTCCDatabase executeQuery:@"SELECT * FROM access"];
        
    while ([results next]) {
        BOOL success = [_db executeUpdate:@"INSERT INTO access (source, service, client, client_type, auth_value, auth_reason, auth_version, csreq, policy_id, indirect_object_identifier_type, indirect_object_identifier, indirect_object_code_identity, flags, last_modified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
         @"systemTCCDatabase",
         [results stringForColumn:@"service"],
         [results stringForColumn:@"client"],
         @([results intForColumn:@"client_type"]),
         @([results intForColumn:@"auth_value"]),
         @([results intForColumn:@"auth_reason"]),
         @([results intForColumn:@"auth_version"]),
         [results dataForColumn:@"csreq"],
         @([results intForColumn:@"policy_id"]),
         @([results intForColumn:@"indirect_object_identifier_type"]),
         [results stringForColumn:@"indirect_object_identifier"],
         [results dataForColumn:@"indirect_object_code_identity"],
         @([results intForColumn:@"flags"]),
         @([results intForColumn:@"last_modified"])
        ];
        
        if (!success) {
            NSLog(@"Error: failed to add record to database");
        }
    }
    
    [systemTCCDatabase close];
    
    return YES;
}

- (NSArray<NSDictionary*>*)selectAll {
    [self refresh];
    
    NSMutableArray* output = [NSMutableArray array];
    
    FMResultSet* results = [_db executeQuery:@"SELECT * FROM access"];
        
    while ([results next]) {
        [output addObject:[results resultDictionary]];
    }
    
    return output;
}

- (NSDictionary*)selectRecordByClient:(NSString*)client service:(NSString*)service {
    [self refresh];
    
    NSDictionary* output;
    
    FMResultSet* results = [_db executeQuery:@"SELECT * FROM access WHERE client = ? AND service = ?", client, service];
    
    if ([results next]) {
        output = [results resultDictionary];
    }
    
    [results close];
    
    return output;
}

- (BOOL)resetDBPermissions:(NSString*)service forClient:(NSString*)client {
    NSString* userTCCDatabasePath = [NSString stringWithFormat:@"/Users/%@/Library/Application Support/com.apple.TCC/TCC.db", _user];
    NSLog(@"Querying TCC database at: %@", userTCCDatabasePath);
    
    FMDatabase* userTCCDatabase = [FMDatabase databaseWithPath:userTCCDatabasePath];
    
    if (![userTCCDatabase open]) {
        NSLog(@"Error: failed to open database at %@", userTCCDatabasePath);
        return NO;
    }
    

    // (1) Unknown - i.e. TCC will prompt the user
    NSString* auth_value = @"1";
    
    // (3) User set - i.e. the user set the permission
    NSString* auth_reason = @"3";
    
    NSArray* arguments = @[
        auth_value,
        auth_reason,
        service,
        client
    ];
    
    NSError* error;
    
    // auth_value=1 (unknown), auth_reason=3 (user set)
    [userTCCDatabase executeUpdate:@"UPDATE access SET auth_value=?, auth_reason=? WHERE service=? AND client=?;"
                values:arguments error:&error];

    NSLog(@"Query successfully executed");
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

@end
