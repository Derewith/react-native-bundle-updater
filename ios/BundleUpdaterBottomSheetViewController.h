#import <UIKit/UIKit.h>
#import "BundleUpdaterButton.h"

@interface BundleUpdaterBottomSheetViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *buttonLabel;
@property (nonatomic, strong) NSString *buttonLink;
@property (nonatomic, strong) NSString *buttonBackgroundColor;
@property (nonatomic, strong) UIImage *buttonIcon; // TODO verify
@property (nonatomic, strong) UIImage *footerLogo;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) BundleUpdaterButton *button;
@property (nonatomic, strong) UIImageView *footerLogoImageView;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *modalView;

@property (nonatomic, strong) NSLayoutConstraint *buttonBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *footerLogoBottomConstraint;

@property (nonatomic) BOOL isNecessaryUpdate;

@end
