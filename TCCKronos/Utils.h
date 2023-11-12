
//  Utils.h
//  tcc-kronos




#ifndef Utils_h
#define Utils_h

pid_t findProcess(NSString* processName);
NSString* parseStringWithRegex(NSString* regexString, NSString* target);
NSString* convertEuidToUsername(NSNumber* euid);
NSString* convertGuidToUsername(NSNumber* guid);
NSString* formatDateWithNumber(NSNumber* dateNumber);
NSString* formatDateWithDate(NSDate* date);
NSString* getAppVersion(void);
NSString* getAppBinary(NSString* appPath);
NSBundle* findAppBundle(NSString* path);
NSImage* getIconForProcess(NSString* path);
NSImage* getIconForBundle(NSBundle* bundle);
NSString* getConsoleUser(void);
NSString* stringFromAuthReason(int);
NSString* stringFromAuthValue(int);

#endif /* Utils_h */
