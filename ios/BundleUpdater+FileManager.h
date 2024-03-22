#import "BundleUpdater.h"

@interface BundleUpdater (FileManager)

- (void)copyFilesFromSource:(NSString *)sourceFolder toDestination:(NSString *)destinationFolder;
- (void)clearDocumentsFolder;
- (NSMutableData *)calculateSHA256Hash:(NSData *)script;
- (NSString *)loadHashFromDisk;
- (NSString *)unzipBundleAndAssetsInto: (NSURL *) location withSuccess:(BOOL *)success;

@end
