#import "BundleUpdater+FileManager.h"
#import "CommonCrypto/CommonDigest.h"

@implementation BundleUpdater (FileManager)

/*!
 *  @brief Copy files from source to destination recursively
 *
 *  @param sourceFolder      Source folder
 *  @param destinationFolder Destination folder
 */
- (void)copyFilesFromSource:(NSString *)sourceFolder toDestination:(NSString *)destinationFolder {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [manager contentsOfDirectoryAtPath:sourceFolder error:&error];

    if (error) {
        NSLog(@"[BUNDLE UPDATER SDK]: Error reading contents of directory %@: %@", sourceFolder, [error localizedDescription]);
        return;
    }

    for (NSString *file in contents) {
        NSString *sourceFilePath = [sourceFolder stringByAppendingPathComponent:file];
        NSString *destinationFilePath = [destinationFolder stringByAppendingPathComponent:file];

        BOOL isDir;
        BOOL fileExistsAtPath = [manager fileExistsAtPath:sourceFilePath isDirectory:&isDir];

        if (fileExistsAtPath) {
            if (isDir) {
                // It's a directory, create it in the destination
                [manager createDirectoryAtPath:destinationFilePath withIntermediateDirectories:YES attributes:nil error:nil];

                // Recursively copy the contents of the subdirectory
                [self copyFilesFromSource:sourceFilePath toDestination:[destinationFolder stringByAppendingPathComponent:file]];
            } else {
                //NSLog(@"Copying to the destination: %@", destinationFilePath);
                // It's a file, copy it to the destination
                NSData *fileData = [NSData dataWithContentsOfFile:sourceFilePath];
                [fileData writeToFile:destinationFilePath atomically:YES];
            }
        }
    }
    //Log the content of the destination folder
    NSLog(@"[BUNDLE UPDATER SDK]: content of the %@ folder %@", sourceFolder, [manager contentsOfDirectoryAtPath:destinationFolder error:nil]);
}

/*!
 * @brief clear the documents folder from files that are not intended to be there
 */
- (void)clearDocumentsFolder{
    //TODO - custom method and custom class to interact with the documents folder
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSArray *documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirs.firstObject error:nil];
    NSString *documentPath = dirs.firstObject;
    NSFileManager *defManager = [NSFileManager defaultManager];
    for (NSString *document in documents){
        if([document isEqualToString:@"unzipped"] || [document isEqualToString:@"bundle.zip"]){
            NSString *pathToDoc = [documentPath stringByAppendingPathComponent:document];
            NSError *errorRemoving;
            [defManager removeItemAtPath:pathToDoc error:&errorRemoving];
            if(errorRemoving){
                // TODO - understand what to do in this case
                NSLog(@"[BUNDLE UPDATER ]: Error removing doc %@", document);
            }
        }
    }
}

/*!
 *  @brief get the hash of a file
 *
 *  @param script - data of the bundle
 * *
 *  @return a data hash
 */
- (NSMutableData *)calculateSHA256Hash:(NSData *)script {
    NSMutableData *hash =
        [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(script.bytes, (CC_LONG)script.length,
              (unsigned char *)hash.mutableBytes);
    return hash;
}

/*!
 *  @brief load the saved hash of the file from  disk
 *
 *  @return a string hash of the file
 */
- (NSString *)loadHashFromDisk {
    NSString *hashPath = [[NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
        stringByAppendingPathComponent:@"main.jsbundle.sha256"];
    NSString *oldHash = [NSString stringWithContentsOfFile:hashPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    return oldHash;
}



@end
