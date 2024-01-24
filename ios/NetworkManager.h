#import "BundleUpdater.h"

@interface NetworkManager : NSObject

+ (instancetype)sharedManager;

- (void)initializeWithApiKey: (NSString *)apiKey andwithBundle:(NSString *)bundle onBranch:(NSString *) branch  andWithCompletitionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (void)downloadBundleWithiKey: (NSString *)keyToUse withBranch:(NSString *)branch andVersion:(NSString *)version withCompletionHandler: (void (^) (NSURL *location, NSURLResponse *response, NSError *error)) completionHandler;
@end
