#import "BundleUpdater.h"
#import "BundlerUpdaterNitificationVC.h"
#import "BundleUpdaterViewController.h"
#import "CommonCrypto/CommonDigest.h"

#import <React/RCTBridgeModule.h>
#import <sys/utsname.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTReloadCommand.h>


@interface BundleUpdater()
// in this case props will be visible to any subclass (them are still private)
// useful when need of getter and setter by default
    @property (nonatomic, strong) NSString *apiUrl;
    @property (nonatomic, strong) NSString *bundle_id_from_api;
    @property (nonatomic, strong) BundleUpdaterViewController *updaterVC;
@end

@implementation BundleUpdater{
//    in this case are private instance variables only visible inside this class and not on subclasses
//    NSString *_apiUrl;
//    NSString *_bundle_id_from_api;
//    BundleUpdaterViewController *_updaterVC;
}
RCT_EXPORT_MODULE()

// MARK: - INIT

+ (instancetype)sharedInstance{
    static BundleUpdater *sharedInstance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        sharedInstance = [[BundleUpdater alloc] init];
    });
    return sharedInstance;
}

// MARK: - SETTERS

- (NSString *)apiUrl{
    //lazy initialization
    if(!_apiUrl){
        _apiUrl = @"http://192.168.1.92:3003";
    }
    return _apiUrl;
}

- (NSString *)bundle_id_from_api{
    // lazy init
    if(!_bundle_id_from_api){
        _bundle_id_from_api = @"";
    }
    return _bundle_id_from_api;
}

- (BundleUpdaterViewController *)updaterVC {
    // lazy init
    if(!_updaterVC){
        _updaterVC = [[BundleUpdaterViewController alloc] init];
    }
    return _updaterVC;
}

// MARK: - METHODS

/*!
 *  @brief get the hash of the file
 *
 *  @param script - data of the bundle
 * *
 *  @return a data hash
 */
- (NSMutableData *)calculateSHA256Hash:(NSData *)script {
    NSMutableData *hash =
        [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(script.bytes, (CC_LONG)script.length,
              (unsigned char *)hash.mutableBytes);
    return hash;
}

/*!
 *  @brief load the saved hash of the file from  disk
 *
 *  @return a string hash of the file
 */
- (NSString *)loadHashFromDisk {
    NSString *hashPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    NSString *oldHash = [NSString stringWithContentsOfFile:hashPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    return oldHash;
}

/*!
 *  @brief save the new bundle and the hash on disk
 *
 *  @param script - data of  bundle
 *
 *  @param hashString - the hash of the bundle file
 */
- (void)saveNewBundle:(NSData *)script
                 andHashString:(NSString *)hashString
                 andAssetsFiles:(NSArray*)assetsFiles
                 fromFolder:(NSString *)sourceFolder{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *scriptPath = [documentsDirectory
        stringByAppendingPathComponent:@"main.jsbundle"];
    [script writeToFile:scriptPath atomically:YES];

    NSString *hashPath = [documentsDirectory
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    [hashString writeToFile:hashPath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
    //assets
    NSString *assetsDirectory = [documentsDirectory stringByAppendingPathComponent:@"assets"];
    //check if the directory already exist
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:assetsDirectory]){
        [manager createDirectoryAtPath:assetsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // Salva i file nella cartella "assets"
    for (NSDictionary *fileObj in assetsFiles) {
        NSString *fileName = fileObj[@"file"];
        NSData *fileData = [[NSData alloc] initWithBase64EncodedString:fileObj[@"data"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
        NSString *destinationPath = [assetsDirectory stringByAppendingPathComponent:fileName];
        
        [fileData writeToFile:destinationPath atomically:YES];
    }
    NSLog(@"[SDK] bundle and assets saved on disk");
}

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

/*!
 *  @brief show the update bottomsheet if the config are supplied
 *
 *  @param updateData - dictionary with the sheet config
 */
- (void)showUpdateVC:(NSDictionary *)updateData withNecessaryUpdate:(BOOL)isNecessaryUpdate{
    // Set the data properties of the bottom sheet view controller
    self.updaterVC.image = updateData[@"image"];
    self.updaterVC.titleText = updateData[@"title"];
    self.updaterVC.message = updateData[@"message"];
    self.updaterVC.buttonLabel = updateData[@"button_label"];
    self.updaterVC.buttonLink = updateData[@"button_label"];
    self.updaterVC.buttonBackgroundColor = updateData[@"button_color"];
    self.updaterVC.buttonIcon = [UIImage imageNamed:@"button_icon"];
    self.updaterVC.footerLogo = [UIImage imageNamed:@"sdk_logo"];
    if(isNecessaryUpdate){
        self.updaterVC.isNecessaryUpdate = true;
    }
    NSString *type = updateData[@"type"];
    if([type isEqualToString:@"Notification"]){
        //TODO - pass config to the notification
        BundlerUpdaterNitificationVC *notificationVC = [BundlerUpdaterNitificationVC new];
        notificationVC.isNecessaryUpdate = isNecessaryUpdate;
        if([notificationVC isKindOfClass:[UIViewController class]]){
            UIViewController *_notificationVC = (UIViewController *)notificationVC;
            _notificationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            // present the new viewContoller
            dispatch_async(dispatch_get_main_queue(), ^{
               UIWindow *window = [[UIApplication sharedApplication] keyWindow];
               UIViewController *rootViewController = window.rootViewController;
               [rootViewController presentViewController:_notificationVC animated:NO completion:nil];
            });
            return;
        }else{
           NSLog(@"[SDK] It's NOT an UIViewController, display normal bottomsheet");
        }
    }else if([type isEqualToString:@"Modal"]){
        self.updaterVC.isModal = true;
    }
    UIViewController *rootViewController =
        [[[UIApplication sharedApplication] keyWindow] rootViewController];
    self.updaterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.updaterVC.transitioningDelegate = self;
    [rootViewController presentViewController:self.updaterVC
                                     animated:YES
                                   completion:nil];
}

/*!
 *  @brief hide the bottomsheet*
 */
-(void)hideBottomSheet {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.updaterVC dismissViewControllerAnimated:YES completion:nil];
    });
}


/*!
 *  @brief Initialize the  app with the apikey | get the configuration for the sheet/app
 *
 *  @param apiKey - the apiKey for the app
 */
- (void)initialization:(NSString *)apiKey
               resolve:(void (^)(NSString *))resolve
                reject:(void (^)(NSString *, NSString *, NSError *))reject {
    // TODO fix Conflicting parameter types in implementation of
    // 'initialization:resolve:reject:': 'void (^__strong)(NSString *__strong)'
    // vs '__strong RCTPromiseResolveBlock' (aka 'void (^__strong)(__strong
    // id)')
    NSString *savedBundle = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"bundleId"];
    NSString *oldKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleKey"];
    if(!oldKey || ![oldKey isEqualToString:apiKey]){
        NSLog(@"detected api key change");
        //remove the saved bundleId - the actual deletion will be done in the initializeBundle method
        savedBundle = @"";
    }
        
        
    NSString *urlString =
        [NSString stringWithFormat:@"%@/project/%@/initialize", self.apiUrl, apiKey];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];

    // Create a dictionary to hold the field values
//    NSDictionary *fields = [[NSMutableDictionary alloc]
//        initWithDictionary:@{@"metaData" : [self getMetaData]}];
    NSDictionary *body = [[NSMutableDictionary alloc]
        initWithDictionary:@{
            @"metaData" : [self getMetaData],
            @"bundleId" : savedBundle ? savedBundle : @""
        }];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                       options:0
                                                         error:&jsonError];
    if (!jsonData) {
        NSLog(@"[SDK] JSON serialization error: %@", jsonError);
        reject(@"error", @"JSON serialization error", jsonError);
        return;
    }

    // Set the request body with the JSON data
    // NSLog(@"[SDK] init json %@", body.description);
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
//        [self showUpdateVC:@{
//            @"button_color": @"#FF1542",
//            @"button_label": @"Aggiorna ora",
//            @"button_link" : @"https://xylem.com",
//            @"image" : @"https://i.ibb.co/ngTj6wc/xylem-italia-logo.jpg",
//            @"message": @"Per continuare a utilizzare Xylem X, aggiorna per le ultime funzionalita e correzioni di bug.",
//            @"privacy": @"https://develondigital.com",
//            @"title": @"Aggiornamento disponibile!"
//       }];
//    });
// MARK: - to test the notification
//    AlertViewTest *alertVC = [AlertViewTest new];
//    if([alertVC isKindOfClass:[UIViewController class]]){
//        NSLog(@"is uiViewController");
//        UIViewController *_alertVC = (UIViewController *)alertVC;
//        _alertVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//        // present the new viewContoller
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//            UIViewController *rootViewController = window.rootViewController;
//            [rootViewController presentViewController:_alertVC animated:NO completion:nil];
//        });
//        // [alertView useAlertView];
//    }else{
//        NSLog(@"is NOT uiViewController");
//    }

    
    // Create the task to send the request
    NSURLSessionDataTask *dataTask = [session
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response,
                              NSError *error) {
            if (error) {
                NSLog(@"[SDK] initialization error: %@", error);
                reject(@"error", @"Initialization error", error);
            } else {
//                NSHTTPURLResponse *httpResponse =
//                    (NSHTTPURLResponse *)response;
//                NSLog(@"[SDK] initialization response: %@",
//                      [[NSString alloc] initWithData:data
//                                            encoding:NSUTF8StringEncoding]);
//                if(httpResponse.statusCode == 404){
//                    
//                }
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
//                NSLog(@"%@", responseDict.description);
//                NSLog(@"%@", [responseDict valueForKey:@"update_required"]);
                id updateRequiredValue = [responseDict valueForKey:@"update_required"];
                if (updateRequiredValue != nil) {
                    NSLog(@"Update required %@", updateRequiredValue ? @"YES": @"NO");
                    if([updateRequiredValue isKindOfClass:[NSNumber class]]){
                       // update not required
                    }else{
                        //update required
                        if ([responseDict valueForKey:@"update_required"]) {
                            bool isNecessaryUpdate = [[responseDict valueForKey:@"is_necessary"] boolValue];
                            self.bundle_id_from_api = [responseDict valueForKey:@"bundleId"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self showUpdateVC:updateRequiredValue withNecessaryUpdate:isNecessaryUpdate];
                            });
                        }
                    }
                }
            }
          }];

    [dataTask resume];
}

/*!
 *  @brief  Initialize the bundle for react native
 *
 *  @param bridge - the react native bridge to start the app
 *
 *  @param key - the apiKey for the app
 *
 *  @return a bundle for the react native app
 */
- (NSURL *)initializeBundle:(RCTBridge *)bridge withKey:(NSString *)key{
  #if DEBUG
      return [[RCTBundleURLProvider sharedSettings]
          jsBundleURLForBundleRoot:@"index"];
  #else
      //verify if the key is the same as the previous one
      NSString *oldKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleKey"];
      if(!oldKey || ![oldKey isEqualToString:key]){
        NSLog(@"detected api key change");
        //if not, delete the old bundle
        NSString *documentDirectoryJSBundleFilePath =
            [[NSSearchPathForDirectoriesInDomains(
                NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                stringByAppendingPathComponent:@"main.jsbundle"];
        BOOL isDir;
        BOOL fileExistsAtPath = [[NSFileManager defaultManager]
            fileExistsAtPath:documentDirectoryJSBundleFilePath
                 isDirectory:&isDir];
        if (fileExistsAtPath) {
            [[NSFileManager defaultManager] removeItemAtPath:documentDirectoryJSBundleFilePath error:nil];
        }
        [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"bundleKey"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"bundleId"];
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

/*!
 *  @brief Check the bundle hash if it's the same and open the bottomsheet if not
 *
 *  @param apiKey - the api key of the project
 */
RCT_EXPORT_METHOD(checkAndReplaceBundle : (nullable NSString *)apiKey) {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          //Save the actual bundle id on the phone
          [[NSUserDefaults standardUserDefaults] setObject:self.bundle_id_from_api forKey:@"bundleId"];
          // get the saved api key
          NSString *_key = [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleKey"];
          NSString *keyToUse = apiKey ? apiKey : _key;
          // Fetch script from server
          NSString *url = [NSString
              stringWithFormat:@"%@/project/%@/bundle", self.apiUrl, keyToUse];

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
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                  NSLog(@"Error: %@", error.localizedDescription);
                  return;
                }
                NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
                // NSLog(@"%ld",(long)res.statusCode);
                if(res.statusCode == 200){
                  NSError *jsonError;
                  NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                  if (jsonError) {
                      NSLog(@"Errore nella decodifica del JSON: %@", jsonError.localizedDescription);
                      return;
                  }
                  // Estrai il bundle e la cartella "assets" dalla risposta JSON
                    NSString *bundleName = responseDict[@"bundle"][@"file"];
                    NSString *bundleContent = responseDict[@"bundle"][@"data"];
                    NSData *bundleData = [[NSData alloc] initWithBase64EncodedString:bundleContent options:NSDataBase64DecodingIgnoreUnknownCharacters];
                       
                    // Calculate sha256 hash
                    NSMutableData *hash =
                        [self calculateSHA256Hash:bundleData];
                    NSString *hashString =
                        [hash base64EncodedStringWithOptions:0];
                    // Load hash from disk - For now removed
//                    NSString *oldHash = [self loadHashFromDisk];
//                    NSLog(@"[SDK] OLDHASH: %@", oldHash);
//                    NSLog(@"[SDK] NEWHAS: %@", hashString);
//                    if (![hashString isEqualToString:oldHash]) {
                  
                  //ASSETS
                  NSString *assetsFolderPath = responseDict[@"assetsFolder"][@"path"];
                  NSArray *assetsFiles = responseDict[@"assetsFolder"][@"files"];
                  [self saveNewBundle:bundleData andHashString:hashString andAssetsFiles:assetsFiles fromFolder:assetsFolderPath];
                  [self reload];
//                    }else{
//                        NSLog(@"[SDK] BUNDLE IS UP TO DATE");
//                    }
                 
                }else if(res.statusCode == 404){
                    //TODO
                }else {
                    //generic error
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
                // update done or not - dismiss bottomsheet
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.2 animations:^{
                        self.updaterVC.backgroundView.alpha = 0;
                    }];
                [NSTimer scheduledTimerWithTimeInterval:0.2
                        target:self
                        selector:@selector(hideBottomSheet)
                        userInfo:nil
                        repeats:NO];
                });
            }];
          [task resume];
        });
}

/*!
 *  @brief reload the bundle for the javascript section
 */
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


#pragma mark - TO IMPLEMENT:
//- (void)getPhoneBatteryLevel {
    //    UIDevice *device = [UIDevice currentDevice];
    //    [device setBatteryMonitoringEnabled:YES];
    //    switch ([device batteryState]) {
    //        case UIDeviceBatteryStateCharging:
    //            return @"Charging";
    //        case UIDeviceBatteryStateFull:
    //            return @"Charge complete";
    //        case UIDeviceBatteryStateUnplugged:
    //            return @"Unplugged";
    //        case UIDeviceBatteryStateUnknown:
    //            return @"Unknown";
    //    }

    //    return @"Unknown";
//}
@end
