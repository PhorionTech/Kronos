
//  ConnectionVerifier.m
//  TCCKronosExtension




#import "ConnectionVerifier.h"

#import "Constants.h"

#define CS_VALID 0x00000001
#define CS_RUNTIME 0x00010000

@interface NSXPCConnection(PrivateAuditToken)

@property (nonatomic, readonly) audit_token_t auditToken;

@end

@implementation ConnectionVerifier

+ (BOOL)isValid:(NSXPCConnection*)connection {
      
      //status
      OSStatus status = !errSecSuccess;
      
      //audit token
      audit_token_t auditToken = {0};
      
      //task ref
      SecTaskRef taskRef = 0;
      
      //code ref
      SecCodeRef codeRef = NULL;
      
      //code signing info
      CFDictionaryRef csInfo = NULL;
      
      //cs flags
      uint32_t csFlags = 0;
      
      //signing req string (main app)
      NSString* requirement = nil;

      //extract audit token
      auditToken = connection.auditToken;
      
      //obtain dynamic code ref
      status = SecCodeCopyGuestWithAttributes(NULL, (__bridge CFDictionaryRef _Nullable)(@{(__bridge NSString *)kSecGuestAttributeAudit : [NSData dataWithBytes:&auditToken length:sizeof(audit_token_t)]}), kSecCSDefaultFlags, &codeRef);
    
      if(errSecSuccess != status)
      {
          //bail
          return NO;
      }
      
      //validate code
      status = SecCodeCheckValidity(codeRef, kSecCSDefaultFlags, NULL);
      if(errSecSuccess != status)
      {
          //bail
          return NO;
      }
      
      //get code signing info
      status = SecCodeCopySigningInformation(codeRef, kSecCSDynamicInformation, &csInfo);
      if(errSecSuccess != status)
      {
          //bail
          return NO;
      }
    
      //extract flags
      csFlags = [((__bridge NSDictionary *)csInfo)[(__bridge NSString *)kSecCodeInfoStatus] unsignedIntValue];
      
    
      
      //gotta have hardened runtime
      if( !(CS_VALID & csFlags) &&
          !(CS_RUNTIME & csFlags) )
      {
          
          //bail
          return NO;
      }
      
      
      //init signing req
      requirement = [NSString stringWithFormat:@"anchor apple generic and identifier \"%@\" and certificate leaf [subject.OU] = \"%@\"", APP_BUNDLE_ID, TEAM_ID];
      
      //step 1: create task ref
      // uses NSXPCConnection's (private) 'auditToken' iVar
      taskRef = SecTaskCreateWithAuditToken(NULL, connection.auditToken);
      if(NULL == taskRef)
      {
          //bail
          return NO;
      }
          
      //step 2: validate
      // check that client is signed with Objective-See's and it's LuLu
      if(errSecSuccess != (status = SecTaskValidateForRequirement(taskRef, (__bridge CFStringRef)(requirement))))
      {
          //bail
          return NO;
      }
      
    return YES;
}

@end
