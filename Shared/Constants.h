
//  Constants.h
//  tcc-kronos




#ifndef Constants_h
#define Constants_h

#define APP_BUNDLE_ID @"io.phorion.tcc-kronos"
#define TEAM_ID @"Z2FDA4QHGU"

#define SYSEXT_PROCESS_NAME @"io.phorion.tcc-kronos.TCCKronosExtension"
#define SYSEXT_BUNDLE_ID @"Z2FDA4QHGU.io.phorion.tcc-kronos.TCCKronosExtension.xpc"

#define LAUNCH_DEMON_PLIST @"~/Library/LaunchAgents/io.phorion.kronos.plist"

#define APP_BACKGROUND [NSColor colorWithSRGBRed:0.09 green:0.09 blue:0.09 alpha:0.95]

#define DATABASE_PATH @"/Library/Application Support/Phorion/Kronos/"
#define DATABASE_NAME @"db.sqlite"

#define BACKGROUND_TASK_IDENTIFIER @"io.phorion.tcc-kronos.TCCKronosBackground"

#define SETTING_ESF @"KronosESFTamperingDetectionEnabled"
#define SETTING_SENTRY @"KronosSentryTelemetryEnabled"
#define SETTING_AUTO_UPDATE @"KronosSparkleAutoUpdateEnabled"

#endif /* Constants_h */
