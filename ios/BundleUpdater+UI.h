
#import "BundleUpdater.h"

@interface BundleUpdater (UI)
- (void)showUpdateVC:(NSDictionary *)updateData withNecessaryUpdate:(BOOL)isNecessaryUpdate;
- (void)prepareAndHideBottomSheet;
@end
