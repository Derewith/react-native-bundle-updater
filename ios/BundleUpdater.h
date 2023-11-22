#ifdef RCT_NEW_ARCH_ENABLED
    #import "RNBundleUpdaterSpec.h"
    @interface BundleUpdater : NSObject <NativeBundleUpdaterSpec>
#else
    #import <React/RCTBridgeModule.h>
    #import <Foundation/Foundation.h>
    @interface BundleUpdater : NSObject <RCTBridgeModule, UIViewControllerTransitioningDelegate>
    @property (nonatomic, weak) RCTBridge *bridge;

    + (instancetype)sharedInstance;
    - (void)initialization:(NSString *)apiKey
                resolve:(void (^)(NSString *))resolve
                    reject:(void (^)(NSString *, NSString *, NSError *))reject;
    - (NSURL *)initializeBundle:(RCTBridge *)bridge withKey:(NSString *)key;
    - (void)reload;
    - (void)checkAndReplaceBundle: (nullable NSString *)apiKey;
#endif

@end
