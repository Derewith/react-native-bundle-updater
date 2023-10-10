#import "BundleUpdater.h"
#import "CommonCrypto/CommonDigest.h"
#import <React/RCTBridge.h>
#import <React/RCTBridgeModule.h>

@implementation BundleUpdater
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

NSString *apiUrl = @"http://192.168.1.136";

- (NSMutableData *)calculateSHA256Hash:(NSData *)script {
    NSMutableData *hash =
        [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(script.bytes, (CC_LONG)script.length,
              (unsigned char *)hash.mutableBytes);
    return hash;
}

- (NSString *)loadHashFromDisk {
    NSString *hashPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    NSString *oldHash = [NSString stringWithContentsOfFile:hashPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    return oldHash;
}

- (void)saveNewBundleAndHashToDisk:(NSData *)script
                        hashString:(NSString *)hashString {
    NSString *scriptPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle"];
    [script writeToFile:scriptPath atomically:YES];

    NSString *hashPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    [hashString writeToFile:hashPath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
}

RCT_EXPORT_METHOD(checkAndReplaceBundle : (NSString *)apiKey) {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          // Fetch script from server
          NSString *url =
              [NSString stringWithFormat:@"%@/project/%@/bundle", apiUrl, apiKey];

          NSLog(@"[SDK] Fetching script from %@", url);

          NSURL *scriptURL = [NSURL URLWithString:url];

          NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession]
              downloadTaskWithURL:scriptURL
                completionHandler:^(NSURL *location, NSURLResponse *response,
                                    NSError *error) {
                  if (location) {
                      // The file has been downloaded successfully and is
                      // located at `location`. You can now read it into a
                      // NSData object.
                      NSData *script = [NSData dataWithContentsOfURL:location];
                      // Now you can use the data
                      if (!script) {
                          NSLog(@"[SDK] MISSING SCRIPT DATA FOR URL: %@",
                                script);
                          return;
                      }

                      // Calculate sha256 hash
                      NSMutableData *hash = [self calculateSHA256Hash:script];
                      NSString *hashString =
                          [hash base64EncodedStringWithOptions:0];

                      // Load hash from disk
                      NSString *oldHash = [self loadHashFromDisk];

                      NSLog(@"[SDK] OLDHASH: %@", oldHash);
                      NSLog(@"[SDK] NEWHAS: %@", hashString);

                      if (![hashString isEqualToString:oldHash]) {
                          // If the file has changed, save the new bundle and
                          // hash to disk
                          [self saveNewBundleAndHashToDisk:script
                                                hashString:hashString];
                          NSLog(@"[SDK] SAVED NEW BUNDLE CORRECTLY");
                      } else {
                          NSLog(@"[SDK] BUNDLE IS UP TO DATE");
                      }
                  } else {
                      // An error occurred during the download. Handle it here.
                      NSLog(@"[SDK] An error occurred: %@", error);
                  }
                }];
          [downloadTask resume];
        });
}

RCT_EXPORT_METHOD(reload) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.bridge requestReload];
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
