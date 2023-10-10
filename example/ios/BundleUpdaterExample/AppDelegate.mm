#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.moduleName = @"BundleUpdaterExample";
    // You can add your custom initial props in the dictionary below.
    // They will be passed down to the ViewController used by React Native.
    self.initialProps = @{};

    return [super application:application
        didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
//#if DEBUG
//  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
//#else
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
//#endif
}

@end
