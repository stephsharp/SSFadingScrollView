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

@property (nonatomic) CALayer *maskLayer;
@property (nonatomic) CAGradientLayer *gradientLayer;

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
    self.fadeDuration = 0.3;
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

- (void)layoutSubviews
{
    [super layoutSubviews];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.maskLayer.frame = self.bounds;
    [CATransaction commit];

    if (self.fadeTop) {
        if (self.contentOffset.y <= 0 && ![self topFadeIsHidden]) {
            NSArray *colours = [self colorsArrayByReplacingFirstObjectWithColor:[SSFadingScrollView opaqueColor]];

            // Fade out top gradient
            [self animateGradientColours:colours];
        }
        else if (self.contentOffset.y > 0 && [self topFadeIsHidden]) {
             NSArray *colours = [self colorsArrayByReplacingFirstObjectWithColor:[SSFadingScrollView transparentColor]];

            // Fade in top gradient
            [self animateGradientColours:colours];
        }
    }
    else if (self.fadeBottom) {
        // TODO: don't fade bottom of scrollview if contentOffset.y >= contentSize.height - bounds.size.height
    }
}

- (BOOL)topFadeIsHidden
{
    CGColorRef firstColor = (__bridge CGColorRef)self.gradientLayer.colors.firstObject;
    return CGColorEqualToColor(firstColor, [SSFadingScrollView opaqueColor]);
}

- (NSArray *)colorsArrayByReplacingFirstObjectWithColor:(CGColorRef)color
{
    NSMutableArray *mutableColours = [self.gradientLayer.colors mutableCopy];
    mutableColours[0] = (__bridge id)color;

    return [mutableColours copy];
}

- (void)animateGradientColours:(NSArray *)colours
{
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    animation.fromValue = ((CAGradientLayer *)self.gradientLayer.presentationLayer).colors;
    animation.toValue = colours;
    // TODO: duration = total duration * percentage of total colour to fade
    animation.duration = self.fadeDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradientLayer.colors = colours; // update the model value
    [CATransaction commit];

    [self.gradientLayer addAnimation:animation forKey:@"animateGradient"];
}

#pragma mark - Properties

- (CALayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [self setupMaskLayer];
    }
    return _maskLayer;
}

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

- (CALayer *)setupMaskLayer
{
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;

    self.gradientLayer = [self setupGradientLayer];
    [maskLayer addSublayer:self.gradientLayer];

    if (self.maskScrollBar) {
        [maskLayer addSublayer:[self scrollBarMaskLayer]];
    }

    self.layer.mask = maskLayer;

    return maskLayer;
}

- (CAGradientLayer *)setupGradientLayer
{
    id transparent = (id)[SSFadingScrollView transparentColor];
    id opaque = (id)[SSFadingScrollView opaqueColor];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect frame = self.bounds;
    frame.origin.y = 0;
    gradientLayer.frame = frame;

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

    scrollGutterLayer.backgroundColor = [SSFadingScrollView opaqueColor];

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

+ (CGColorRef)opaqueColor
{
    return [UIColor blackColor].CGColor;
}

+ (CGColorRef)transparentColor
{
    return [UIColor clearColor].CGColor;
}

@end
