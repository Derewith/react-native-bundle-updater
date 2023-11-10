#import "AppDelegate.h"
#import "BundleUpdater.h"

#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.moduleName = @"BundleUpdaterExample";
    // You can add your custom initial props in the dictionary below.
    // They will be passed down to the ViewController used by React Native.
    self.initialProps = @{};

    BundleUpdater *bundleUpdater = [[BundleUpdater alloc] init];
    [bundleUpdater initialization:@"9980a7943e0db5892b50f6972b02b4c2a2b3"
        resolve:^(NSString *result) {
          NSLog(@"[APP]Initialization success: %@", result);
        }
        reject:^(NSString *code, NSString *message, NSError *error) {
          NSLog(@"[APP]Initialization error: %@", error);
        }];

    return [super application:application
        didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#if DEBUG
    return [[RCTBundleURLProvider sharedSettings]
        jsBundleURLForBundleRoot:@"index"];
#else
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

@end
