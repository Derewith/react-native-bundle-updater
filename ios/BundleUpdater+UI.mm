#import "BundleUpdater+UI.h"
#import "BundleUpdaterNitificationVC.h"

@implementation BundleUpdater (UI)

/*!
 *  @brief show the update bottomsheet if the config are supplied
 *
 *  @param updateData - dictionary with the sheet config
 */
- (void)showUpdateVC:(NSDictionary *)updateData withNecessaryUpdate:(BOOL)isNecessaryUpdate{
    NSDictionary *config = updateData[@"configuration"];
    NSDictionary *actionBtn = updateData[@"actionBtn"];
    // Set the data properties of the bottom sheet view controller
    self.updaterVC.image = config[@"image"];
    self.updaterVC.titleText = config[@"title"];
    self.updaterVC.message = config[@"message"];
    self.updaterVC.buttonLabel = actionBtn[@"label"];
    self.updaterVC.buttonLink = actionBtn[@"label"];
    self.updaterVC.buttonBackgroundColor = actionBtn[@"color"];
    self.updaterVC.buttonIcon = [UIImage imageNamed:@"button_icon"];
    self.updaterVC.footerLogo = [UIImage imageNamed:@"sdk_logo"];
    if(isNecessaryUpdate){
        self.updaterVC.isNecessaryUpdate = true;
    }
    NSString *type = config[@"type"];
    if([type isEqualToString:@"notification"]){
        //TODO - pass config to the notification
        BundleUpdaterNitificationVC *notificationVC = [BundleUpdaterNitificationVC new];
        notificationVC.isNecessaryUpdate = isNecessaryUpdate;
        if([notificationVC isKindOfClass:[UIViewController class]]){
            UIViewController *_notificationVC = (UIViewController *)notificationVC;
            _notificationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            // present the new viewContoller
            dispatch_async(dispatch_get_main_queue(), ^{
               UIWindow *window = [[UIApplication sharedApplication] keyWindow];
               UIViewController *rootViewController = window.rootViewController;
               [rootViewController presentViewController:_notificationVC animated:NO completion:nil];
            });
            return;
        }else{
           NSLog(@"[BUNDLE UPDATER SDK]: It's NOT an UIViewController, display normal bottomsheet");
        }
    }else if([type isEqualToString:@"modal"]){
        self.updaterVC.isModal = true;
    }
    UIViewController *rootViewController =
        [[[UIApplication sharedApplication] keyWindow] rootViewController];
    self.updaterVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.updaterVC.transitioningDelegate = self; // TODO 
    [rootViewController presentViewController:self.updaterVC
                                     animated:YES
                                   completion:nil];
}

/*!
 *  @brief prepare the updaterVC before hiding the
 */
- (void)prepareAndHideBottomSheet {
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO - weak self
        [UIView animateWithDuration:0.2 animations:^{
            self.updaterVC.loadingView.alpha = 0;
            self.updaterVC.backgroundView.alpha = 0;
        }];
        [self.updaterVC.spinner stopAnimating];
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(hideBottomSheet)
                                       userInfo:nil
                                        repeats:NO];
    });
}

/*!
 *  @brief hide the bottomsheet*
 */
- (void)hideBottomSheet {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.updaterVC dismissViewControllerAnimated:YES completion:nil];
    });
}


@end
