#import "BundleUpdaterBottomSheetViewController.h"
#import "BundleUpdaterButton.h"
#import "UIColor+HexString.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BundleUpdater.h"
@implementation BundleUpdaterBottomSheetViewController

- (UIFont *)customFontWithSize:(CGFloat)size {
    return [self customFontWithSize:size weight:UIFontWeightBold];
}

- (UIFont *)customFontWithSize:(CGFloat)size weight:(UIFontWeight)weight {
    UIFont *systemFont = [UIFont systemFontOfSize:size weight:weight];
    UIFont *font;

    if (@available(iOS 13.0, *)) {
        UIFontDescriptor *descriptor = [systemFont.fontDescriptor
            fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
        if (descriptor) {
            font = [UIFont fontWithDescriptor:descriptor size:size];
        } else {
            font = systemFont;
        }
    } else {
        font = systemFont;
    }

    return font;
}

//- (void)visitwebsitebuttonTapped:(UIButton *)sender {
//	return [self visitwebsitebuttonTapped:sender
//url:@"https://www.develondigital.com"];
//}

- (void)visitwebsitebuttonTapped:(UIButton *)sender {
    NSURL *yourURL = [NSURL URLWithString:@"https://www.develondigital.com"];
    if ([[UIApplication sharedApplication] canOpenURL:yourURL]) {
        [[UIApplication sharedApplication] openURL:yourURL
                                           options:@{}
                                 completionHandler:nil];
    }
}

- (void)reloadApp:(UIButton *)sender {
    [[BundleUpdater sharedInstance] reload];
    // hide the modal
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxLabelWidth = screenWidth - 100; // Adjust the padding as needed

    self.view.backgroundColor = [UIColor clearColor];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView setImage:[UIImage imageNamed:@"AppStore"]];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.footerLogoImageView = [[UIImageView alloc] init];
    self.footerLogoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.footerLogoImageView setImage:[UIImage imageNamed:@"logo_dd"]];

    self.button = [[BundleUpdaterButton alloc] init];

    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    self.button.userInteractionEnabled = YES;

    // Create the background view
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = 0;
    [self.view addSubview:self.backgroundView];

    // Create the modal view
    CGFloat modalHeight = self.view.bounds.size.height / 2 - 75;
    CGFloat modalY = self.view.bounds.size.height - modalHeight;

    self.modalView = [[UIView alloc]
        initWithFrame:CGRectMake(0, modalY, self.view.bounds.size.width,
                                 modalHeight)];
    
    self.modalView.backgroundColor = [UIColor whiteColor];
    self.modalView.layer.borderWidth = 0.1f;
    self.modalView.layer.borderColor = [UIColor blackColor].CGColor;
    self.modalView.layer.cornerRadius = 20;


//    UIBezierPath *maskPath = [UIBezierPath
//        bezierPathWithRoundedRect:self.modalView.bounds
//                byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
//                      cornerRadii:CGSizeMake(20.0, 20.0)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.modalView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.modalView.layer.mask = maskLayer;

    [self.view addSubview:self.modalView];

    [self.modalView addSubview:self.imageView];
    [self.modalView addSubview:self.titleLabel];
    [self.modalView addSubview:self.messageLabel];

    // imageView
    if (self.image != nil) {
        NSURL *url = [NSURL URLWithString:self.image];
        [self.imageView sd_setImageWithURL:url
                          placeholderImage:[UIImage imageNamed:@"AppStore"]];
    }

    // titleLabel
    self.titleLabel.text = self.titleText;
    self.titleLabel.font = [self customFontWithSize:20];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0; // Allow multiple lines if needed
    self.titleLabel.lineBreakMode =
        NSLineBreakByWordWrapping; // Wrap the text if it exceeds the width

    [self.titleLabel
        setCenter:CGPointMake(screenWidth / 2, self.titleLabel.center.y)];

    // messageLabel
    self.messageLabel.text = self.message;
    self.messageLabel.textColor = [UIColor systemGrayColor];
    self.messageLabel.font = [self customFontWithSize:16
                                               weight:UIFontWeightRegular];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.numberOfLines = 0; // Allow multiple lines if needed
    self.messageLabel.lineBreakMode =
        NSLineBreakByWordWrapping; // Wrap the text if it exceeds the width

    CGSize messageLabelSize =
        [self.messageLabel sizeThatFits:CGSizeMake(maxLabelWidth, CGFLOAT_MAX)];
    CGRect messageLabelFrame = self.messageLabel.frame;
    messageLabelFrame.size.width = messageLabelSize.width;
    messageLabelFrame.size.height = messageLabelSize.height;
    self.messageLabel.frame = messageLabelFrame;

    [self.messageLabel sizeToFit];
    [self.messageLabel
        setCenter:CGPointMake(screenWidth / 2, self.messageLabel.center.y)];

    // button
    if (self.buttonBackgroundColor != nil) {
        UIColor *newColor =
            [UIColor colorFromHexString:self.buttonBackgroundColor];
        [self.button setButtonColor:newColor];
    }
    // [self.button setTitle:self.buttonLabel forState:UIControlStateNormal];
    // self.button.backgroundColor = ;
    // [self.button setImage:self.buttonIcon forState:UIControlStateNormal];
    NSDictionary *attributes = @{
        NSFontAttributeName : [self customFontWithSize:16],
        NSForegroundColorAttributeName : [UIColor whiteColor]
    };
    NSAttributedString *attributedTitle =
        [[NSAttributedString alloc] initWithString:self.buttonLabel
                                        attributes:attributes];
    [self.button setAttributedTitle:attributedTitle
                           forState:UIControlStateNormal];
    [self.button setCenter:CGPointMake(screenWidth / 2, self.button.center.y)];
    [self.button addTarget:self
                    action:@selector(reloadApp:)
          forControlEvents:UIControlEventTouchUpInside];

    // footerLogo
    if (self.footerLogo != nil) {
        self.footerLogoImageView.image = self.footerLogo;
    }

    [NSLayoutConstraint activateConstraints:@[
        // Position imageView at the top center of the view
        [self.imageView.widthAnchor constraintEqualToConstant:60],
        [self.imageView.heightAnchor constraintEqualToConstant:60],
        [self.imageView.topAnchor
            constraintEqualToAnchor:self.modalView.topAnchor
                           constant:40],
        [self.imageView.centerXAnchor
            constraintEqualToAnchor:self.modalView.centerXAnchor],

        // Position titleLabel below imageView with some spacing
        [self.titleLabel.topAnchor
            constraintEqualToAnchor:self.imageView.bottomAnchor
                           constant:20],
        [self.titleLabel.centerXAnchor
            constraintEqualToAnchor:self.modalView.centerXAnchor],
        [self.titleLabel.widthAnchor constraintEqualToConstant:maxLabelWidth],
        [self.titleLabel.heightAnchor constraintEqualToConstant:30],

        // Position messageLabel below titleLabel with some spacing
        [self.messageLabel.topAnchor
            constraintEqualToAnchor:self.titleLabel.bottomAnchor
                           constant:10],
        [self.messageLabel.centerXAnchor
            constraintEqualToAnchor:self.modalView.centerXAnchor],
        [self.messageLabel.widthAnchor constraintEqualToConstant:maxLabelWidth],
        [self.messageLabel.heightAnchor
            constraintEqualToConstant:messageLabelSize.height],
    ]];

    [self.modalView addSubview:self.button];
    [self.modalView addSubview:self.footerLogoImageView];

    // button
    [self.button.widthAnchor constraintEqualToConstant:184].active = YES;
    [self.button.heightAnchor constraintEqualToConstant:46].active = YES;
    [self.button.centerXAnchor
        constraintEqualToAnchor:self.modalView.centerXAnchor]
        .active = YES;
    self.buttonBottomConstraint = [self.button.bottomAnchor
        constraintEqualToAnchor:self.modalView.bottomAnchor
                       constant:-70];
    self.buttonBottomConstraint.active = YES;

    // footerLogo
    [self.footerLogoImageView.widthAnchor constraintEqualToConstant:172 * 0.5]
        .active = YES;
    [self.footerLogoImageView.heightAnchor constraintEqualToConstant:24 * 0.5]
        .active = YES;
    [self.footerLogoImageView.centerXAnchor
        constraintEqualToAnchor:self.modalView.centerXAnchor]
        .active = YES;
    self.footerLogoBottomConstraint = [self.footerLogoImageView.bottomAnchor
        constraintEqualToAnchor:self.modalView.bottomAnchor
                       constant:-23];
    self.footerLogoBottomConstraint.active = YES;

    // [self.view setNeedsUpdateConstraints];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 0.5;
    }];
}
- (void)updateViewConstraints {
    [super updateViewConstraints];

    //    CGFloat buttonOffset = CGRectGetMaxY(self.modalView.frame) - 60;
    //    CGFloat footerLogoOffset = CGRectGetMaxY(self.modalView.frame) - 40;

    // self.buttonBottomConstraint.constant = 60;
    // self.footerLogoBottomConstraint.constant = 40;
}

@end
