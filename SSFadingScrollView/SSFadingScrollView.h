//
//  SSFadingScrollView.h
//  Created by Stephanie Sharp on 1/06/13.
//

#import <UIKit/UIKit.h>

//! Project version number for SSFadingScrollView.
FOUNDATION_EXPORT double SSFadingScrollViewVersionNumber;

//! Project version string for SSFadingScrollView.
FOUNDATION_EXPORT const unsigned char SSFadingScrollViewVersionString[];

typedef NS_ENUM(NSUInteger, SSScrollViewFadeAxis) {
    SSScrollViewFadeAxisVertical   = 0,
    SSScrollViewFadeAxisHorizontal = 1,
};

typedef NS_ENUM(NSUInteger, FadeEdges) {
    FadeEdgesTopAndBottom __attribute__((deprecated("Use the fadeLeadingEdge and fadeTrailingEdge properties instead."))),
    FadeEdgesTop __attribute__((deprecated("Use the fadeLeadingEdge property instead."))),
    FadeEdgesBottom __attribute__((deprecated("Use the fadeTrailingEdge property instead."))),
};

/**
 * This scrollview subclass is meant to only scroll in one direction (horizontal or vertical).
 * On the chosen axis, either or both the leading and trailing edges can be faded.
 */
@interface SSFadingScrollView : UIScrollView

/**
 * Designated initializer.
 */
- (instancetype)initWithFadeSize:(CGFloat)fadeSize axis:(SSScrollViewFadeAxis)fadeAxis;

/**
 * Initializer that fades the top and bottom of the scroll view.
 */
- (instancetype)initWithFadeSize:(CGFloat)fadeSize;

/**
 * Initializer that fades the top and bottom of the scroll view with default fade height.
 */
- (instancetype)init;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable NSUInteger fadeAxis;
#else
@property (nonatomic) SSScrollViewFadeAxis fadeAxis;
#endif

/**
 * Fade leading edge of fade axis. Default is YES.
 */
@property (nonatomic) IBInspectable BOOL fadeLeadingEdge;

/**
 * Fade trailing edge of fade axis. Default is YES.
 */
@property (nonatomic) IBInspectable BOOL fadeTrailingEdge;

/**
 * Size of gradient. Default is 30.
 */
@property (nonatomic) IBInspectable CGFloat fadeSize;

/**
 * Duration of fade in & out. Default is 0.3 seconds.
 */
@property (nonatomic) IBInspectable double fadeDuration;

/**
 * Default is YES. Scroll bars are masked so they don't fade with the scroll view content.
 * Set to NO to fade out the scroll bars along with the content.
 */
@property (nonatomic) IBInspectable BOOL maskScrollBars;

#pragma mark - Deprecated

/**
 * Deprecated initializer.
 */
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges __attribute__((deprecated("Use initWithFadeSize: and the fadeLeadingEdge/fadeTrailingEdge properties instead.")));

/**
 * Initializer that fades the top and bottom of the scroll view.
 */
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight __attribute__((deprecated("Use initWithFadeSize: instead.")));

/**
 * Fade top of scroll view. Default is YES.
 */
@property (nonatomic) BOOL fadeTop __attribute__((deprecated("Use the fadeLeadingEdge property instead.")));

/**
 * Fade bottom of scroll view. Default is YES.
 */
@property (nonatomic) BOOL fadeBottom __attribute__((deprecated("Use the fadeTrailingEdge property instead.")));

/**
 * Height of gradient. Default is 30.
 */
@property (nonatomic) CGFloat fadeHeight __attribute__((deprecated("Use the fadeSize property instead.")));

@end
