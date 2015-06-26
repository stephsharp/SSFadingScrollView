//
//  SSFadingScrollView.h
//
//  Created by julien goudet on 26/06/2015.
//  Copyright (c) 2015 lbp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSFadingScrollView : UIScrollView

/**
 *  Call this main init method to put default top and bottom fade with default effect
 *
 *  @return the faded UISCrollView
 */
- (id)init;

/**
 *  Call this method to init a UIScrollView with a default fade only at the Top
 *
 *  @return the faded UISCrollView
 */
- (id)initWithTopFade;

/**
 *  Call this method to init a UIScrollView with a given percentage of fade, only at the Top
 *
 *  @param percent the percent of the scrollview which will be faded at the top
 *
 *  @return the faded UISCrollView
 */
- (id)initWithTopFade:(float)percent;

/**
 *  Call this method to init a UIScrollView with a default fade only at the Bottom
 *
 *  @return the faded UISCrollView
 */
- (id)initWithBottomFade;

/**
 *  Call this method to init a UIScrollView with a given percentage of fade, only at the Bottom
 *
 *  @param percent the percent of the scrollview which will be faded at the Bottom
 *
 *  @return the faded UISCrollView
 */
- (id)initWithBottomFade:(float)percent;


@end