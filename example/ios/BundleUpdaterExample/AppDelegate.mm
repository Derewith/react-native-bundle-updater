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
    [bundleUpdater initialization:@"70df8a199213d53d892a3eddb6f3bf9c4158"
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
  return [bundleUpdater initializeBundle:bridge withKey:@"70df8a199213d53d892a3eddb6f3bf9c4158"];
}

@end
