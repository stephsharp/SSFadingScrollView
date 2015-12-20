//
//  SSFadingScrollView.h
//  Created by Stephanie Sharp on 1/06/13.
//

#import <UIKit/UIKit.h>

//! Project version number for SSFadingScrollView.
FOUNDATION_EXPORT double SSFadingScrollViewVersionNumber;

//! Project version string for SSFadingScrollView.
FOUNDATION_EXPORT const unsigned char SSFadingScrollViewVersionString[];

typedef NS_ENUM(NSUInteger, FadeEdges) {
    FadeEdgesTopAndBottom,
    FadeEdgesTop,
    FadeEdgesBottom
};

@interface SSFadingScrollView : UIScrollView

/**
 * Designated initializer.
 */
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges;

/**
 * Initializer that fades the top and bottom of the scroll view.
 */
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight;

/**
 * Initializer that fades the top and bottom of the scroll view with default fade height.
 */
- (instancetype)init;

/**
 * Fade top of scroll view. Default is YES.
 */
@property (nonatomic) IBInspectable BOOL fadeTop;

/**
 * Fade bottom of scroll view. Default is YES.
 */
@property (nonatomic) IBInspectable BOOL fadeBottom;

/**
 * Height of gradient. Default is 30.
 */
@property (nonatomic) IBInspectable CGFloat fadeHeight;

/**
 * Duration of fade in & out. Default is 0.3 seconds.
 */
@property (nonatomic) IBInspectable double fadeDuration;

/**
 * Default is YES. Scroll bars are masked so they don't fade with the scroll view content.
 * Set to NO to fade out the scroll bars along with the content.
 */
@property (nonatomic) IBInspectable BOOL maskScrollBars;

@end
