#import "BundleUpdater.h"
#import "CommonCrypto/CommonDigest.h"
#import <React/RCTBridgeModule.h>

@implementation BundleUpdater
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(checkAndReplaceBundle : (NSString *)url) {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          NSURL *scriptURL = [NSURL URLWithString:url];
          NSData *script = [NSData dataWithContentsOfURL:scriptURL];
          if (!script) {
              return;
          }
          // Calculate sha256 hash
          NSMutableData *hash =
              [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
          CC_SHA256(script.bytes, (CC_LONG)script.length, hash.mutableBytes);
          NSString *hashString = [hash base64EncodedStringWithOptions:0];

          // Load hash from disk
          NSString *hashPath = [[NSSearchPathForDirectoriesInDomains(
              NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
              stringByAppendingPathComponent:@"main.jsbundle.sha256"];
          NSString *oldHash =
              [NSString stringWithContentsOfFile:hashPath
                                        encoding:NSUTF8StringEncoding
                                           error:nil];

          if (![hashString isEqualToString:oldHash]) {
              // If the file has changed, save the new bundle and hash to disk
              NSString *scriptPath = [[NSSearchPathForDirectoriesInDomains(
                  NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                  stringByAppendingPathComponent:@"main.jsbundle"];
              [script writeToFile:scriptPath atomically:YES];
              [hashString writeToFile:hashPath
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:nil];
          }
        });
}

RCT_EXPORT_METHOD(reload) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    [controller dismissViewControllerAnimated:YES completion:nil];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:@"yourInitialControllerId"];
    [UIApplication sharedApplication].keyWindow.rootViewController = initViewController;
  });
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeBundleUpdaterSpecJSI>(
        params);
}
#endif

@end
