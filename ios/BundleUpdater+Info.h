#import "BundleUpdater.h"
#import <sys/utsname.h>

@interface BundleUpdater (Info)
- (NSString *)getDeviceModelName;
- (NSDictionary *)getMetaData;
@end
