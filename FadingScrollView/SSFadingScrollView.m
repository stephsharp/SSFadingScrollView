//
//  FadingScrollView.m
//  Created by Stephanie Sharp on 1/06/13.
//

#import "SSFadingScrollView.h"
#import <QuartzCore/QuartzCore.h>

// TODO: check scrollbar width is still the same on iOS 7+ as it was on iOS 6
static CGFloat const kDefaultScrollBarWidth = 7.0f;
static CGFloat const kDefaultFadeHeight = 30.0f;

typedef NS_ENUM(NSUInteger, FadeType) {
    FadeTypePercentage,
    FadeTypeHeight
};

@interface SSFadingScrollView ()

@property (nonatomic) FadeType fadeType;
@property (nonatomic) FadeEdges fadeEdges;
@property (nonatomic) CGFloat topFadePercentage;
@property (nonatomic) CGFloat bottomFadePercentage;

@end

@implementation SSFadingScrollView

#pragma mark - Initializers

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage edges:(FadeEdges)fadeEdges
{
    self = [super init];
    if (self) {
        self.fadeType = FadeTypePercentage;
        self.fadeEdges = fadeEdges;

        switch (fadeEdges) {
            case FadeTopAndBottom:
                [self fadeTopWithPercentage:fadePercentage];
                [self fadeBottomWithPercentage:fadePercentage];
                break;
            case FadeTop:
                [self fadeTopWithPercentage:fadePercentage];
                self.fadeBottom = NO;
                break;
            case FadeBottom:
                [self fadeBottomWithPercentage:fadePercentage];
                self.fadeTop = NO;
                break;
            default:
                break;
        }
    }
    return self;
}

- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage
{
    return [self initWithFadePercentage:fadePercentage edges:FadeTopAndBottom];
}

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges
{
    return [self initWithFadePercentage:[self percentageForHeight:fadeHeight] edges:fadeEdges];
}

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight
{
    return [self initWithFadeHeight:fadeHeight edges:FadeTopAndBottom];
}

- (instancetype)init
{
    return [self initWithFadeHeight:kDefaultFadeHeight];
}

#pragma mark Initializer helpers

- (void)setDefaults
{
    self.fadeType = FadeTypeHeight;
    self.fadeTop = YES;
    self.fadeBottom = YES;
    self.topFadePercentage = [self percentageForHeight:kDefaultFadeHeight];
    self.bottomFadePercentage = [self percentageForHeight:kDefaultFadeHeight];
    self.maskScrollBar = NO;
}

- (void)fadeTopWithPercentage:(CGFloat)percentage
{
    self.fadeTop = YES;
    self.topFadePercentage = percentage;
}

- (void)fadeBottomWithPercentage:(CGFloat)percentage
{
    self.fadeBottom = YES;
    self.bottomFadePercentage = percentage;
}

#pragma mark - Layout

// TODO: dont fade top if content offset is at top (and same for bottom edge)

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.mask = [self maskLayer];
}

#pragma mark - Properties

- (void)setFadeHeight:(CGFloat)fadeHeight
{
    self.topFadePercentage = [self percentageForHeight:fadeHeight];
    self.bottomFadePercentage = [self percentageForHeight:fadeHeight];
}

- (void)setBounds:(CGRect)bounds
{
    // TODO: Refactor this to use percentage change between self.bounds and bounds?
    if (self.fadeType == FadeTypeHeight) {
        CGFloat topHeight = [self heightForPercentage:self.topFadePercentage];
        CGFloat bottomHeight = [self heightForPercentage:self.bottomFadePercentage];

        [super setBounds:bounds];

        self.topFadePercentage = [self percentageForHeight:topHeight];
        self.bottomFadePercentage = [self percentageForHeight:bottomHeight];
    }
    else {
        [super setBounds:bounds];
    }
}

#pragma mark - Gradient mask

- (CALayer *)maskLayer
{
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;

    [maskLayer addSublayer:[self gradientMaskLayer]];

    if (self.maskScrollBar) {
        [maskLayer addSublayer:[self scrollBarMaskLayer]];
    }

    return maskLayer;
}

- (CALayer *)gradientMaskLayer
{
    id transparent = (id)[self transparent];
    id opaque = (id)[self opaque];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(self.bounds.origin.x, 0,
                                     self.bounds.size.width, self.bounds.size.height);

    NSArray *gradientColors = [NSArray new];
    NSArray *gradientLocations = [NSArray new];

    if (self.fadeTop) {
        gradientColors = @[transparent, opaque];
        gradientLocations = @[@(0), @(self.topFadePercentage)];
    }
    if (self.fadeBottom) {
        gradientColors = [gradientColors arrayByAddingObjectsFromArray:@[opaque, transparent]];
        gradientLocations = [gradientLocations arrayByAddingObjectsFromArray:@[@(1.0f - self.bottomFadePercentage), @(1)]];
    }

    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);

    return gradientLayer;
}

- (CALayer *)scrollBarMaskLayer
{
    CALayer *scrollGutterLayer = [CALayer layer];
    scrollGutterLayer.frame = CGRectMake(self.bounds.size.width - kDefaultScrollBarWidth, 0,
                                         kDefaultScrollBarWidth, self.bounds.size.height);

    scrollGutterLayer.backgroundColor = [self opaque];

    return scrollGutterLayer;
}

- (CGFloat)percentageForHeight:(CGFloat)height
{
    CGFloat scrollViewHeight = CGRectGetHeight(self.bounds);
    return (scrollViewHeight > 0) ? (height / scrollViewHeight) : 0;
}

- (CGFloat)heightForPercentage:(CGFloat)percentage
{
    return CGRectGetHeight(self.bounds) * percentage;
}

#pragma mark Mask colors

- (CGColorRef)opaque
{
    return [UIColor colorWithWhite:0 alpha:1].CGColor;
}

- (CGColorRef)transparent
{
    return [UIColor colorWithWhite:0 alpha:0].CGColor;
}

@end
