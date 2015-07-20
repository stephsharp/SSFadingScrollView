//
//  FadingScrollView.h
//  Created by Stephanie Sharp on 1/06/13.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FadeEdges) {
    FadeEdgesTopAndBottom,
    FadeEdgesTop,
    FadeEdgesBottom
};

@interface SSFadingScrollView : UIScrollView

// designated initializer
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges;
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight; // top and bottom
- (instancetype)init; // top and bottom with default fade height

@property (nonatomic) IBInspectable BOOL fadeTop;
@property (nonatomic) IBInspectable BOOL fadeBottom;
@property (nonatomic) IBInspectable CGFloat fadeHeight; // default = 30.0f
@property (nonatomic) IBInspectable double fadeDuration;

// Default NO, set to YES to mask the scroll bars so they aren't faded
// Masking scrollbars works for iOS 7+
@property (nonatomic) IBInspectable BOOL maskScrollBars;

@end
