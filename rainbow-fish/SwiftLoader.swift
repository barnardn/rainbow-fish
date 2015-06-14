//
//  BSLoader.swift
//  Brainstorage
//
//  Created by Kirill Kunst on 07.02.15.
//  Copyright (c) 2015 Kirill Kunst. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics

let loaderSpinnerMarginSide : CGFloat = 35.0
let loaderSpinnerMarginTop : CGFloat = 20.0
let loaderTitleMargin : CGFloat = 5.0


class SwiftFullScreenLoader: UIView {
    
    private var loadingView: SwiftLoadingView!
    private var titleLabel: UILabel?
    private var backgroundView: UIView!
    private var animating: Bool = false
    
    var title: String? {
        didSet {
            if self.titleLabel == nil {
                self.titleLabel = UILabel(frame: CGRectZero)
            }
            self.titleLabel!.numberOfLines = 1
            self.titleLabel!.textAlignment = .Center
            self.titleLabel!.adjustsFontSizeToFitWidth = true
            self.titleLabel?.font = self.config.titleTextFont
            self.titleLabel?.textColor = self.config.titleTextColor
            self.titleLabel?.text = self.title
            if self.titleLabel?.superview == nil {
                self.addSubview(self.titleLabel!)
                self.setNeedsLayout()
            }
        }
    }
    
    var config: SwiftLoaderConfig = SwiftLoaderConfig() {
        didSet {
            self.loadingView.config = self.config
            self.loadingView.frame = CGRectMake(CGRectGetMidX(self.frame) - (self.config.size/2.0), CGRectGetMidY(self.frame) - (self.config.size/2.0) - 24.0, self.config.size, self.config.size)
            if let lbl = self.titleLabel {
                lbl.textColor = self.config.titleTextColor
                lbl.font = self.config.titleTextFont
            }
        }
    }
    
    class var sharedInstance: SwiftFullScreenLoader {
        struct Singleton {
            static let instance = SwiftFullScreenLoader(frame: UIScreen.mainScreen().bounds)
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        let screenBounds = UIScreen.mainScreen().bounds
        self.loadingView = SwiftLoadingView(frame: CGRectMake(CGRectGetMidX(self.frame) - (self.config.size/2.0), CGRectGetMidY(self.frame) - (self.config.size/2.0) - 24.0, self.config.size, self.config.size))
        self.backgroundView = UIView(frame: CGRectZero)
        self.backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.backgroundView.layer.cornerRadius = 8
        self.addSubview(self.backgroundView)
        self.addSubview(self.loadingView)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        let frame = CGRectMake(CGRectGetMidX(self.frame) - (self.config.size/2.0), CGRectGetMidY(self.frame) - (self.config.size/2.0) - 24.0, self.config.size, self.config.size)
        
        var bgframe = CGRectInset(frame, -8.0, -8.0)
        self.loadingView.frame = frame
        self.backgroundView.frame = frame
        if let label = self.titleLabel {
            label.frame = CGRectMake(CGRectGetMinX(bgframe), CGRectGetMaxY(self.loadingView.frame), CGRectGetWidth(bgframe), 24.0)
            bgframe.size.height += 24.0
            self.backgroundView.frame = bgframe
        }
    }
    
    class func show(#title: String?) {
        var currentWindow : UIWindow = UIApplication.sharedApplication().windows.last as! UIWindow
        let fullScreenLoader = SwiftFullScreenLoader.sharedInstance
        fullScreenLoader.title = title

        if fullScreenLoader.superview == nil {
            currentWindow.addSubview(fullScreenLoader)
            fullScreenLoader.start()
        }
    }
    
    class func hide() {
        let loader = SwiftFullScreenLoader.sharedInstance
        loader.stop()
    }
    
    
    private func start() {
        if self.animating {
            return            
        }
        self.loadingView?.start()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1
            }, completion: { (finished) -> Void in
                self.animating = true
        });
    }
    
    private func stop() {
        if (self.superview == nil) {
            return
        }
//        if !self.animating {
//            return
//        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (finished) -> Void in
                self.removeFromSuperview()
                self.loadingView?.stop()
                self.animating = false
        });
    }
    
}



class SwiftLoader: UIView {

    private var titleLabel : UILabel?
    private var loadingView : SwiftLoadingView?
    private var animated : Bool?
    private var canUpdated = false
    private var title: String?
    
    var config : SwiftLoaderConfig = SwiftLoaderConfig() {
        didSet {
            self.loadingView?.config = config
        }
    }
    
    override var frame : CGRect {
        didSet {
            self.update()
        }
    }
    
    class var sharedInstance: SwiftLoader {
        struct Singleton {
            
            static let instance = SwiftLoader(frame: CGRectMake(0,0,SwiftLoaderConfig().size,SwiftLoaderConfig().size))
        }
        return Singleton.instance
    }
    
    class func show(#animated: Bool) {
        self.show(title: nil, animated: animated)
    }
    
    
    class func show(#title: String?, animated : Bool) {
        var currentWindow : UIWindow = UIApplication.sharedApplication().windows.last as! UIWindow
        
        let loader = SwiftLoader.sharedInstance
        loader.canUpdated = true
        loader.animated = animated
        loader.title = title
        loader.update()
        
        var height : CGFloat = UIScreen.mainScreen().bounds.size.height
        var width : CGFloat = UIScreen.mainScreen().bounds.size.width
        
        let w = ceilf(Float(width)/2.0)
        let h = ceilf(Float(height)/2.0 - Float(SwiftLoaderConfig().size)/2.0)
        
        var center : CGPoint = CGPointMake(CGFloat(w), CGFloat(h))

        loader.center = center
        
        if (loader.superview == nil) {
            currentWindow.addSubview(loader)
            loader.start()
        }
    }

    class func hide() {
        let loader = SwiftLoader.sharedInstance
        loader.stop()
    }
    
    class func setConfig(config : SwiftLoaderConfig) {
        let loader = SwiftLoader.sharedInstance
        loader.config = config
        loader.frame = CGRectMake(0,0,loader.config.size,loader.config.size)
    }
    
    /**
    Private methods
    */
    
    private func setup() {
        self.alpha = 0
        self.update()
    }
    
    private func start() {
        self.loadingView?.start()
        if (self.animated!) {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.alpha = 1
            }, completion: { (finished) -> Void in
                
            });
        } else {
            self.alpha = 1
        }
    }
    
    private func stop() {
        
        if (self.animated!) {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.alpha = 0
                }, completion: { (finished) -> Void in
                    self.removeFromSuperview()
                    self.loadingView?.stop()
            });
        } else {
            self.alpha = 0
            self.removeFromSuperview()
            self.loadingView?.stop()
        }
    }
    
    private func update() {
        self.backgroundColor = self.config.backgroundColor
        self.layer.cornerRadius = self.config.cornerRadius
        var loadingViewSize = self.frame.size.width - (loaderSpinnerMarginSide * 2)
        
        if (self.loadingView == nil) {
            self.loadingView = SwiftLoadingView(frame: self.frameForSpinner())
            self.addSubview(self.loadingView!)
        } else {
            self.loadingView?.frame = self.frameForSpinner()
        }
        
        if (self.titleLabel == nil) {
            self.titleLabel = UILabel(frame: CGRectMake(loaderTitleMargin, loaderSpinnerMarginTop + loadingViewSize, self.frame.width - loaderTitleMargin*2, 42.0))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.textAlignment = NSTextAlignment.Center
            self.titleLabel?.adjustsFontSizeToFitWidth = true
        } else {
            self.titleLabel?.frame = CGRectMake(loaderTitleMargin, loaderSpinnerMarginTop + loadingViewSize, self.frame.width - loaderTitleMargin*2, 42.0)
        }
        
        self.titleLabel?.font = self.config.titleTextFont
        self.titleLabel?.textColor = self.config.titleTextColor
        self.titleLabel?.text = self.title
        
        self.titleLabel?.hidden = self.title == nil
    }
    
    func frameForSpinner() -> CGRect {
        var loadingViewSize = self.frame.size.width - (loaderSpinnerMarginSide * 2)
        
        if (self.title == nil) {
            var yOffset = (self.frame.size.height - loadingViewSize) / 2
            return CGRectMake(loaderSpinnerMarginSide, yOffset, loadingViewSize, loadingViewSize)
        }
        return CGRectMake(loaderSpinnerMarginSide, loaderSpinnerMarginTop, loadingViewSize, loadingViewSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


/**
*  Loader View
*/
private class SwiftLoadingView : UIView {
    
    private var lineWidth : Float?
    private var lineTintColor : UIColor?
    private var backgroundLayer : CAShapeLayer?
    private var isSpinning : Bool?
    
    private var config : SwiftLoaderConfig = SwiftLoaderConfig() {
        didSet {
            self.update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
    Setup loading view
    */
    
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.lineWidth = ceilf(fmaxf(Float(self.frame.size.width) * 0.025, 1))
        
        self.backgroundLayer = CAShapeLayer()
        self.backgroundLayer?.contentsScale = UIScreen.mainScreen().scale
        self.backgroundLayer?.strokeColor = self.config.spinnerColor.CGColor
        self.backgroundLayer?.fillColor = self.backgroundColor?.CGColor
        self.backgroundLayer?.lineCap = kCALineCapRound
        self.backgroundLayer?.lineWidth = CGFloat(self.lineWidth!)
        self.layer.addSublayer(self.backgroundLayer!)
        
        let maskLayer = CALayer()
        let image = UIImage(named: "angle-mask")
        maskLayer.contents = image?.CGImage
        self.backgroundLayer?.mask = maskLayer
        
        
    }
    
    private func update() {
        self.lineWidth = self.config.spinnerLineWidth
        
        self.backgroundLayer?.lineWidth = CGFloat(self.lineWidth!)
        self.backgroundLayer?.strokeColor = self.config.spinnerColor.CGColor
    }
    
    /**
    Draw Circle
    */
    
    override func drawRect(rect: CGRect) {
        self.backgroundLayer?.frame = self.bounds
        self.backgroundLayer?.mask.frame = self.bounds
    }
    
    private func drawBackgroundCircle(partial : Bool) {
        var startAngle : CGFloat = CGFloat(M_PI) / CGFloat(2.0)
        var endAngle : CGFloat = (2.0 * CGFloat(M_PI)) + startAngle
        
        let x: Float = ceilf(Float(self.bounds.size.width / 2))
        let y: Float = ceilf(Float(self.bounds.size.height / 2.0))
        
        var center : CGPoint = CGPointMake(CGFloat(x), CGFloat(y))
        var radius : CGFloat = (CGFloat(self.bounds.size.width) - CGFloat(self.lineWidth!)) / CGFloat(2.0)
        
        var processBackgroundPath : UIBezierPath = UIBezierPath()
        processBackgroundPath.lineWidth = CGFloat(self.lineWidth!)
        
        if (partial) {
            endAngle = (1.8 * CGFloat(M_PI)) + startAngle
        }
        
        processBackgroundPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.backgroundLayer?.path = processBackgroundPath.CGPath;
    }
    
    /**
    Start and stop spinning
    */
    
    private func start() {
        self.isSpinning? = true
        self.drawBackgroundCircle(false)
        
        var rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0)
        rotationAnimation.duration = 1.0;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = HUGE;
        self.backgroundLayer?.addAnimation(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stop() {
        self.drawBackgroundCircle(false)
        
        self.backgroundLayer?.removeAllAnimations()
        self.isSpinning? = false
    }
}


/**
* Loader config
*/

struct SwiftLoaderConfig {
    
    /**
    *  Size of loader
    */
    var size : CGFloat = 120.0
    
    /**
    *  Color of spinner view
    */
    var spinnerColor = UIColor.blackColor()
    
    /**
    *  S
    */
    var spinnerLineWidth :Float = 4.0
    
    /**
    *  Color of title text
    */
    var titleTextColor = UIColor.blackColor()
    
    /**
    *  Font for title text in loader
    */
    var titleTextFont : UIFont = UIFont.boldSystemFontOfSize(16.0)
    
    /**
    *  Background color for loader
    */
    var backgroundColor = UIColor.whiteColor()
    
    /**
    *  Corner radius for loader
    */
    var cornerRadius : CGFloat = 10.0
    
}




