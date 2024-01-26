#import "BundleUpdater.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTReloadCommand.h>
#import "BundleUpdater+FileManager.h"
#import "BundleUpdater+Info.h"
#import "BundleUpdater+UI.h"
#import "NetworkManager.h"


@interface BundleUpdater()
// in this case props will be visible to any subclass (them are still private)
// useful when need of getter and setter by default
    @property (nonatomic, strong) NSString *bundle_id_from_api;
    @property (nonatomic, strong) NSString *branch;
@end

@implementation BundleUpdater
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
NSString *const API_URL = @"http://192.168.1.92:3000";

+ (NSString *)API_URL{
    return API_URL;
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
    NSFileManager *manager = [NSFileManager defaultManager];

    // bundle
    NSString *scriptPath = [documentsDirectory
        stringByAppendingPathComponent:@"main.jsbundle"];
    [script writeToFile:scriptPath atomically:YES];
    // hash for the bundle
    NSString *hashPath = [documentsDirectory
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    [hashString writeToFile:hashPath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
    // assets
    NSString *assetsDirectory = [documentsDirectory stringByAppendingPathComponent:@"assets"];
    // check if the directory already exist
    if(![manager fileExistsAtPath:assetsDirectory]){
        [manager createDirectoryAtPath:assetsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // Save the assets files in the assets directory
   [self copyFilesFromSource:sourceFolder toDestination:assetsDirectory];
    NSLog(@"[BUNDLE UPDATER SDK]: bundle and assets saved on disk");
    // log the directory folder content
    NSLog(@"[BUNDLE UPDATER SDK]: content of the document folder %@", [manager contentsOfDirectoryAtPath:documentsDirectory error:nil]);
    NSLog(@"[BUNDLE UPDATER SDK]: content of the assets folder %@", [manager contentsOfDirectoryAtPath:assetsDirectory error:nil]);
}



/*!
 *  @brief Initialize the  app with the apikey | get the configuration for the sheet/app
 *
 *  @param apiKey - the apiKey for the app
 */
- (void)initialization:(NSString *)apiKey
            withBranch:(NSString *)branch{
    [self setBranch:branch];
    //check saved bundle
    NSString *savedBundle = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"bundleId"];
    NSString *oldKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"bundleKey"];
    if(!oldKey || ![oldKey isEqualToString:apiKey]){
        NSLog(@"[BUNDLE UPDATER SDK]: detected api key change");
        //remove the saved bundleId - the actual deletion will be done in the initializeBundle method
        savedBundle = @"";
    }
    __weak id weakself = self;
    [[NetworkManager sharedManager] initializeWithApiKey:apiKey andwithBundle:savedBundle onBranch:branch andWithCompletitionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"[BUNDLE UPDATER SDK]: initialization error: %@", error);
        } else {
            NSError *jsonError;
            NSDictionary *responseDict =
                [NSJSONSerialization JSONObjectWithData:data
                                                options:0
                                                  error:&jsonError];
            if (jsonError) {
                NSLog(@"[BUNDLE UPDATER SDK]: JSON parsing error: %@", jsonError);
                return;
            }
            id updateRequiredValue = [responseDict valueForKey:@"update_required"];
            if (updateRequiredValue != nil) {
                if([updateRequiredValue isKindOfClass:[NSNumber class]]){
                   // TODO - update not required
                }else{
                    //update required
                    if ([responseDict valueForKey:@"update_required"]) {
                        bool isNecessaryUpdate = [[responseDict valueForKey:@"is_necessary"] boolValue];
                        self.bundle_id_from_api = [responseDict valueForKey:@"bundleId"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakself showUpdateVC:updateRequiredValue withNecessaryUpdate:isNecessaryUpdate];
                        });
                    }
                }
            }
        }
    }];
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
        NSLog(@"[BUNDLE UPDATER SDK]: detected api key change");
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
          NSLog(@"[BUNDLE UPDATER SDK]: Missing file so picking default");
          return [[NSBundle mainBundle] URLForResource:@"main"
                                         withExtension:@"jsbundle"];
      } else {
          NSLog(@"[BUNDLE UPDATER SDK]: GOT file %@", documentDirectoryJSBundleFilePath);
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
           NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
           __weak id weakSelf = self;
           [[NetworkManager sharedManager] downloadBundleWithiKey:keyToUse withBranch:self.branch andVersion:appVersionString withCompletionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
               if (error) {
                   NSLog(@"[BUNDLE UPDATER SDK]: Error retrieving bundle: %@", error.localizedDescription);
                   return;
               }
               NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
               if (res.statusCode == 200) {
                   // Get the documents directory
                   BOOL success = false;
                   NSString *destinationFolderPath = [weakSelf unzipBundleAndAssetsInto:location withSuccess: &success];
                   if (success) {
                       //Log all the file in the destinationFolderPath
                       NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationFolderPath error:nil];
                       // NSLog(@"[BUNDLE UPDATER SDK]: Unzipped files: %@", contents.description);
                       //retrieve the name of the bundle from the Content-disposition header
                       NSString *contentDisposition = [[res allHeaderFields] valueForKey:@"Content-disposition"];
                       // split the filename
                       NSArray *contentDispositionArray = [contentDisposition componentsSeparatedByString:@"="];
                       NSString *bundleName = [contentDispositionArray lastObject];
                       // NSLog(@"[BUNDLE UPDATER SDK]: bundle name: %@", bundleName);
                       NSData *bundleData = [NSData dataWithContentsOfFile:[destinationFolderPath stringByAppendingPathComponent:bundleName]];
                       // Calculate sha256 hash
                       NSMutableData *hash =
                       [weakSelf calculateSHA256Hash:bundleData];
                       NSString *hashString = [hash base64EncodedStringWithOptions:0];
                       //retrieve the assets files - remove the bundle file
                       NSMutableArray *assetsFiles = [NSMutableArray new];
                       for (NSString *file in contents) {
                           if(![file isEqualToString:bundleName]){
                               [assetsFiles addObject:file];
                           }
                       }
                       //check if bundle data is not empty
                       if(bundleData.length == 0){
                           NSLog(@"[BUNDLE UPDATER SDK]: bundle data is empty");
                           [weakSelf prepareAndHideBottomSheet];
                           return;
                       } 
                       //TODO - __weak typeof(self)weakSelf = self;
                       [weakSelf saveNewBundle:bundleData andHashString:hashString andAssetsFiles:assetsFiles fromFolder:destinationFolderPath];
                       [weakSelf clearDocumentsFolder];
                       [weakSelf reload];
                       // NSLog(@"[SDK] Content of the Documents folder after cleaning %@");
                   } else {
                       NSLog(@"[BUNDLE UPDATER SDK]: Unzipping failed!");
                   }
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
                   NSLog(@"[BUNDLE UPDATER SDK]: An error occurred: %@", errorString);
               }
               // update done or not - dismiss bottomsheet
               [weakSelf prepareAndHideBottomSheet];
           }];
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

// TODO - REACT CATEGORY
// TODO - IMPLEMENT A PANIC FALLBACK

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
