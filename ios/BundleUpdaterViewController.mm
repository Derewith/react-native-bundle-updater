#import "BundleUpdaterViewController.h"
#import "BundleUpdaterButton.h"
#import "UIColor+HexString.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BundleUpdater.h"

#define MAX_MESSAGE_HEIGHT 115

@implementation BundleUpdaterViewController{
    CGFloat modalHeight;
    CGFloat modalY;
    CGFloat modalPadding;
}

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
    dispatch_async(dispatch_get_main_queue(), ^{
        // TODO - understand if the view must be shown ony while bundle is reloading
        // or even when the app is checking for bundle to update and the user needs to press the button
        [self.spinner startAnimating];
        self.loadingView.alpha = 1;
    });
    [[BundleUpdater sharedInstance] checkAndReplaceBundle:nil];
}

- (void)hideBottomSheet {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)hideBottomsheetTimer:(NSTimer *)timer{
    id duration = [timer userInfo];
    if(duration){
        NSLog(@"test %@",duration);
        [self hideBottomSheetAnimated:[duration floatValue]];
    }
}

-(void)hideBottomSheetAnimated {
    [self hideBottomSheetAnimated:0.2];
}

-(void)hideBottomSheetAnimated:(float)timing {
    [UIView animateWithDuration:timing animations:^{
        self.backgroundView.alpha = 0;
    }];
    [NSTimer scheduledTimerWithTimeInterval:timing
            target:self
            selector:@selector(hideBottomSheet)
            userInfo:nil
            repeats:NO];
}


- (void)handleTapBG:(UITapGestureRecognizer *)gesture {
    [self hideBottomSheetAnimated];
}

-(void)handleSwipe:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [recognizer translationInView:self.view];
        CGRect frame = self.modalView.frame;
        if(translation.y > 0){
            // swipe down
            frame.origin.y += translation.y;
            self.modalView.frame = frame;
            [recognizer setTranslation:CGPointZero inView:self.modalView];
           // [self hideBottomSheetAnimated];
        }else{
            //swipe up
            //give the illusion that he can swipe up - swipe up a little bit and then back down
            CGFloat maxTranslation = frame.origin.y;
            //if it's already at the top, don't move it
            if(frame.origin.y > self->modalY - 8){
                maxTranslation += translation.y;
            }
            //if the translation is more than the modal height, move untill the modalY
            CGFloat upperLimit = self->modalY - 8;
            maxTranslation = MAX(maxTranslation, upperLimit);
            frame.origin.y = maxTranslation;
            self.modalView.frame = frame;
            [recognizer setTranslation:CGPointZero inView:self.modalView];
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"ended");
        if(self.modalView.frame.origin.y > self->modalY + 130){
            //bring it down
            CGRect frame = self.modalView.frame;
            frame.origin.y = self.view.bounds.size.height;
            [UIView animateWithDuration:0.2 animations:^{
                self.modalView.frame = frame;
            }completion:^(BOOL finished) {
                if(finished){
                    [self hideBottomSheetAnimated:0.3];
                }
            }];
        }
        else{
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.modalView.frame;
                frame.origin.y = self->modalY;
                self.modalView.frame = frame;
            }];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxLabelWidth = screenWidth - 80; // Adjust the padding as needed

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

    //create the loading view
    self.loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.loadingView.backgroundColor = [UIColor whiteColor];
    self.loadingView.alpha = 0;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.loadingView.center;
    [self.loadingView addSubview:self.spinner];
    
    [self.view addSubview: self.loadingView];
    // Create the background view
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = 0;
    //recognize touch
    if(!self.isNecessaryUpdate){
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBG:)];
        self.backgroundView.userInteractionEnabled = YES;
        [self.backgroundView addGestureRecognizer:tapGesture];
    }
    [self.view addSubview:self.backgroundView];
    
    // Create the modal view
    modalPadding = 25;
    float paddingH = 48;
    if(self.isModal){
        modalHeight = self.view.bounds.size.height / 2 - 130 + modalPadding;
    }else{
        modalHeight = self.view.bounds.size.height / 2 - 75 + modalPadding;
    }
    if(self.isModal){
        modalY = (self.view.bounds.size.height / 2) - (modalHeight / 2);
    }else{
        modalY = self.view.bounds.size.height - modalHeight + modalPadding;
    }
    CGFloat modalWidth = self.isModal ? self.view.bounds.size.width - paddingH : self.view.bounds.size.width;
    CGFloat modalX = self.isModal ? paddingH / 2 : 0;
    
    self.modalView = [[UIView alloc]
        initWithFrame:CGRectMake(modalX, modalY, modalWidth,
                                 modalHeight)];
    
    self.modalView.backgroundColor = [UIColor whiteColor];
    self.modalView.layer.borderWidth = 0.1f;
    self.modalView.layer.borderColor = [UIColor blackColor].CGColor;
    self.modalView.layer.cornerRadius = 20;

    //Swipe recognizer
    if(!self.isNecessaryUpdate){
        UIPanGestureRecognizer *swipeRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        self.modalView.userInteractionEnabled = YES;
        [self.modalView addGestureRecognizer:swipeRec];
    }
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
                           constant:0],
        [self.messageLabel.centerXAnchor
            constraintEqualToAnchor:self.modalView.centerXAnchor],
        [self.messageLabel.widthAnchor constraintEqualToConstant:maxLabelWidth],
        [self.messageLabel.heightAnchor
            constraintEqualToConstant:self.isModal ? MAX_MESSAGE_HEIGHT - 20 : MAX_MESSAGE_HEIGHT],
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
        constraintEqualToAnchor:self.footerLogoImageView.topAnchor
                       constant: -12];
   // [self.button.topAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:16].active = YES;
    self.buttonBottomConstraint.active = YES;

    // footerLogo
    [self.footerLogoImageView.widthAnchor constraintEqualToConstant:172 * 0.5]
        .active = YES;
    [self.footerLogoImageView.heightAnchor constraintEqualToConstant:24 * 0.5]
        .active = YES;
    [self.footerLogoImageView.centerXAnchor
        constraintEqualToAnchor:self.modalView.centerXAnchor]
        .active = YES;
    
    CGFloat bottomPadding = 22;
    if(!self.isModal){
        if(@available(iOS 11.0, *)){
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            bottomPadding = window.safeAreaInsets.bottom;
        }
        bottomPadding+=16;
    }
    self.footerLogoBottomConstraint = [self.footerLogoImageView.bottomAnchor
        constraintEqualToAnchor:self.modalView.bottomAnchor
                       constant:-bottomPadding];
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
}

@end
