
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNBundleUpdaterSpec.h"

@interface BundleUpdater : NSObject <NativeBundleUpdaterSpec>
#else
#import <React/RCTBridgeModule.h>

@interface BundleUpdater : NSObject <RCTBridgeModule>
@property (nonatomic, weak) RCTBridge *bridge;
#endif

@end
