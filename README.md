#SSFadingScrollView

A UIScrollView subclass that fades the leading and/or trailing edges of a scroll view to transparent. It animates the gradient in and out based on the current content offset, and uses a mask to fade the scroll view content without also fading the scroll bars.

![SSFadingScrollView screenshots](SSFadingScrollView.png)

##Features

- [x] Fade top and/or bottom of vertical scroll view
- [x] Fade left and/or right of horizontal scroll view
- [x] Animated fade in and out (based on content offset) with customizable duration
- [x] Adjustable gradient size
- [x] Scroll bars don't fade out with the scroll view content
- [x] IBInspectable properties allow you to set up your fading scroll view entirely in Interface Builder. (See the demo project for an example.)

##Properties

#####fadeLeadingEdge

Fade leading edge of fade axis. Default is YES.

#####fadeTrailingEdge

Fade trailing edge of fade axis. Default is YES.

#####fadeSize

Size of gradient. Default is 30.

#####fadeDuration

Duration of fade in & out. Default is 0.3 seconds.

#####maskScrollBars

Default is YES. Scroll bars are masked so they don't fade with the scroll view content. Set to NO to fade out the scroll bars along with the content.

##Installation

###CocoaPods

To install via CocoaPods, add to your podfile:

    pod 'SSFadingScrollView', '~> 1.1'

##Acknowledgements

With thanks to:

 - [MaximKeegan](https://gist.github.com/MaximKeegan)/[FadeScrollView](https://gist.github.com/MaximKeegan/2478842)
 - [kgn](https://gist.github.com/kgn)/[SNFadeScrollView](https://gist.github.com/kgn/3180607)

Photos in the demo project were sourced from [Unsplash](https://unsplash.com/).
 
##License

SSFadingScrollView is released under the MIT license. See LICENSE for details.
 