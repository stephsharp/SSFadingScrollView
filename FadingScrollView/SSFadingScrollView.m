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
@property (nonatomic) CGFloat topFadeHeight;
@property (nonatomic) CGFloat bottomFadeHeight;

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

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges
{
    self = [super init];
    if (self) {
        self.fadeType = FadeTypeHeight;
        self.fadeEdges = fadeEdges;

        switch (fadeEdges) {
            case FadeTopAndBottom:
                [self fadeTopWithHeight:fadeHeight];
                [self fadeBottomWithHeight:fadeHeight];
                break;
            case FadeTop:
                [self fadeTopWithHeight:fadeHeight];
                self.fadeBottom = NO;
                break;
            case FadeBottom:
                [self fadeBottomWithHeight:fadeHeight];
                self.fadeTop = NO;
                break;
            default:
                break;
        }
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

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight
{
    return [self initWithFadeHeight:fadeHeight edges:FadeTopAndBottom];
}

- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage
{
    return [self initWithFadePercentage:fadePercentage edges:FadeTopAndBottom];
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
    self.topFadeHeight = kDefaultFadeHeight;
    self.bottomFadeHeight = kDefaultFadeHeight;
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

- (void)fadeTopWithHeight:(CGFloat)height
{
    self.fadeTop = YES;
    self.topFadeHeight = height;
}

- (void)fadeBottomWithHeight:(CGFloat)height
{
    self.fadeBottom = YES;
    self.bottomFadeHeight = height;
}

#pragma mark - Layout

// TODO: dont fade top if content offset is at top (and same for bottom edge)

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;

    [maskLayer addSublayer:[self gradientLayer]];

    if (self.maskScrollBar) {
        [maskLayer addSublayer:[self scrollBarMaskLayer]];
    }

    self.layer.mask = maskLayer;
}

#pragma mark Mask

- (CALayer *)gradientLayer
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
        gradientLocations = @[@(0), @([self topFadeDistance])];
    }
    if (self.fadeBottom) {
        gradientColors = [gradientColors arrayByAddingObjectsFromArray:@[opaque, transparent]];
        gradientLocations = [gradientLocations arrayByAddingObjectsFromArray:@[@(1.0f - [self bottomFadeDistance]), @(1)]];
    }

    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);

    return gradientLayer;
}

// fade distance is between 0 and 1
- (CGFloat)topFadeDistance
{
    if (self.fadeType == FadeTypeHeight) {
        return [self heightAsPercentage:self.topFadeHeight];
    }

    return self.topFadePercentage;
}

- (CGFloat)bottomFadeDistance
{
    if (self.fadeType == FadeTypeHeight) {
        return [self heightAsPercentage:self.bottomFadeHeight];
    }

    return self.bottomFadePercentage;
}

- (CGFloat)heightAsPercentage:(CGFloat)height
{
    CGFloat scrollViewHeight = CGRectGetHeight(self.bounds);
    return (scrollViewHeight > 0) ? (height / scrollViewHeight) : 0;
}

- (CALayer *)scrollBarMaskLayer
{
    CALayer *scrollGutterLayer = [CALayer layer];
    scrollGutterLayer.frame = CGRectMake(self.bounds.size.width - kDefaultScrollBarWidth, 0,
                                         kDefaultScrollBarWidth, self.bounds.size.height);

    scrollGutterLayer.backgroundColor = [self opaque];

    return scrollGutterLayer;
}

#pragma mark - Properties

- (void)setFadeHeight:(CGFloat)fadeHeight
{
    self.topFadeHeight = fadeHeight;
    self.bottomFadeHeight = fadeHeight;
}

#pragma mark - Mask colors

- (CGColorRef)opaque
{
    return [UIColor colorWithWhite:0 alpha:1].CGColor;
}

- (CGColorRef)transparent
{
    return [UIColor colorWithWhite:0 alpha:0].CGColor;
}

@end
