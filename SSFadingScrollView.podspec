Pod::Spec.new do |s|
  s.name         = "SSFadingScrollView"
  s.version      = "1.1.0"
  s.summary      = "A UIScrollView subclass that fades the leading and/or trailing edges of a scroll view to transparent"
  s.homepage     = "https://github.com/stephsharp/SSFadingScrollView/"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Stephanie Sharp"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/stephsharp/SSFadingScrollView.git", :tag => "v#{s.version}" }
  s.source_files = "SSFadingScrollView"
  s.public_header_files = [ "SSFadingScrollView/SSFadingScrollView.h" ]
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end
