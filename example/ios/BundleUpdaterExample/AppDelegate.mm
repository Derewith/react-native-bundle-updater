#import "AppDelegate.h"
#import "BundleUpdater.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.moduleName = @"BundleUpdaterExample";
    // You can add your custom initial props in the dictionary below.
    // They will be passed down to the ViewController used by React Native.
    self.initialProps = @{};

    BundleUpdater *bundleUpdater = [BundleUpdater sharedInstance];
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
  BundleUpdater *bundleUpdater = [BundleUpdater sharedInstance];
  return [bundleUpdater initializeBundle:bridge withKey:@"9980a7943e0db5892b50f6972b02b4c2a2b3"];
}

@end
