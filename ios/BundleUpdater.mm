#import "BundleUpdater.h"

#import "BundleUpdaterBottomSheetViewController.h"

#import "CommonCrypto/CommonDigest.h"
#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTReloadCommand.h>
#import <sys/utsname.h>

@implementation BundleUpdater
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

NSString *apiUrl = @"http://192.168.1.136";
NSDictionary *update_config = @{};

+ (instancetype)sharedInstance {
    static BundleUpdater *sharedInstance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
      sharedInstance = [[BundleUpdater alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSMutableData *)calculateSHA256Hash:(NSData *)script {
    NSMutableData *hash =
        [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(script.bytes, (CC_LONG)script.length,
              (unsigned char *)hash.mutableBytes);
    return hash;
}

- (NSString *)loadHashFromDisk {
    NSString *hashPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    NSString *oldHash = [NSString stringWithContentsOfFile:hashPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    return oldHash;
}

- (void)saveNewBundleAndHashToDisk:(NSData *)script
                        hashString:(NSString *)hashString {
    // Save the bundle on a folder with the sdk key as path
    //    NSString *folder =
    //    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
    //    NSUserDomainMask, YES) firstObject]; NSFileManager *manager =
    //    [NSFileManager defaultManager];
    NSString *scriptPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle"];
    [script writeToFile:scriptPath atomically:YES];

    NSString *hashPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    [hashString writeToFile:hashPath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
}

- (NSString *)getDeviceModelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (void)getPhoneBatteryLevel {
    //    UIDevice *device = [UIDevice currentDevice];
    //    [device setBatteryMonitoringEnabled:YES];
    //    switch ([device batteryState]) {
    //		case UIDeviceBatteryStateCharging:
    //			return @"Charging";
    //		case UIDeviceBatteryStateFull:
    //			return @"Charge complete";
    //		case UIDeviceBatteryStateUnplugged:
    //			return @"Unplugged";
    //		case UIDeviceBatteryStateUnknown:
    //			return @"Unknown";
    //    }

    //    return @"Unknown";
}

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
    //    NSString *phoneChargingState = [self getPhoneBatteryLevel];
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
        @"sdkVersion" : @"ALPHA-", // SDK_VERSION",
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

- (void)showBottomSheet:(NSDictionary *)updateData {
    BundleUpdaterBottomSheetViewController *bottomSheetVC =
        [[BundleUpdaterBottomSheetViewController alloc] init];

    // Set the data properties of the bottom sheet view controller
    bottomSheetVC.image = updateData[@"image"];
    bottomSheetVC.titleText = updateData[@"title"];
    ;
    bottomSheetVC.message = updateData[@"message"];
    bottomSheetVC.buttonLabel = updateData[@"button_label"];
    bottomSheetVC.buttonLink = updateData[@"button_label"];
    bottomSheetVC.buttonBackgroundColor = updateData[@"button_color"];
    bottomSheetVC.buttonIcon = [UIImage imageNamed:@"button_icon"];
    bottomSheetVC.footerLogo = [UIImage imageNamed:@"sdk_logo"];

    UIViewController *rootViewController =
        [[[UIApplication sharedApplication] keyWindow] rootViewController];

    bottomSheetVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    bottomSheetVC.transitioningDelegate = self;

    [rootViewController presentViewController:bottomSheetVC
                                     animated:YES
                                   completion:nil];
}

- (void)initialization:(NSString *)apiKey
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {

    NSString *savedBundle =
        [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleId"];
    NSString *urlString =
        [NSString stringWithFormat:@"%@/project/%@/initialize", apiUrl, apiKey];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    // Create a dictionary to hold the field values
    //    NSDictionary *fields = [[NSMutableDictionary alloc]
    //        initWithDictionary:@{@"metaData" : [self getMetaData]}];
    
    NSDictionary *body = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"metaData" : [self getMetaData],
        @"bundleId" : savedBundle ? savedBundle : @""
    }];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                       options:0
                                                         error:&jsonError];
    if (!jsonData) {
		// TODO fix Conflicting parameter types in implementation of
		// 'initialization:resolve:reject:': 'void (^__strong)(NSString *__strong)'
		// vs '__strong RCTPromiseResolveBlock' (aka 'void (^__strong)(__strong
		// id)')
        NSLog(@"[SDK] JSON serialization error: %@", jsonError);
        reject(@"error", @"JSON serialization error", jsonError);
        return;
    }

    // Set the request body with the JSON data
    [request setHTTPBody:jsonData];

    // Set the appropriate headers for JSON
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // Create the session configuration and session
    NSURLSessionConfiguration *sessionConfiguration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:sessionConfiguration];
    //     MARK: - TO TEST THE MODAL
    //     dispatch_async(dispatch_get_main_queue(), ^{
    //        [self showBottomSheet:@{
    //            @"button_color": @"#FF1542",
    //            @"button_label": @"Aggiorna ora",
    //            @"button_link" : @"https://xylem.com",
    //            @"image" : @"https://i.ibb.co/ngTj6wc/xylem-italia-logo.jpg",
    //            @"message": @"Per continuare a utilizzare Xylem X, aggiorna
    //            per le ultime funzionalita e correzioni di bug.",
    //            @"privacy": @"https://develondigital.com",
    //            @"title": @"Aggiornamento disponibile!"
    //       }];
    //    });
    // Create the task to send the request
    NSURLSessionDataTask *dataTask = [session
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response,
                              NSError *error) {
            if (error) {
                NSLog(@"[SDK] initialization error: %@", error);
                reject(@"error", @"Initialization error", error);
            } else {
                NSLog(@"[SDK] initialization response: %@",
                      [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding]);
                resolve(@"Initialization success");
                NSError *jsonError;
                NSDictionary *responseDict =
                    [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&jsonError];
                if (jsonError) {
                    NSLog(@"[SDK] JSON parsing error: %@", jsonError);
                    return;
                }
                NSLog(@"%@", responseDict.description);
                @try {
                    if ([responseDict valueForKey:@"update_required"]) {
                        // Pass the "update_required" object to the
                        // showBottomSheet method
                        update_config =
                            [responseDict valueForKey:@"update_required"];
                        NSString *bundle_id =
                            [responseDict valueForKey:@"bundleId"];
                        [[NSUserDefaults standardUserDefaults]
                            setObject:bundle_id
                               forKey:@"bundleId"];
                        //                    dispatch_async(dispatch_get_main_queue(),
                        //                    ^{
                        //                      [self
                        //                      showBottomSheet:responseDict[@"update_required"]];
                        //                    });
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Update not required");
                }
            }
          }];

    [dataTask resume];
}

- (NSURL *)initializeBundle:(RCTBridge *)bridge withKey:(NSString *)key {
#if DEBUG
    return [[RCTBundleURLProvider sharedSettings]
        jsBundleURLForBundleRoot:@"index"];
#else
    // verify if the key is the same as the previous one
    NSString *oldKey =
        [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleKey"];
    if (!oldKey || ![oldKey isEqualToString:key]) {
        NSLog(@"detected api key change");
        // if not, delete the old bundle
        NSString *documentDirectoryJSBundleFilePath =
            [[NSSearchPathForDirectoriesInDomains(
                NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                stringByAppendingPathComponent:@"main.jsbundle"];
        BOOL isDir;
        BOOL fileExistsAtPath = [[NSFileManager defaultManager]
            fileExistsAtPath:documentDirectoryJSBundleFilePath
                 isDirectory:&isDir];
        if (fileExistsAtPath) {
            [[NSFileManager defaultManager]
                removeItemAtPath:documentDirectoryJSBundleFilePath
                           error:nil];
        }
        [[NSUserDefaults standardUserDefaults] setObject:key
                                                  forKey:@"bundleKey"];
    }
    // Check if there is the main.jsbundle file in the Document directory
    NSString *documentDirectoryJSBundleFilePath =
        [[NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent:@"main.jsbundle"];
    BOOL isDir;
    BOOL fileExistsAtPath = [[NSFileManager defaultManager]
        fileExistsAtPath:documentDirectoryJSBundleFilePath
             isDirectory:&isDir];
    if (!fileExistsAtPath) {
        NSLog(@"[SDK]Missing file so picking default");
        return [[NSBundle mainBundle] URLForResource:@"main"
                                       withExtension:@"jsbundle"];
    } else {
        NSLog(@"[SDK]GOT file %@", documentDirectoryJSBundleFilePath);
        return [NSURL fileURLWithPath:documentDirectoryJSBundleFilePath];
    }
#endif
}

RCT_EXPORT_METHOD(checkAndReplaceBundle : (NSString *)apiKey) {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          // Fetch script from server
          NSString *url = [NSString
              stringWithFormat:@"%@/project/%@/bundle", apiUrl, apiKey];

          NSLog(@"[SDK] Fetching script from %@", url);

          NSURL *scriptURL = [NSURL URLWithString:url];

          NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
          [request setURL:scriptURL];
          [request setHTTPMethod:@"POST"];

          // Set the appropriate headers for your request
          [request setValue:@"application/json"
              forHTTPHeaderField:@"Content-Type"];
          [request setValue:@"Bearer <YOUR_AUTH_TOKEN>"
              forHTTPHeaderField:@"Authorization"];

          NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession]
              downloadTaskWithRequest:request
                    completionHandler:^(NSURL *location,
                                        NSURLResponse *response,
                                        NSError *error) {
                      if (error) {
                          NSLog(@"[SDK] ERROR: %@", error);
                          return;
                      }

                      if (location) {
                          // The file has been downloaded successfully and is
                          // located at `location`. You can now read it into a
                          // NSData object.
                          NSData *script =
                              [NSData dataWithContentsOfURL:location];
                          // Now you can use the data
                          if (!script) {
                              NSLog(@"[SDK] MISSING SCRIPT DATA FOR URL: %@",
                                    script);
                              return;
                          }

                          // Calculate sha256 hash
                          NSMutableData *hash =
                              [self calculateSHA256Hash:script];
                          NSString *hashString =
                              [hash base64EncodedStringWithOptions:0];

                          // Load hash from disk
                          NSString *oldHash = [self loadHashFromDisk];

                          NSLog(@"[SDK] OLDHASH: %@", oldHash);
                          NSLog(@"[SDK] NEWHAS: %@", hashString);

                          if (![hashString isEqualToString:oldHash]) {
                              // If the file has changed, save the new bundle
                              // and hash to disk
                              [self saveNewBundleAndHashToDisk:script
                                                    hashString:hashString];
                              NSLog(@"[SDK] SAVED NEW BUNDLE CORRECTLY");
                              dispatch_async(dispatch_get_main_queue(), ^{
                                [self showBottomSheet:update_config];
                              });
                          } else {
                              NSLog(@"[SDK] BUNDLE IS UP TO DATE");
                          }
                      } else {
                          // An error occurred during the download. Handle it
                          // here.
                          NSString *errorMessage = [NSString
                              stringWithFormat:@"Error: %@",
                                               error.localizedDescription];
                          NSString *errorCode = [NSString
                              stringWithFormat:@"%ld", (long)error.code];
                          NSString *errorString = [NSString
                              stringWithFormat:
                                  @"{\"code\": %@, \"message\": \"%@\"}",
                                  errorCode, errorMessage];
                          NSLog(@"[SDK] An error occurred: %@", errorString);
                      }
                    }];
          [downloadTask resume];
        });
}

RCT_EXPORT_METHOD(reload) {
    dispatch_async(dispatch_get_main_queue(), ^{
      RCTTriggerReloadCommandListeners(@"bundle changed");
    });
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeBundleUpdaterSpecJSI>(
        params);
}
#endif

@end
