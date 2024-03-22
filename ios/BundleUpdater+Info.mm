#import "BundleUpdater+Info.h"
@implementation BundleUpdater (Info)

/*!
 *  @brief get the device model info
 *
 *  @return a string with the info of the device
 */
- (NSString *)getDeviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

/*!
 *  @brief get the a list of info as summary for the device
 *
 *  @return a dictionary with the info
 */
- (NSDictionary *)getMetaData {
    UIDevice *device = [UIDevice currentDevice];
    NSString *device_name = device.name;
    NSString *device_model = [self getDeviceModelName];
    NSString *systemname = device.systemName;
    NSString *systemVersion = device.systemVersion;
    NSString *deviceIdentifier = [[device identifierForVendor] UUIDString];
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *marketingVersion = infoDictionary[@"CFBundleShortVersionString"];
    NSString *projectVersion = infoDictionary[@"CFBundleVersion"];

    NSString *preferredUserLocale =
        [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    NSString *batteryLevel = @"Unknown";
    // TODO   NSString *phoneChargingState = [self getPhoneBatteryLevel];
    //    if (![phoneChargingState isEqualToString:@"Unknown"]) {
    //        batteryLevel = [NSString
    //            stringWithFormat:@"%.f", (float)[device batteryLevel] * 100];
    //    }
    NSString *lowPowerModeEnabled =
        [[NSProcessInfo processInfo] isLowPowerModeEnabled] ? @"true"
                                                            : @"false";
    //    NSDictionary *diskInfo = [self getDiskInfo];
    NSString *buildMode = @"RELEASE";
#ifdef DEBUG
    buildMode = @"DEBUG";
#endif
    float scaleFactor = [[UIScreen mainScreen] scale];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    return @{
        @"device_name" : device_name,
        @"device_model" : device_model,
        @"deviceIdentifier" : deviceIdentifier,
        @"bundleID" : bundleID,
        @"system_name" : systemname,
        @"systemVersion" : systemVersion,
        @"buildVersionNumber" : marketingVersion,
        @"releaseVersionNumber" : projectVersion,
        @"preferredUserLocale" : preferredUserLocale,
        @"sdkVersion" : @"ALPHA-1", // SDK_VERSION",
        @"buildMode" : buildMode,
        @"batteryLevel" : batteryLevel,
        //        @"phoneChargingStatus" : phoneChargingState,
        @"batterySaveMode" : lowPowerModeEnabled,
        //        @"totalDiskSpace" : [diskInfo objectForKey:@"totalSpace"],
        //        @"totalFreeDiskSpace" : [diskInfo
        //        objectForKey:@"totalFreeSpace"],
        @"devicePixelRatio" : @(scaleFactor),
        @"screenWidth" : @(screenWidth),
        @"screenHeight" : @(screenHeight)
    };
}

@end