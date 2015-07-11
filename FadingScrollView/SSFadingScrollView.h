//
//  FadingScrollView.h
//  Created by Stephanie Sharp on 1/06/13.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FadeEdges) {
    FadeTopAndBottom,
    FadeTop,
    FadeBottom
};

@interface SSFadingScrollView : UIScrollView

- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage edges:(FadeEdges)fadeEdges; // designated initializer
- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage; // top and bottom

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges;
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight; // top and bottom
// top and bottom with default fade height
- (instancetype)init;

@property (nonatomic) IBInspectable BOOL fadeTop;
@property (nonatomic) IBInspectable BOOL fadeBottom;
@property (nonatomic) IBInspectable CGFloat fadeHeight;
@property (nonatomic) IBInspectable double fadeDuration;

// default NO, set to YES to mask the scroll bar so it isn't faded
@property (nonatomic) IBInspectable BOOL maskScrollBar;

@end
