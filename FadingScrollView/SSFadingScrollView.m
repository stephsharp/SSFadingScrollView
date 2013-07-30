//
//  FadingScrollView.m
//  Created by Stephanie Sharp on 1/06/13.
//

#import "SSFadingScrollView.h"
#import <QuartzCore/QuartzCore.h>

#define kScrollBarWidth 7
#define kFadePercentage 0.1

@implementation SSFadingScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSObject * transparent = (NSObject *) [[UIColor colorWithWhite:0 alpha:0] CGColor];
    NSObject * opaque = (NSObject *) [[UIColor colorWithWhite:0 alpha:1] CGColor];
    
    CALayer * maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;
    
    CALayer * scrollGutterLayer = [CALayer layer];
    scrollGutterLayer.frame = CGRectMake(self.bounds.size.width - kScrollBarWidth, 0,
                                         kScrollBarWidth, self.bounds.size.height);
    scrollGutterLayer.backgroundColor = (__bridge CGColorRef)(opaque);
    
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(self.bounds.origin.x, 0,
                                     self.bounds.size.width, self.bounds.size.height);
    
    gradientLayer.colors = [NSArray arrayWithObjects: transparent, opaque,
                            opaque, transparent, nil];
    
    // Set percentage of scrollview that fades at top & bottom
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0],
                               [NSNumber numberWithFloat:kFadePercentage],
                               [NSNumber numberWithFloat:1.0 - kFadePercentage],
                               [NSNumber numberWithFloat:1], nil];
    
    gradientLayer.startPoint=CGPointMake(0.5, 0);
    gradientLayer.endPoint=CGPointMake(0.5, 1);
    
    [maskLayer addSublayer:gradientLayer];
    [maskLayer addSublayer:scrollGutterLayer];
    self.layer.mask = maskLayer;
}

@end
