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
    [bundleUpdater initialization:@"6e776f467b0744d19e62172c59c79efb" withBranch: @"staging"];

    return [super application:application
        didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  BundleUpdater *bundleUpdater = [BundleUpdater sharedInstance];
  return [bundleUpdater initializeBundle:bridge withKey:@"6e776f467b0744d19e62172c59c79efb"];
}


@end
