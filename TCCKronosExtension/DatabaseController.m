
//  DatabaseController.m
//  tcc-kronos




#import "DatabaseController.h"
#import "Constants.h"
#import "TCCLog.h"

#import "FMDB.h"

@implementation DatabaseController {
    FMDatabase* _db;
}

- (instancetype)init
{
    return [self initWithDatabase:DATABASE_NAME inDirectory:DATABASE_PATH];
}

- (instancetype)initWithDatabase:(NSString*)databaseName inDirectory:(NSString*)databaseDir {
    self = [super init];
    if (self) {
        if (![self initialiseDatabase:databaseName inDirectory:databaseDir]) {
            return nil;
        }
        
        if (![self initialiseTables]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)initialiseDatabase:(NSString*)databaseName inDirectory:(NSString*)databaseDir
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error;
    
    if (![fm fileExistsAtPath:databaseDir]) {
        [fm createDirectoryAtPath:databaseDir withIntermediateDirectories:YES attributes:0 error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
            return NO;
        }
    }
    
    NSString* fullyQualifiedPath = [databaseDir stringByAppendingPathComponent:databaseName];
    
    _db = [FMDatabase databaseWithPath:fullyQualifiedPath];
    
    if (![_db open]) {
        NSLog(@"Failed to open database at: %@", fullyQualifiedPath);
        _db = nil;
        return NO;
    }
    
    return YES;
}

- (BOOL)initialiseTables
{
    if (![_db tableExists:@"usage"]) {
        [_db executeUpdate: @"CREATE TABLE usage (msgID TEXT, timestamp INTEGER, service TEXT, responsibleIdentifier TEXT, responsiblePid INTEGER, responsiblePath TEXT, accessingIdentifier TEXT, accessingPid INTEGER, accessingPath TEXT, requestingIdentifier TEXT, requestingPid INTEGER, requestingPath TEXT, authValue INTEGER, authReason INTEGER, prompted BOOLEAN, didRequest BOOLEAN, didCtx BOOLEAN, didAttribution BOOLEAN, didResult BOOLEAN, PRIMARY KEY (msgID, timestamp));"];
    }
    
    if (![_db tableExists:@"conditions"]) {
        [_db executeUpdate:@"CREATE TABLE conditions (uuid TEXT PRIMARY KEY, appIdentifier TEXT, service TEXT, conditionType TEXT, conditionValue TEXT, conditionIdentifier TEXT);"];
    }
    
    return YES;
}

- (void)close
{
    [_db close];
}

- (BOOL)writeTCCLogToDatabase:(TCCLog*)log
{
    NSError* error;
    
    if ([[log type] isEqualToString:@"REQUEST"]) {
        [_db executeUpdate:@"INSERT INTO usage (msgID, prompted, timestamp, didRequest, didCtx, didAttribution, didResult) VALUES (?, False, ?, True, False, False, False)" values:@[log.msgID, @([log.timestamp timeIntervalSince1970])] error:&error];
        
    } else if ([[log type] isEqualToString:@"AUTHREQ_CTX"]) {
        [_db executeUpdate:@"UPDATE usage SET service=?, didCtx=True WHERE msgID=? ORDER BY timestamp DESC LIMIT 1" values:@[log.data[@"service"], log.msgID] error:&error];
        
    } else if ([[log type] isEqualToString:@"AUTHREQ_ATTRIBUTION"]) {
        NSMutableArray* values = [NSMutableArray array];
        
        [values addObjectsFromArray:@[
            log.data[@"responsible"][@"identifier"],
            log.data[@"responsible"][@"pid"],
            log.data[@"responsible"][@"binary_path"],
            log.data[@"accessing"][@"identifier"],
            log.data[@"accessing"][@"pid"],
            log.data[@"accessing"][@"binary_path"],
            log.data[@"requesting"][@"identifier"],
            log.data[@"requesting"][@"pid"],
            log.data[@"requesting"][@"binary_path"],
            log.msgID
        ]];
        
        [_db executeUpdate:@"UPDATE usage SET responsibleIdentifier=?, responsiblePid=?, responsiblePath=?, accessingIdentifier=?, accessingPid=?, accessingPath=?, requestingIdentifier=?, requestingPid=?, requestingPath=?, didAttribution=True WHERE msgID=? ORDER BY timestamp DESC LIMIT 1"
        values:values error:&error];
        
    } else if ([[log type] isEqualToString:@"AUTHREQ_RESULT"]) {
        [_db executeUpdate:@"UPDATE usage SET authValue=?, authReason=?, didResult=True WHERE msgID=? ORDER BY timestamp DESC LIMIT 1" values:@[log.data[@"authValue"], log.data[@"authReason"], log.msgID] error:&error];
    } else if ([[log type] isEqualToString:@"AUTHREQ_PROMPTING"]) {
        [_db executeUpdate:@"UPDATE usage SET prompted=True WHERE msgID=? ORDER BY timestamp DESC LIMIT 1" values:@[log.msgID] error:&error];
    }
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

- (NSArray<NSDictionary*>*)getConditions {
    NSMutableArray* output = [NSMutableArray array];
    
    FMResultSet* results = [_db executeQuery:@"SELECT * FROM conditions"];
    
    while ([results next]) {
        [output addObject:[results resultDictionary]];
    }
    
    return output;
}

- (NSDictionary*)getConditionsForService:(NSString*)service forApp:(NSString*)appIdentifier {
    NSDictionary* output;
    
    FMResultSet* results = [_db executeQuery:@"SELECT * FROM conditions WHERE service = ? AND appIdentifier = ?", service, appIdentifier];
    
    if ([results next]) {
        output = [results resultDictionary];
    }
    
    [results close];
    
    return output;
}

- (BOOL)addCondition:(NSString*)condition withValue:(NSString*)value withIdentifier:(NSString*)identifier forService:(NSString*)service forApp:(NSString*)app {
    
    BOOL result = [_db executeUpdate:@"INSERT INTO conditions (uuid, appIdentifier, service, conditionType, conditionValue, conditionIdentifier) VALUES (?, ?, ?, ?, ?, ?)",
     [[NSUUID UUID] UUIDString],
     app,
     service,
     condition,
     value,
     identifier];
    
    if (!result) {
        NSLog(@"Error: Inserting condition for %@ %@ into db", service, app);
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteCondition:(NSDictionary*)condition {
    return [_db executeUpdate:@"DELETE FROM conditions WHERE uuid = ?", condition[@"uuid"]];
}

- (NSArray<NSDictionary*>*)getUsageForApp:(NSString*)appIdentifier {
    NSMutableArray* output = [NSMutableArray array];
    
    FMResultSet* results = [_db executeQuery:@"SELECT * FROM usage WHERE responsibleIdentifier=? OR accessingIdentifier=?", appIdentifier, appIdentifier];
    while ([results next]) {
        [output addObject:[results resultDictionary]];
    }
    
    return output;
}

- (NSDictionary*)getUsageByMsgID:(NSString*)msgID {
    NSDictionary* output;
    
    FMResultSet* results = [_db executeQuery:@"SELECT * FROM usage WHERE msgID = ? ORDER BY timestamp DESC LIMIT 1", msgID];
    
    if ([results next]) {
        output = [results resultDictionary];
    }
    
    [results close];
    
    return output;
}



@end
