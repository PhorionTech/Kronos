
//  Utils.m
//  TCCKronos

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import <Foundation/Foundation.h>
#import <AppKit/Appkit.h>


#import <libproc.h>
#import <sys/sysctl.h>
#import <grp.h>
#import <pwd.h>

@import SystemConfiguration;

// src: https://github.com/objective-see/LuLu/blob/master/LuLu/Shared/utilities.m

// get process's path
NSString* getProcessPath(pid_t pid)
{
    // task path
    NSString* processPath = nil;

    // buffer for process path
    char pathBuffer[PROC_PIDPATHINFO_MAXSIZE] = { 0 };

    // status
    int status = -1;

    //'management info base' array
    int mib[3] = { 0 };

    // system's size for max args
    unsigned long systemMaxArgs = 0;

    // process's args
    char* taskArgs = NULL;

    //# of args
    int numberOfArgs = 0;

    // size of buffers, etc
    size_t size = 0;

    // reset buffer
    memset(pathBuffer, 0x0, PROC_PIDPATHINFO_MAXSIZE);

    // first attempt to get path via 'proc_pidpath()'
    status = proc_pidpath(pid, pathBuffer, sizeof(pathBuffer));
    if (0 != status) {
        // init task's name
        processPath = [NSString stringWithUTF8String:pathBuffer];
    }
    // otherwise
    //  try via task's args ('KERN_PROCARGS2')
    else {
        // init mib
        //  want system's size for max args
        mib[0] = CTL_KERN;
        mib[1] = KERN_ARGMAX;

        // set size
        size = sizeof(systemMaxArgs);

        // get system's size for max args
        if (-1 == sysctl(mib, 2, &systemMaxArgs, &size, NULL, 0)) {
            // bail
            goto bail;
        }

        // alloc space for args
        taskArgs = malloc(systemMaxArgs);
        if (NULL == taskArgs) {
            // bail
            goto bail;
        }

        // init mib
        //  want process args
        mib[0] = CTL_KERN;
        mib[1] = KERN_PROCARGS2;
        mib[2] = pid;

        // set size
        size = (size_t)systemMaxArgs;

        // get process's args
        if (-1 == sysctl(mib, 3, taskArgs, &size, NULL, 0)) {
            // bail
            goto bail;
        }

        // sanity check
        //  ensure buffer is somewhat sane
        if (size <= sizeof(int)) {
            // bail
            goto bail;
        }

        // extract number of args
        memcpy(&numberOfArgs, taskArgs, sizeof(numberOfArgs));

        // extract task's name
        //  follows # of args (int) and is NULL-terminated
        processPath = [NSString stringWithUTF8String:taskArgs + sizeof(int)];
    }

bail:

    // free process args
    if (NULL != taskArgs) {
        // free
        free(taskArgs);
        taskArgs = NULL;
    }

    return processPath;
}

// find a process by name
pid_t findProcess(NSString* processName)
{
    // pid
    pid_t pid = -1;

    // status
    int status = -1;

    //# of procs
    int numberOfProcesses = 0;

    // array of pids
    pid_t* pids = NULL;

    // process path
    NSString* processPath = nil;

    // get # of procs
    numberOfProcesses = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    if (-1 == numberOfProcesses) {
        // bail
        goto bail;
    }

    // alloc buffer for pids
    pids = calloc((unsigned long)numberOfProcesses, sizeof(pid_t));

    // get list of pids
    status = proc_listpids(PROC_ALL_PIDS, 0, pids, numberOfProcesses * (int)sizeof(pid_t));
    if (status < 0) {
        // bail
        goto bail;
    }

    // iterate over all pids
    //  get name for each via helper function
    for (int i = 0; i < numberOfProcesses; ++i) {
        // skip blank pids
        if (0 == pids[i]) {
            // skip
            continue;
        }

        // get path
        processPath = getProcessPath(pids[i]);
        if ((nil == processPath) || (0 == processPath.length)) {
            // skip
            continue;
        }

        // no match?
        if (YES != [processPath.lastPathComponent isEqualToString:processName]) {
            // skip
            continue;
        }

        // save
        pid = pids[i];

        // pau
        break;

    } // all procs

bail:

    // free buffer
    if (NULL != pids) {
        // free
        free(pids);
        pids = NULL;
    }

    return pid;
}

NSString* parseStringWithRegex(NSString* regexString, NSString* target) {
    if ([target rangeOfString:regexString options:NSRegularExpressionSearch].location == NSNotFound) {
        return @"";
    }
    
    NSError* error;
    NSString* __block result;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSRegularExpression *regex = [NSRegularExpression
        regularExpressionWithPattern:regexString
        options:NSRegularExpressionCaseInsensitive
        error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return nil;
    }
    
    [regex enumerateMatchesInString:target options:0 range:NSMakeRange(0, [target length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
        
        result = [target substringWithRange:[match rangeAtIndex:1]];

        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}


NSString* convertEuidToUsername(NSNumber* euid)
{
    struct passwd* pws;
    pws = getpwuid((uid_t)euid.intValue);

    if (pws == NULL) {
        return [NSString stringWithFormat:@"<UNKNOWN (euid=%@)>", euid];
    }

    return [NSString stringWithUTF8String:(char*)pws->pw_name];
}

NSString* convertGuidToUsername(NSNumber* guid)
{
    struct group* grp;
    grp = getgrgid((gid_t)guid.intValue);

    if (grp == NULL) {
        return [NSString stringWithFormat:@"<UNKNOWN (guid=%@)>", guid];
    }

    return [NSString stringWithUTF8String:(char*)grp->gr_name];
}

NSString* formatDateWithNumber(NSNumber* dateNumber) {
    // Convert NSNumber to long long
    long long timestamp = [dateNumber longLongValue];
    
    // Convert long long to NSDate
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    // Configure date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    // Format date
    NSString *formattedDateTime = [formatter stringFromDate:date];
    return formattedDateTime;
}

NSString* formatDateWithDate(NSDate* date) {
    
    // Configure date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    // Format date
    NSString *formattedDateTime = [formatter stringFromDate:date];
    return formattedDateTime;
}

//get app's version
// extracted from Info.plist
NSString* getAppVersion(void)
{
    //read and return 'CFBundleVersion' from bundle
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

//give path to app
// get full path to its binary
NSString* getAppBinary(NSString* appPath)
{
    //binary path
    NSString* binaryPath = nil;
    
    //app bundle
    NSBundle* appBundle = nil;
    
    //load app bundle
    appBundle = [NSBundle bundleWithPath:appPath];
    if(nil == appBundle)
    {
        //err msg
        NSLog(@"ERROR: failed to load app bundle for %@", appPath);
        
        //bail
        goto bail;
    }
    
    //extract executable
    binaryPath = [appBundle.executablePath stringByResolvingSymlinksInPath];
    
bail:
    
    return binaryPath;
}

//given a path to binary
// parse it back up to find app's bundle
NSBundle* findAppBundle(NSString* path)
{
    //app's bundle
    NSBundle* appBundle = nil;
    
    //standarized path
    NSString* standardedPath = nil;
    
    //app's path
    NSString* appPath = nil;
    
    //standardize path
    standardedPath = [[path stringByStandardizingPath] stringByResolvingSymlinksInPath];
    
    //first just try full path
    appPath = standardedPath;
    
    //try to find the app's bundle
    do
    {
        //try to load app's bundle
        appBundle = [NSBundle bundleWithPath:appPath];
        
        //was an app passed in?
        if(YES == [appBundle.bundlePath isEqualToString:standardedPath])
        {
            //all done
            break;
        }
        
        //check for match
        // binary path's match
        if( (nil != appBundle) &&
            (YES == [appBundle.executablePath isEqualToString:standardedPath]))
        {
            //all done
            break;
        }
        
        //unset
        appBundle = nil;
        
        //remove last part
        // will try this next
        appPath = [appPath stringByDeletingLastPathComponent];
        
    //scan until we get to root
    // of course, loop will exit if app info dictionary is found/loaded
    } while( (nil != appPath) &&
             (YES != [appPath isEqualToString:@"/"]) &&
             (YES != [appPath isEqualToString:@""]) );
    
    return appBundle;
}

//get an icon for a process
// for apps, this will be app's icon, otherwise just a standard system one
NSImage* getIconForProcess(NSString* path)
{
    //icon's file name
    NSString* iconFile = nil;
    
    //icon's path
    NSString* iconPath = nil;
    
    //icon's path extension
    NSString* iconExtension = nil;
    
    //icon
    NSImage* icon = nil;
    
    //system's document icon
    static NSImage* documentIcon = nil;
    
    //bundle
    NSBundle* appBundle = nil;
    
    //invalid path?
    // grab a default icon and bail
    if(YES != [[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        //set icon to system 'application' icon
        icon = [[NSWorkspace sharedWorkspace] iconForContentType:UTTypeApplicationBundle];

        //set size to 64 @2x
        [icon setSize:NSMakeSize(128, 128)];
   
        //bail
        goto bail;
    }
    
    //first try grab bundle
    // then extact icon from this
    appBundle = findAppBundle(path);
    if(nil != appBundle)
    {
        //extract icon
        icon = [[NSWorkspace sharedWorkspace] iconForFile:appBundle.bundlePath];
        if(nil != icon)
        {
            //done!
            goto bail;
        }
        
        //get file
        iconFile = appBundle.infoDictionary[@"CFBundleIconFile"];
        
        //get path extension
        iconExtension = [iconFile pathExtension];
        
        //if its blank (i.e. not specified)
        // go with 'icns'
        if(YES == [iconExtension isEqualTo:@""])
        {
            //set type
            iconExtension = @"icns";
        }
        
        //set full path
        iconPath = [appBundle pathForResource:[iconFile stringByDeletingPathExtension] ofType:iconExtension];
        
        //load it
        icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    }
    
    //process is not an app or couldn't get icon
    // try to get it via shared workspace
    if( (nil == appBundle) ||
        (nil == icon) )
    {
        //extract icon
        icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        
        //load system document icon
        // static var, so only load once
        if(nil == documentIcon)
        {
            //load
            documentIcon = [[NSWorkspace sharedWorkspace] iconForContentType:UTTypePlainText];

        }
        
        //if 'iconForFile' method doesn't find and icon, it returns the system 'document' icon
        // the system 'application' icon seems more applicable, so use that here...
        if(YES == [icon isEqual:documentIcon])
        {
            //set icon to system 'application' icon
            icon =  [[NSWorkspace sharedWorkspace] iconForContentType:UTTypeApplicationBundle];
        }
        
        //'iconForFileType' returns small icons
        // so set size to 64 @2x
        [icon setSize:NSMakeSize(128, 128)];
    }
    
bail:
    
    return icon;
}


NSImage* getIconForBundle(NSBundle* bundle)
{
    //icon's file name
    NSString* iconFile = nil;
    
    //icon's path
    NSString* iconPath = nil;
    
    //icon's path extension
    NSString* iconExtension = nil;
    
    // default
    NSImage* icon =  [[NSWorkspace sharedWorkspace] iconForContentType:UTTypeApplicationBundle];
    [icon setSize:NSMakeSize(128, 128)];
    
    if (bundle != nil)
    {
        //extract icon
        icon = [[NSWorkspace sharedWorkspace] iconForFile:bundle.bundlePath];
        
        if(nil != icon)
        {
            //done!
            goto bail;
        }
        
        //get file
        iconFile = bundle.infoDictionary[@"CFBundleIconFile"];
        
        //get path extension
        iconExtension = [iconFile pathExtension];
        
        //if its blank (i.e. not specified)
        // go with 'icns'
        if(YES == [iconExtension isEqualTo:@""])
        {
            //set type
            iconExtension = @"icns";
        }
        
        //set full path
        iconPath = [bundle pathForResource:[iconFile stringByDeletingPathExtension] ofType:iconExtension];
        
        //load it
        icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    }
    
    
bail:
    
    return icon;
}

NSString* getConsoleUser(void)
{
    //copy/return user
    return CFBridgingRelease(SCDynamicStoreCopyConsoleUser(NULL, NULL, NULL));
}

NSString* stringFromAuthReason(int code) {
    NSString *result;
    switch (code) {
        case 1:
            result = @"Error";
            break;
        case 2:
            result = @"User Consent";
            break;
        case 3:
            result = @"User Set";
            break;
        case 4:
            result = @"System Set";
            break;
        case 5:
            result = @"Service Policy";
            break;
        case 6:
            result = @"MDM Policy";
            break;
        case 7:
            result = @"Override Policy";
            break;
        case 8:
            result = @"Missing usage string";
            break;
        case 9:
            result = @"Prompt Timeout";
            break;
        case 10:
            result = @"Preflight Unknown";
            break;
        case 11:
            result = @"Entitled";
            break;
        case 12:
            result = @"App Type Policy";
            break;
        default:
            result = @"Unknown";
            break;
    }
    return result;
}

NSString* stringFromAuthValue(int code) {
    NSString* result;
    switch (code) {
        case 0:
            result = @"Denied";
            break;
        case 1:
            result = @"Authorization unknown";
            break;
        case 2:
            result = @"Allowed";
            break;
        case 3:
            result = @"Limited";
            break;
    }
    return result;
}


void checkLaunchdPlist(void) {
     NSFileManager *fileMgr = [NSFileManager defaultManager];
     NSString* targetPath = [@"~/Library/LaunchAgents/io.phorion.kronos.plist" stringByExpandingTildeInPath];

    if ([fileMgr fileExistsAtPath:targetPath] == YES) {
        // Open the plist file from the bundle
        NSMutableDictionary* launchdPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:targetPath];
        
        if ([launchdPlist[@"Program"] isEqualToString:[[NSBundle mainBundle] executablePath]] == NO) {
            [launchdPlist setObject:[[NSBundle mainBundle] executablePath] forKey:@"Program"];
            [launchdPlist writeToFile:targetPath atomically:YES];
        }
    }
}
