//
//  FadingScrollView.h
//  Created by Stephanie Sharp on 1/06/13.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FadeType) {
    FadeTypePercentage,
    FadeTypeHeight
};

typedef NS_ENUM(NSUInteger, FadeEdges) {
    FadeEdgesTopAndBottom,
    FadeEdgesTop,
    FadeEdgesBottom
};

@interface SSFadingScrollView : UIScrollView

// designated initializer
- (instancetype)initWithFadeType:(FadeType)fadeType percentage:(CGFloat)fadePercentage edges:(FadeEdges)fadeEdges;
- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage edges:(FadeEdges)fadeEdges;
- (instancetype)initWithFadePercentage:(CGFloat)fadePercentage; // top and bottom

- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight edges:(FadeEdges)fadeEdges;
- (instancetype)initWithFadeHeight:(CGFloat)fadeHeight; // top and bottom
- (instancetype)init; // top and bottom with default fade height

@property (nonatomic) IBInspectable BOOL fadeTop;
@property (nonatomic) IBInspectable BOOL fadeBottom;
@property (nonatomic) IBInspectable CGFloat fadeHeight;
@property (nonatomic) IBInspectable double fadeDuration;

// default NO, set to YES to mask the scroll bar so it isn't faded
@property (nonatomic) IBInspectable BOOL maskScrollBar;

@end
