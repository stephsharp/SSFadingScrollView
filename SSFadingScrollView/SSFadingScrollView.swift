//
//  SSFadingScrollView.swift
//  SSFadingScrollView
//
//  Created by Bartosz Dolewski on 16/06/2019.
//  Copyright © 2019 Stephanie Sharp. All rights reserved.
//

import UIKit
import QuartzCore

@objc enum FadeAxis: Int {
    case vertical = 0
    case horizontal = 1
}

@objc enum FadeEdges: Int {
    case FadeEdgesTopAndBottom
    case FadeEdgesTop
    case FadeEdgesBottom
}

private let SSDefaultFadeSize: CGFloat = 30.0
private let SSDefaultFadeDuration: CFTimeInterval = 0.3

@IBDesignable
class SSFadingScrollView: UIScrollView {
    /**
     * Fade leading edge of fade axis. Default is YES.
     */
    @IBInspectable var fadeLeadingEdge = false
    /**
     * Fade trailing edge of fade axis. Default is YES.
     */
    @IBInspectable var fadeTrailingEdge = false
    /**
     * Size of gradient. Default is 30.
     */
    @IBInspectable var fadeSize: CGFloat = 0.0
    /**
     * Duration of fade in & out. Default is 0.3 seconds.
     */
    @IBInspectable var fadeDuration = 0.0
    /**
     * Default is YES. Scroll bars are masked so they don't fade with the scroll view content.
     * Set to NO to fade out the scroll bars along with the content.
     */
    @IBInspectable var maskScrollBars = false
    
    @available(*, unavailable, message: "This property is reserved for Interface Builder. Use 'fadeAxis' instead.")
    @IBInspectable var axisIB: FadeAxis.RawValue {
        set { fadeAxis = FadeAxis(rawValue: newValue) ?? .vertical }
        get { return fadeAxis.rawValue }
    }
    
    var fadeAxis: FadeAxis = .vertical
    
    private lazy var maskLayer: CALayer = {
        return setupMaskLayer()
    }()
    
    private lazy var verticalScrollBarLayer: CALayer = {
        return setupVerticalScrollBarLayer()
    }()
    
    private lazy var horizontalScrollBarLayer: CALayer = {
        return setupHorizontalScrollBarLayer()
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        return setupGradientLayer()
    }()
    
    private var verticalScrollBar: UIImageView?
    private var horizontalScrollBar: UIImageView?
    
    private var verticalScrollObservation: NSKeyValueObservation?
    private var horizontalScrollObservation: NSKeyValueObservation?
    
    // MARK: - Initializers
    init(fadeSize: CGFloat, axis fadeAxis: FadeAxis) {
        super.init(frame: CGRect.zero)
        setDefaults()
        self.fadeSize = fadeSize
        self.fadeAxis = fadeAxis
        
        verticalScrollObservation = verticalScrollBar?.observe(\.alpha) { [weak self] object, change in
            self?.layoutSubviews()
        }
        
        horizontalScrollObservation = horizontalScrollBar?.observe(\.alpha) { [weak self] object, change in
            self?.layoutSubviews()
        }
    }
    
    convenience init(fadeSize: CGFloat) {
        self.init(fadeSize: fadeSize, axis: .vertical)
    }
    
    convenience init() {
        self.init(fadeSize: SSDefaultFadeSize)
    }
    
    convenience override init(frame: CGRect) {
        self.init()
        setDefaults()
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setDefaults()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }
}

// MARK: - Setup helpers
private extension SSFadingScrollView {
    func setDefaults() {
        fadeAxis = .vertical
        fadeLeadingEdge = true
        fadeTrailingEdge = true
        fadeSize = SSDefaultFadeSize
        fadeDuration = SSDefaultFadeDuration
        maskScrollBars = true
    }
    
    func setupMaskLayer() -> CALayer {
        let maskLayer = CALayer()
        maskLayer.frame = bounds
        
        gradientLayer = setupGradientLayer()
        maskLayer.addSublayer(gradientLayer)
        
        if maskScrollBars {
            maskLayer.addSublayer(verticalScrollBarLayer)
            maskLayer.addSublayer(horizontalScrollBarLayer)
        }
        
        layer.mask = maskLayer
        
        return maskLayer
    }
    
    func setupVerticalScrollBarLayer() -> CALayer {
        findScrollBars()
        return scrollBar(with: verticalScrollBar?.frame ?? .zero)
    }
    
    func setupHorizontalScrollBarLayer() -> CALayer {
        findScrollBars()
        return scrollBar(with: horizontalScrollBar?.frame ?? .zero)
    }
    
    func setupGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.frame.origin = .zero
        
        var colors: [CGColor] = []
        var locations: [NSNumber] = []
        
        if fadeLeadingEdge {
            colors = [transparentColor, opaqueColor]
            locations = [NSNumber(value: 0), NSNumber(value: percentageForFadeSize)]
        }
        
        if fadeTrailingEdge {
            colors = colors + [opaqueColor, transparentColor]
            locations = locations + [NSNumber(value: 1.0 - percentageForFadeSize), NSNumber(value: 1)]
        }
        
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        gradientLayer.startPoint = isVertical ? CGPoint(x: 0.5, y: 0.0) : CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = isVertical ? CGPoint(x: 0.5, y: 1.0) : CGPoint(x: 1.0, y: 0.5)
        
        return gradientLayer
    }
}

// MARK: - Update helpers
private extension SSFadingScrollView {
    func updateMask() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.frame = bounds
        CATransaction.commit()
        
        updateGradients()
        updateScrollBarMasks()
    }
    
     func updateLeadingFade(_ contentOffset: Int) {
        if !leadingGradientIsHidden && contentOffset <= 0 {
            animateLeadingGradient(to: opaqueColor) // fade out
        } else if leadingGradientIsHidden && contentOffset > 0 {
            animateLeadingGradient(to: transparentColor) // fade in
        }
    }
    
     func updateTrailingFade(_ contentOffset: Int) {
        let maxContentOffset = isVertical ? Float(contentSize.height - bounds.height) : Float(contentSize.width - bounds.width)
        
        if !trailingGradientIsHidden && contentOffset >= Int(roundf(maxContentOffset)) {
            animateTrailingGradient(to: opaqueColor)
        } else if trailingGradientIsHidden && contentOffset < Int(roundf(maxContentOffset)) {
            animateTrailingGradient(to: transparentColor)
        }
    }
    
    func updateGradients() {
        gradientLayer.frame = maskLayer.bounds
        let contentOffset = Int(roundf(Float(isVertical ? self.contentOffset.y : self.contentOffset.x)))
        
        if fadeLeadingEdge {
            updateLeadingFade(contentOffset)
        }
        if fadeTrailingEdge {
            updateTrailingFade(contentOffset)
        }
    }
    
    func updateScrollBarMasks() {
        guard maskScrollBars else { return }
        guard let verticalScrollBar = verticalScrollBar,
            let horizontalScrollBar = horizontalScrollBar else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let verticalScrollBarFrame = layer.convert(verticalScrollBar.frame, to: maskLayer)
        verticalScrollBarLayer.frame = verticalScrollBarFrame
        verticalScrollBarLayer.opacity = Float(verticalScrollBar.alpha)
        
        let horizontalScrollBarFrame = layer.convert(horizontalScrollBar.frame, to: maskLayer)
        horizontalScrollBarLayer.frame = horizontalScrollBarFrame
        horizontalScrollBarLayer.opacity = Float(horizontalScrollBar.alpha)
        
        CATransaction.commit()
    }
}

// MARK: - ScrollBars
extension SSFadingScrollView {
    func scrollBar(with frame: CGRect) -> CALayer {
        let scrollBarLayer = CALayer()
        scrollBarLayer.backgroundColor = opaqueColor
        scrollBarLayer.frame = frame
        
        return scrollBarLayer
    }
    
    func isScrollBar(_ dimension: CGFloat) -> Bool {
        return dimension == 3.5 || dimension == 2.5 || ((dimension) < 2.4 && (dimension ) > 2.3)
    }
    
    func findScrollBars() {
        subviews
            .filter { ($0 is UIImageView) && $0.tag == 0 }
            .compactMap { $0 as? UIImageView }
            .forEach { imageView in
                if isScrollBar(imageView.frame.size.width) {
                    verticalScrollBar = imageView
                } else if isScrollBar(imageView.frame.size.height) {
                    horizontalScrollBar = imageView
                }
        }
    }
}

// MARK: - Properties
private extension SSFadingScrollView {
    var isVertical: Bool {
        return fadeAxis == .vertical
    }
    
    var leadingGradientIsHidden: Bool {
        let firstColor = gradientLayer.colors?.first as! CGColor
        return firstColor == opaqueColor
    }
    
    var trailingGradientIsHidden: Bool {
        let lastColor = gradientLayer.colors?.last as! CGColor
        return lastColor == opaqueColor
    }
    
    var opaqueColor: CGColor {
        return UIColor.black.cgColor
    }
    
    var transparentColor: CGColor {
        return UIColor.clear.cgColor
    }
    
    var percentageForFadeSize: Float {
        let size = isVertical ? bounds.height : bounds.width
        
        if size <= 0 {
            return 0
        }
        
        let maxFadePercentage = (fadeLeadingEdge && fadeTrailingEdge) ? Float(0.5) : Float(1.0)
        return fminf(Float(fadeSize / size), maxFadePercentage)
    }
}

// MARK: - Gradient animation
private extension SSFadingScrollView {
    func animateLeadingGradient(to color: CGColor) {
        let colors = colorsWithReplacement(at: 0, with: color)
        animateGradientColors(colors)
    }
    
    func animateTrailingGradient(to color: CGColor) {
        guard let endIndex = gradientLayer.colors?.endIndex else { return }
        
        let lastIndex = endIndex - 1
        let colors = colorsWithReplacement(at: lastIndex, with: color)
        animateGradientColors(colors)
    }
    
    func colorsWithReplacement(at index: Int, with color: CGColor) -> [CGColor] {
        var mutableColors = gradientLayer.colors as! [CGColor]
        mutableColors[index] = color
        
        return mutableColors
    }
    
    func animateGradientColors(_ colors: [CGColor]) {
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        animation.fromValue = (gradientLayer.presentation())?.colors
        animation.toValue = colors
        animation.duration = fadeDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.colors = colors // update the model value
        CATransaction.commit()
        
        gradientLayer.add(animation, forKey: "animateGradient")
    }
}
