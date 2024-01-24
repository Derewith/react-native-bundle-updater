#import "NetworkManager.h"
#import "BundleUpdater+Info.h"

@implementation NetworkManager

+ (instancetype)sharedManager {
    static NetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] init];
        });
    return sharedInstance;
}


//return the completion handler
-(void)initializeWithApiKey: (NSString *)apiKey andwithBundle:(NSString *)bundle onBranch:(NSString *) branch  andWithCompletitionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    NSString *urlString =
        [NSString stringWithFormat:@"%@/project/%@/initialize", [BundleUpdater API_URL], apiKey];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    //Version is taken by the info.plist eg. 1.0.0
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSDictionary *body = [[NSMutableDictionary alloc]
        initWithDictionary:@{
            @"metaData" : [[BundleUpdater sharedInstance] getMetaData],
            @"bundleId" : bundle ? bundle : @"",
            @"version": appVersionString,
            @"branch": branch
        }];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                       options:0
                                                         error:&jsonError];
    if (!jsonData) {
        NSLog(@"[BUNDLE UPDATER SDK]: JSON serialization error: %@", jsonError);
        return;
    }
    // Set the request body with the JSON data
    // NSLog(@"[SDK] init json %@", body.description);
    [request setHTTPBody:jsonData];
    // Set the appropriate headers for JSON
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // Create the session configuration and session
    NSURLSessionConfiguration *sessionConfiguration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:sessionConfiguration];
    // Create the task to send the request
    NSURLSessionDataTask *dataTask = [session
        dataTaskWithRequest:request
          completionHandler:completionHandler];
    [dataTask resume];
}

- (void)downloadBundleWithiKey: (NSString *)keyToUse withBranch:(NSString *)branch andVersion:(NSString *)version withCompletionHandler: (void (^) (NSURL *location, NSURLResponse *response, NSError *error)) completionHandler {
    NSDictionary *body = @{
        @"version": version,
        @"branch": branch
    };
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                       options:0
                                                         error:&jsonError];
    if (!jsonData) {
        NSLog(@"[BUNDLE UPDATER SDK]: JSON serialization error: %@", jsonError);
        return;
    }
    // Fetch script from server
    NSString *url = [NSString
        stringWithFormat:@"%@/project/%@/bundle", [BundleUpdater API_URL], keyToUse];
    NSLog(@"[BUNDLE UPDATER SDK]: Fetching script from %@", url);
    NSURL *scriptURL = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
      [request setURL:scriptURL];
      [request setHTTPMethod:@"POST"];
      [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
      [request setHTTPBody:jsonData];
      NSURLSession *session = [NSURLSession sharedSession];
      NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:completionHandler];
    [downloadTask resume];
}
@end
