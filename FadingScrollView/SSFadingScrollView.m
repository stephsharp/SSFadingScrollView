//
//  FadingScrollView.m
//  Created by Stephanie Sharp on 1/06/13.
//

#import "SSFadingScrollView.h"
#import <QuartzCore/QuartzCore.h>

// TODO: check scrollbar width is still the same on iOS 7+ as it was on iOS 6
static CGFloat const SSDefaultScrollBarWidth = 7.0f;
static CGFloat const SSDefaultFadeHeight = 30.0f;

@interface SSFadingScrollView ()

@property (nonatomic) FadeType fadeType;
@property (nonatomic) CGFloat fadePercentage;
@property (nonatomic) CALayer *maskLayer;
@property (nonatomic) CAGradientLayer *gradientLayer;
@property (nonatomic) BOOL topGradientIsHidden;
@property (nonatomic) BOOL bottomGradientIsHidden;

@end

@implementation SSFadingScrollView

#pragma mark - Initializers

- (instancetype)initWithFadeType:(FadeType)fadeType percentage:(CGFloat)fadePercentage edges:(FadeEdges)fadeEdges
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.fadeType = fadeType;
        self.fadePercentage = fadePercentage;

        switch (fadeEdges) {
            case FadeEdgesTopAndBottom:
                self.fadeTop = YES;
                self.fadeBottom = YES;
                break;
            case FadeEdgesTop:
                self.fadeTop = YES;
                self.fadeBottom = NO;
                break;
            case FadeEdgesBottom:
                self.fadeTop = NO;
                self.fadeBottom = YES;
                break;
            default:
                break;
        }
    }
    return self;
}

- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage edges:(FadeEdges)fadeEdges
{
    return [self initWithFadeType:FadeTypePercentage percentage:fadePercentage edges:fadeEdges];
}

- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage
{
    return [self initWithFadePercentage:fadePercentage edges:FadeEdgesTopAndBottom];
}

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges
{
    return [self initWithFadeType:FadeTypeHeight
                       percentage:[self percentageForHeight:fadeHeight]
                            edges:fadeEdges];
}

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight
{
    return [self initWithFadeHeight:fadeHeight edges:FadeEdgesTopAndBottom];
}

- (instancetype)init
{
    return [self initWithFadeHeight:SSDefaultFadeHeight];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self init];
    if (self) {
        [self setDefaults];
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults
{
    self.fadeType = FadeTypeHeight;
    self.fadeTop = YES;
    self.fadeBottom = YES;
    self.fadePercentage = [self percentageForHeight:SSDefaultFadeHeight];
    self.fadeDuration = 0.3;
    self.maskScrollBar = NO;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self updateMaskFrame];
    [self updateGradients];
}

- (void)updateMaskFrame
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.maskLayer.frame = self.bounds;
    [CATransaction commit];
}

- (void)updateGradients
{
    if (self.fadeTop) {
        if (!self.topGradientIsHidden && self.contentOffset.y <= 0) {
            [self animateTopGradientToColor:[SSFadingScrollView opaqueColor]]; // fade out
        }
        else if (self.topGradientIsHidden && self.contentOffset.y > 0) {
            [self animateTopGradientToColor:[SSFadingScrollView transparentColor]]; // fade in
        }
    }
    if (self.fadeBottom) {
        CGFloat maxContentOffset = self.contentSize.height - CGRectGetHeight(self.bounds);

        if (!self.bottomGradientIsHidden && self.contentOffset.y >= maxContentOffset) {
            [self animateBottomGradientToColor:[SSFadingScrollView opaqueColor]];
        }
        else if (self.bottomGradientIsHidden && self.contentOffset.y < maxContentOffset) {
            [self animateBottomGradientToColor:[SSFadingScrollView transparentColor]];
        }
    }
}

#pragma mark - Properties

- (CALayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [self setupMaskLayer];
    }
    return _maskLayer;
}

- (void)setBounds:(CGRect)bounds
{
    CGFloat previousHeight = self.fadeHeight;
    CGSize previousSize = self.bounds.size;

    [super setBounds:bounds];

    if (!CGSizeEqualToSize(previousSize, bounds.size) && self.fadeType == FadeTypeHeight) {
        // Update fade percentage for new bounds height
        self.fadePercentage = [self percentageForHeight:previousHeight];
    }
}

#pragma mark Computed properties

- (CGFloat)fadeHeight
{
    return [self heightForPercentage:self.fadePercentage];
}

- (void)setFadeHeight:(CGFloat)fadeHeight
{
    self.fadePercentage = [self percentageForHeight:fadeHeight];
}

- (BOOL)topGradientIsHidden
{
    CGColorRef firstColor = (__bridge CGColorRef)self.gradientLayer.colors.firstObject;
    return CGColorEqualToColor(firstColor, [SSFadingScrollView opaqueColor]);
}

- (BOOL)bottomGradientIsHidden
{
    CGColorRef lastColor = (__bridge CGColorRef)self.gradientLayer.colors.lastObject;
    return CGColorEqualToColor(lastColor, [SSFadingScrollView opaqueColor]);
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
        gradientLocations = @[@(0), @(self.fadePercentage)];
    }
    if (self.fadeBottom) {
        gradientColors = [gradientColors arrayByAddingObjectsFromArray:@[opaque, transparent]];
        gradientLocations = [gradientLocations arrayByAddingObjectsFromArray:@[@(1.0f - self.fadePercentage), @(1)]];
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
    scrollGutterLayer.frame = CGRectMake(CGRectGetHeight(self.bounds) - SSDefaultScrollBarWidth, 0,
                                         SSDefaultScrollBarWidth, CGRectGetHeight(self.bounds));

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

#pragma mark Gradient mask colors

+ (CGColorRef)opaqueColor
{
    return [UIColor blackColor].CGColor;
}

+ (CGColorRef)transparentColor
{
    return [UIColor clearColor].CGColor;
}

#pragma mark Gradient animation

- (void)animateTopGradientToColor:(CGColorRef)color
{
    NSArray *colours = [self colorsArrayByReplacingObjectAtIndex:0 withColor:color];
    [self animateGradientColours:colours];
}

- (void)animateBottomGradientToColor:(CGColorRef)color
{
    NSUInteger lastIndex = self.gradientLayer.colors.count - 1;
    NSArray *colours = [self colorsArrayByReplacingObjectAtIndex:lastIndex withColor:color];
    [self animateGradientColours:colours];
}

- (NSArray *)colorsArrayByReplacingObjectAtIndex:(NSUInteger)index withColor:(CGColorRef)color
{
    NSMutableArray *mutableColours = [self.gradientLayer.colors mutableCopy];
    mutableColours[index] = (__bridge id)color;

    return [mutableColours copy];
}

- (void)animateGradientColours:(NSArray *)colours
{
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    animation.fromValue = ((CAGradientLayer *)self.gradientLayer.presentationLayer).colors;
    animation.toValue = colours;
    // TODO: duration = total duration x percentage of total colour to fade
    animation.duration = self.fadeDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradientLayer.colors = colours; // update the model value
    [CATransaction commit];

    [self.gradientLayer addAnimation:animation forKey:@"animateGradient"];
}

@end
