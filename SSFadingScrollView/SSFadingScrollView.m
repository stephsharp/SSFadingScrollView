//
//  SSFadingScrollView.m
//  Created by Stephanie Sharp on 1/06/13.
//

#import "SSFadingScrollView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const SSDefaultFadeSize = 30.0;
static CFTimeInterval const SSDefaultFadeDuration = 0.3;
static void *SSContext = &SSContext;

@interface SSFadingScrollView ()

@property (nonatomic) CALayer *maskLayer;
@property (nonatomic) CAGradientLayer *gradientLayer;

@property (nonatomic) UIImageView *verticalScrollBar;
@property (nonatomic) UIImageView *horizontalScrollBar;
@property (nonatomic) CALayer *verticalScrollBarLayer;
@property (nonatomic) CALayer *horizontalScrollBarLayer;

@end

@implementation SSFadingScrollView

#pragma mark - Initializers

- (instancetype)initWithFadeSize:(CGFloat)fadeSize axis:(SSScrollViewFadeAxis)fadeAxis
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setDefaults];
        _fadeSize = fadeSize;
        _fadeAxis = fadeAxis;
    }
    return self;
}

- (instancetype)initWithFadeSize:(CGFloat)fadeSize
{
    return [self initWithFadeSize:fadeSize axis:SSScrollViewFadeAxisVertical];
}

- (instancetype)init
{
    return [self initWithFadeSize:SSDefaultFadeSize];
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
    _fadeAxis = SSScrollViewFadeAxisVertical;
    _fadeLeadingEdge = YES;
    _fadeTrailingEdge = YES;
    _fadeSize = SSDefaultFadeSize;
    _fadeDuration = SSDefaultFadeDuration;
    _maskScrollBars = YES;
}

- (void)dealloc
{
    if (_verticalScrollBar) {
        [_verticalScrollBar removeObserver:self forKeyPath:@"alpha" context:SSContext];
    }
    if (_horizontalScrollBar) {
        [_horizontalScrollBar removeObserver:self forKeyPath:@"alpha" context:SSContext];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateMask];
}

- (void)updateMask
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.maskLayer.frame = self.bounds;
    [CATransaction commit];

    [self updateGradients];
    [self updateScrollBarMasks];
}

- (void)updateGradients
{
    self.gradientLayer.frame = self.maskLayer.bounds;
    NSInteger contentOffset = roundf(self.isVertical ? self.contentOffset.y : self.contentOffset.x);

    if (self.fadeLeadingEdge) {
        if (!self.leadingGradientIsHidden && contentOffset <= 0) {
            [self animateLeadingGradientToColor:[SSFadingScrollView opaqueColor]]; // fade out
        }
        else if (self.leadingGradientIsHidden && contentOffset > 0) {
            [self animateLeadingGradientToColor:[SSFadingScrollView transparentColor]]; // fade in
        }
    }
    if (self.fadeTrailingEdge) {
        NSInteger maxContentOffset;
        if (self.isVertical) {
            maxContentOffset = roundf(self.contentSize.height - CGRectGetHeight(self.bounds));
        }
        else {
            maxContentOffset = roundf(self.contentSize.width - CGRectGetWidth(self.bounds));
        }

        if (!self.trailingGradientIsHidden && contentOffset >= maxContentOffset) {
            [self animateTrailingGradientToColor:[SSFadingScrollView opaqueColor]];
        }
        else if (self.trailingGradientIsHidden && contentOffset < maxContentOffset) {
            [self animateTrailingGradientToColor:[SSFadingScrollView transparentColor]];
        }
    }
}

#pragma mark - Properties

- (BOOL)isVertical
{
    return self.fadeAxis == SSScrollViewFadeAxisVertical;
}

- (CALayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [self setupMaskLayer];
    }
    return _maskLayer;
}

- (CALayer *)verticalScrollBarLayer
{
    if (!_verticalScrollBarLayer) {
        _verticalScrollBarLayer = [self setupVerticalScrollBarLayer];
    }

    return _verticalScrollBarLayer;
}

- (CALayer *)horizontalScrollBarLayer
{
    if (!_horizontalScrollBarLayer) {
        _horizontalScrollBarLayer = [self setupHorizontalScrollBarLayer];
    }

    return _horizontalScrollBarLayer;
}

- (BOOL)leadingGradientIsHidden
{
    CGColorRef firstColor = (__bridge CGColorRef)self.gradientLayer.colors.firstObject;
    return CGColorEqualToColor(firstColor, [SSFadingScrollView opaqueColor]);
}

- (BOOL)trailingGradientIsHidden
{
    CGColorRef lastColor = (__bridge CGColorRef)self.gradientLayer.colors.lastObject;
    return CGColorEqualToColor(lastColor, [SSFadingScrollView opaqueColor]);
}

#pragma mark - Mask

- (CALayer *)setupMaskLayer
{
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;

    self.gradientLayer = [self setupGradientLayer];
    [maskLayer addSublayer:self.gradientLayer];

    if (self.maskScrollBars) {
        [maskLayer addSublayer:self.verticalScrollBarLayer];
        [maskLayer addSublayer:self.horizontalScrollBarLayer];
    }

    self.layer.mask = maskLayer;

    return maskLayer;
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

#pragma mark - Gradient mask

- (CAGradientLayer *)setupGradientLayer
{
    id transparent = (id)[SSFadingScrollView transparentColor];
    id opaque = (id)[SSFadingScrollView opaqueColor];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect frame = self.bounds;
    frame.origin = CGPointZero;
    gradientLayer.frame = frame;

    NSArray *colors = [NSArray new];
    NSArray *locations = [NSArray new];

    CGFloat fadePercentage = [self percentageForFadeSize];

    if (self.fadeLeadingEdge) {
        colors = @[transparent, opaque];
        locations = @[@(0), @(fadePercentage)];
    }
    if (self.fadeTrailingEdge) {
        colors = [colors arrayByAddingObjectsFromArray:@[opaque, transparent]];
        locations = [locations arrayByAddingObjectsFromArray:@[@(1.0 - fadePercentage), @(1)]];
    }

    gradientLayer.colors = colors;
    gradientLayer.locations = locations;

    if (self.isVertical) {
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 1);
    }
    else {
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
    }

    return gradientLayer;
}

- (CGFloat)percentageForFadeSize
{
    CGFloat size = self.isVertical ? CGRectGetHeight(self.bounds) : CGRectGetWidth(self.bounds);

    if (size <= 0) {
        return 0;
    }

    CGFloat maxFadePercentage = (self.fadeLeadingEdge && self.fadeTrailingEdge) ? 0.5 : 1.0;
    return fminf(self.fadeSize / size, maxFadePercentage);
}

#pragma mark Gradient animation

- (void)animateLeadingGradientToColor:(CGColorRef)color
{
    NSArray *colours = [self colorsArrayByReplacingObjectAtIndex:0 withColor:color];
    [self animateGradientColours:colours];
}

- (void)animateTrailingGradientToColor:(CGColorRef)color
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
    animation.duration = self.fadeDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradientLayer.colors = colours; // update the model value
    [CATransaction commit];

    [self.gradientLayer addAnimation:animation forKey:@"animateGradient"];
}

#pragma mark - Scroll bar mask

- (CALayer *)setupVerticalScrollBarLayer
{
    if (!self.verticalScrollBar) {
        [self findScrollBars];

        if (!self.verticalScrollBar) {
            return nil;
        }
    }

    [self.verticalScrollBar addObserver:self forKeyPath:@"alpha" options:0 context:SSContext];

    return [self scrollBarLayerWithFrame:self.verticalScrollBar.frame];
}

- (CALayer *)setupHorizontalScrollBarLayer
{
    if (!self.horizontalScrollBar) {
        [self findScrollBars];

        if (!self.horizontalScrollBar) {
            return nil;
        }
    }

    [self.horizontalScrollBar addObserver:self forKeyPath:@"alpha" options:0 context:SSContext];

    return [self scrollBarLayerWithFrame:self.horizontalScrollBar.frame];
}

- (void)findScrollBars
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]] && subview.tag == 0) {
            UIImageView *imageView = (UIImageView *)subview;

            if (imageView.frame.size.width == 3.5 ||
                imageView.frame.size.width == 2.5 ||
                (imageView.frame.size.width < 2.4 && imageView.frame.size.width > 2.3))
            {
                self.verticalScrollBar = imageView;
            }
            else if (imageView.frame.size.height == 3.5 ||
                     imageView.frame.size.height == 2.5 ||
                     (imageView.frame.size.height < 2.4 && imageView.frame.size.height > 2.3))
            {
                self.horizontalScrollBar = imageView;
            }
        }
    }
}

- (CALayer *)scrollBarLayerWithFrame:(CGRect)frame
{
    CALayer *scrollBarLayer = [CALayer layer];
    scrollBarLayer.backgroundColor = [SSFadingScrollView opaqueColor];
    scrollBarLayer.frame = frame;

    return scrollBarLayer;
}

- (void)updateScrollBarMasks
{
    if (self.maskScrollBars) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];

        CGRect verticalScrollBarFrame = [self.layer convertRect:self.verticalScrollBar.frame
                                                        toLayer:self.maskLayer];
        self.verticalScrollBarLayer.frame = verticalScrollBarFrame;
        self.verticalScrollBarLayer.opacity = self.verticalScrollBar.alpha;

        CGRect horizontalScrollBarFrame = [self.layer convertRect:self.horizontalScrollBar.frame
                                                          toLayer:self.maskLayer];
        self.horizontalScrollBarLayer.frame = horizontalScrollBarFrame;
        self.horizontalScrollBarLayer.opacity = self.horizontalScrollBar.alpha;

        [CATransaction commit];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != SSContext) {
        return;
    }

    if([keyPath isEqualToString:@"alpha"] && [object valueForKeyPath:keyPath] != [NSNull null]) {
        [self layoutSubviews];
    }
}

#pragma mark - Deprecated

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges
{
    self = [self initWithFadeSize:fadeHeight];
    if (self) {
        switch (fadeEdges) {
            case FadeEdgesTopAndBottom:
                _fadeLeadingEdge = YES;
                _fadeTrailingEdge = YES;
                break;
            case FadeEdgesTop:
                _fadeLeadingEdge = YES;
                _fadeTrailingEdge = NO;
                break;
            case FadeEdgesBottom:
                _fadeLeadingEdge = NO;
                _fadeTrailingEdge = YES;
                break;
            default:
                break;
        }
    }
    return self;
}

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight
{
    return [self initWithFadeSize:fadeHeight];
}

- (BOOL)fadeTop;
{
    return self.fadeLeadingEdge;
}

- (void)setFadeTop:(BOOL)fade;
{
    self.fadeLeadingEdge = fade;
}

- (BOOL)fadeBottom;
{
    return self.fadeTrailingEdge;
}

- (void)setFadeBottom:(BOOL)fade;
{
    self.fadeTrailingEdge = fade;
}

- (CGFloat)fadeHeight;
{
    return self.fadeSize;
}

- (void)setFadeHeight:(CGFloat)height;
{
    self.fadeSize = height;
}

@end
