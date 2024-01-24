#ifdef RCT_NEW_ARCH_ENABLED
    #import "RNBundleUpdaterSpec.h"
    @interface BundleUpdater : NSObject <NativeBundleUpdaterSpec>
#else
    #import <React/RCTBridgeModule.h>
    #import <Foundation/Foundation.h>
    #import "BundleUpdaterViewController.h"
    
NS_ASSUME_NONNULL_BEGIN
    @interface BundleUpdater : NSObject <RCTBridgeModule, UIViewControllerTransitioningDelegate>
    // managed on Categories
    @property (class, nonatomic, readonly) NSString *API_URL;
    @property (nonatomic, strong) BundleUpdaterViewController *updaterVC;
    // public methods
    + (instancetype)sharedInstance;
    - (void)initialization:(NSString *)apiKey
                withBranch:(NSString *)branch
                resolve:(void (^)(NSString *))resolve
                    reject:(void (^)(NSString *, NSString *, NSError *))reject;
    - (NSURL *)initializeBundle:(RCTBridge *)bridge withKey:(NSString *)key;
    - (void)reload;
    - (void)checkAndReplaceBundle: (nullable NSString *)apiKey;
NS_ASSUME_NONNULL_END

#endif

@end
