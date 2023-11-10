#import "BundleUpdaterButton.h"

@implementation BundleUpdaterButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // self.translatesAutoresizingMaskIntoConstraints = NO;
        // Auto layout, variables, and unit scale are not yet supported
        self.frame = CGRectMake(0, 0, 184, 46);

        UIView *shadows = [[UIView alloc] initWithFrame:self.bounds];
        shadows.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shadows.clipsToBounds = NO;
        shadows.userInteractionEnabled = NO;
        [self addSubview:shadows];

        UIBezierPath *shadowPath0 =
            [UIBezierPath bezierPathWithRoundedRect:shadows.bounds
                                       cornerRadius:16];
        CALayer *layer0 = [CALayer layer];
        layer0.shadowPath = shadowPath0.CGPath;
        layer0.shadowColor = [UIColor colorWithRed:0.094
                                             green:0.153
                                              blue:0.294
                                             alpha:0.1]
                                 .CGColor;
        layer0.shadowOpacity = 1;
        layer0.shadowRadius = 6;
        layer0.shadowOffset = CGSizeMake(0, 4);
        layer0.bounds = shadows.bounds;
        layer0.position = shadows.center;
        [shadows.layer addSublayer:layer0];

        UIView *shapes = [[UIView alloc] initWithFrame:self.bounds];
        shapes.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shapes.clipsToBounds = YES;
        shapes.userInteractionEnabled = NO;

        [self addSubview:shapes];

        self.layer1 = [CALayer layer];
        self.layer1.backgroundColor =
            [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1].CGColor;
        self.layer1.bounds = shapes.bounds;
        self.layer1.position = shapes.center;
        [shapes.layer addSublayer:self.layer1];

        CAGradientLayer *layer2 = [CAGradientLayer layer];
        layer2.colors = @[
            (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor,
            (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor
        ];
        layer2.locations = @[ @(0), @(1) ];
        layer2.startPoint = CGPointMake(0.25, 0.5);
        layer2.endPoint = CGPointMake(0.75, 0.5);
        layer2.transform = CATransform3DMakeAffineTransform(
            CGAffineTransformMake(0, 1, -1, 0, 1, 0));
        layer2.bounds = CGRectInset(shapes.bounds, 2 * shapes.bounds.size.width,
                                    2 * shapes.bounds.size.height);
        layer2.position = shapes.center;
        [shapes.layer addSublayer:layer2];

        shapes.layer.cornerRadius = 16;
        shapes.layer.borderWidth = 0.5;
        shapes.layer.borderColor =
            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05].CGColor;
    }
    return self;
}

- (void)setButtonColor:(UIColor *)color {
    self.layer1.backgroundColor = color.CGColor;
}

@end
