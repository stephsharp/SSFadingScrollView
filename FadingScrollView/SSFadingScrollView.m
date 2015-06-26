//
//  SSFadingScrollView.m
//
//  Created by julien goudet on 26/06/2015.
//  Copyright (c) 2015 lbp. All rights reserved.
//

#import "SSFadingScrollView.h"
#import <QuartzCore/QuartzCore.h>


static float const fadeDefault = 0.10;

@interface SSFadingScrollView () {
    float fadePercentage;
    BOOL topFade;
    BOOL bottomFade;
}

@end

@implementation SSFadingScrollView

/**
 *  Call this main init method to put default top and bottom fade with default effect
 *
 *  @return the faded UISCrollView
 */
- (id)init {
    self = [super init];
    if (self) {
        fadePercentage = -1;
        topFade = YES;
        bottomFade = YES;
    }
    return self;
}

/**
 *  Call this method to init a UIScrollView with a default fade only at the Top
 *
 *  @return the faded UISCrollView
 */
- (id)initWithTopFade {
    self = [super init];
    if (self) {
        fadePercentage = -1;
        topFade = YES;
        bottomFade = NO;
    }
    return self;
}

/**
 *  Call this method to init a UIScrollView with a given percentage of fade, only at the Top
 *
 *  @param percent the percent of the scrollview which will be faded at the top
 *
 *  @return the faded UISCrollView
 */
- (id)initWithTopFade:(float)percent {
    self = [super init];
    if (self) {
        fadePercentage = (percent > 0) ? percent : -1;
        topFade = YES;
        bottomFade = NO;
    }
    return self;
}

/**
 *  Call this method to init a UIScrollView with a default fade only at the Bottom
 *
 *  @return the faded UISCrollView
 */
- (id)initWithBottomFade {
    self = [super init];
    if (self) {
        fadePercentage = -1;
        topFade = NO;
        bottomFade = YES;
    }
    return self;
}

/**
 *  Call this method to init a UIScrollView with a given percentage of fade, only at the Bottom
 *
 *  @param percent the percent of the scrollview which will be faded at the Bottom
 *
 *  @return the faded UISCrollView
 */
- (id)initWithBottomFade:(float)percent {
    self = [super init];
    if (self) {
        fadePercentage = (percent > 0) ? percent : -1;
        topFade = NO;
        bottomFade = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    NSObject *transparent = (NSObject *)[[UIColor colorWithWhite:0 alpha:0] CGColor];
    NSObject *opaque = (NSObject *)[[UIColor colorWithWhite:0 alpha:1] CGColor];

    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(self.bounds.origin.x, 0,
                                     self.bounds.size.width, self.bounds.size.height);



    if (bottomFade) {
        if (topFade) {
            gradientLayer.colors = [NSArray arrayWithObjects:
                                    transparent,
                                    opaque,
                                    opaque,
                                    transparent,
                                    nil];
            gradientLayer.locations = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0],
                                       [NSNumber numberWithFloat:((fadePercentage == -1) ? fadeDefault : fadePercentage)],
                                       [NSNumber numberWithFloat:1.0 - ((fadePercentage == -1) ? fadeDefault : fadePercentage)],
                                       [NSNumber numberWithFloat:1],
                                       nil];
        }
        else {
            gradientLayer.colors = [NSArray arrayWithObjects:
                                    opaque,
                                    transparent,
                                    nil];
            gradientLayer.locations = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:1.0 - ((fadePercentage == -1) ? fadeDefault : fadePercentage)],
                                       [NSNumber numberWithFloat:1],
                                       nil];
        }
    }
    else {
        if (topFade) {
            gradientLayer.colors = [NSArray arrayWithObjects:
                                    transparent,
                                    opaque,
                                    nil];
            gradientLayer.locations = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0],
                                       [NSNumber numberWithFloat:((fadePercentage == -1) ? fadeDefault : fadePercentage)],
                                       nil];
        }
        else {
            gradientLayer.colors = [NSArray arrayWithObjects:
                                    transparent,
                                    opaque,
                                    opaque,
                                    transparent,
                                    nil];
            gradientLayer.locations = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0],
                                       [NSNumber numberWithFloat:((fadePercentage == -1) ? fadeDefault : fadePercentage)],
                                       [NSNumber numberWithFloat:1.0 - ((fadePercentage == -1) ? fadeDefault : fadePercentage)],
                                       [NSNumber numberWithFloat:1],
                                       nil];
        }
    }

    [maskLayer addSublayer:gradientLayer];
    self.layer.mask = maskLayer;
}

@end
