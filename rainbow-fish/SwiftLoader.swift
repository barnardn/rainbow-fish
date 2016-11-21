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
    
    fileprivate var loadingView: SwiftLoadingView!
    fileprivate var titleLabel: UILabel?
    fileprivate var backgroundView: UIView!
    fileprivate var animating: Bool = false
    
    var title: String? {
        didSet {
            if self.titleLabel == nil {
                self.titleLabel = UILabel(frame: CGRect.zero)
            }
            self.titleLabel!.numberOfLines = 1
            self.titleLabel!.textAlignment = .center
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
            self.loadingView.frame = CGRect(x: self.frame.midX - (self.config.size/2.0), y: self.frame.midY - (self.config.size/2.0) - 24.0, width: self.config.size, height: self.config.size)
            if let lbl = self.titleLabel {
                lbl.textColor = self.config.titleTextColor
                lbl.font = self.config.titleTextFont
            }
        }
    }
    
    class var sharedInstance: SwiftFullScreenLoader {
        struct Singleton {
            static let instance = SwiftFullScreenLoader(frame: UIScreen.main.bounds)
        }
        return Singleton.instance
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        self.loadingView = SwiftLoadingView(frame: CGRect(x: self.bounds.midX - (self.config.size/2.0), y: self.bounds.midY - (self.config.size/2.0) - 24.0, width: self.config.size, height: self.config.size))
        self.backgroundView = UIView(frame: CGRect.zero)
        self.backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.backgroundView.layer.cornerRadius = 8
        self.addSubview(self.backgroundView)
        self.addSubview(self.loadingView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        let frame = CGRect(x: self.frame.midX - (self.config.size/2.0), y: self.frame.midY - (self.config.size/2.0) - 24.0, width: self.config.size, height: self.config.size)
        
        var bgframe = frame.insetBy(dx: -8.0, dy: -8.0)
        self.loadingView.frame = frame
        self.backgroundView.frame = frame
        if let label = self.titleLabel {
            label.frame = CGRect(x: bgframe.minX, y: self.loadingView.frame.maxY, width: bgframe.width, height: 24.0)
            bgframe.size.height += 24.0
            self.backgroundView.frame = bgframe
        }
    }
    
    class func show(title: String?) {
        let currentWindow : UIWindow = UIApplication.shared.windows.last as UIWindow!
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
    
    
    fileprivate func start() {
        if self.animating {
            return            
        }
        self.loadingView?.start()
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1
            }, completion: { (finished) -> Void in
                self.animating = true
        });
    }
    
    fileprivate func stop() {
        if (self.superview == nil) {
            return
        }
//        if !self.animating {
//            return
//        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 0
            }, completion: { (finished) -> Void in
                self.removeFromSuperview()
                self.loadingView?.stop()
                self.animating = false
        });
    }
    
}



class SwiftLoader: UIView {

    fileprivate var titleLabel : UILabel?
    fileprivate var loadingView : SwiftLoadingView?
    fileprivate var animated : Bool?
    fileprivate var canUpdated = false
    fileprivate var title: String?
    
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
            
            static let instance = SwiftLoader(frame: CGRect(x: 0,y: 0,width: SwiftLoaderConfig().size,height: SwiftLoaderConfig().size))
        }
        return Singleton.instance
    }
    
    class func show(animated: Bool) {
        self.show(title: nil, animated: animated)
    }
    
    
    class func show(title: String?, animated : Bool) {
        
        let currentWindow: UIWindow? = UIApplication.shared.windows.last as UIWindow?
        
        let loader = SwiftLoader.sharedInstance
        loader.canUpdated = true
        loader.animated = animated
        loader.title = title
        loader.update()
        
        let height : CGFloat = UIScreen.main.bounds.size.height
        let width : CGFloat = UIScreen.main.bounds.size.width
        
        let w = ceilf(Float(width)/2.0)
        let h = ceilf(Float(height)/2.0 - Float(SwiftLoaderConfig().size)/2.0)
        
        let center : CGPoint = CGPoint(x: CGFloat(w), y: CGFloat(h))

        loader.center = center
        
        if (loader.superview == nil) {
            currentWindow?.addSubview(loader)
            loader.start()
        }
    }

    class func hide() {
        let loader = SwiftLoader.sharedInstance
        loader.stop()
    }
    
    class func setConfig(_ config : SwiftLoaderConfig) {
        let loader = SwiftLoader.sharedInstance
        loader.config = config
        loader.frame = CGRect(x: 0,y: 0,width: loader.config.size,height: loader.config.size)
    }
    
    /**
    Private methods
    */
    
    fileprivate func setup() {
        self.alpha = 0
        self.update()
    }
    
    fileprivate func start() {
        self.loadingView?.start()
        if (self.animated!) {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.alpha = 1
            }, completion: { (finished) -> Void in
                
            });
        } else {
            self.alpha = 1
        }
    }
    
    fileprivate func stop() {
        
        if (self.animated!) {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
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
    
    fileprivate func update() {
        self.backgroundColor = self.config.backgroundColor
        self.layer.cornerRadius = self.config.cornerRadius
        let loadingViewSize = self.frame.size.width - (loaderSpinnerMarginSide * 2)
        
        if (self.loadingView == nil) {
            self.loadingView = SwiftLoadingView(frame: self.frameForSpinner())
            self.addSubview(self.loadingView!)
        } else {
            self.loadingView?.frame = self.frameForSpinner()
        }
        
        if (self.titleLabel == nil) {
            self.titleLabel = UILabel(frame: CGRect(x: loaderTitleMargin, y: loaderSpinnerMarginTop + loadingViewSize, width: self.frame.width - loaderTitleMargin*2, height: 42.0))
            self.addSubview(self.titleLabel!)
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.textAlignment = NSTextAlignment.center
            self.titleLabel?.adjustsFontSizeToFitWidth = true
        } else {
            self.titleLabel?.frame = CGRect(x: loaderTitleMargin, y: loaderSpinnerMarginTop + loadingViewSize, width: self.frame.width - loaderTitleMargin*2, height: 42.0)
        }
        
        self.titleLabel?.font = self.config.titleTextFont
        self.titleLabel?.textColor = self.config.titleTextColor
        self.titleLabel?.text = self.title
        
        self.titleLabel?.isHidden = self.title == nil
    }
    
    func frameForSpinner() -> CGRect {
        let loadingViewSize = self.frame.size.width - (loaderSpinnerMarginSide * 2)
        
        if (self.title == nil) {
            let yOffset = (self.frame.size.height - loadingViewSize) / 2
            return CGRect(x: loaderSpinnerMarginSide, y: yOffset, width: loadingViewSize, height: loadingViewSize)
        }
        return CGRect(x: loaderSpinnerMarginSide, y: loaderSpinnerMarginTop, width: loadingViewSize, height: loadingViewSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


/**
*  Loader View
*/
private class SwiftLoadingView : UIView {
    
    fileprivate var lineWidth : Float?
    fileprivate var lineTintColor : UIColor?
    fileprivate var backgroundLayer : CAShapeLayer?
    fileprivate var isSpinning : Bool?
    
    fileprivate var config : SwiftLoaderConfig = SwiftLoaderConfig() {
        didSet {
            self.update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
    Setup loading view
    */
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        self.lineWidth = ceilf(fmaxf(Float(self.frame.size.width) * 0.025, 1))
        
        self.backgroundLayer = CAShapeLayer()
        self.backgroundLayer?.contentsScale = UIScreen.main.scale
        self.backgroundLayer?.strokeColor = self.config.spinnerColor.cgColor
        self.backgroundLayer?.fillColor = self.backgroundColor?.cgColor
        self.backgroundLayer?.lineCap = kCALineCapRound
        self.backgroundLayer?.lineWidth = CGFloat(self.lineWidth!)
        self.layer.addSublayer(self.backgroundLayer!)
        
        let maskLayer = CALayer()
        let image = UIImage(named: "angle-mask")
        maskLayer.contents = image?.cgImage
        self.backgroundLayer?.mask = maskLayer
        
        
    }
    
    fileprivate func update() {
        self.lineWidth = self.config.spinnerLineWidth
        
        self.backgroundLayer?.lineWidth = CGFloat(self.lineWidth!)
        self.backgroundLayer?.strokeColor = self.config.spinnerColor.cgColor
    }
    
    /**
    Draw Circle
    */
    
    override func draw(_ rect: CGRect) {
        self.backgroundLayer?.frame = self.bounds
        self.backgroundLayer?.mask!.frame = self.bounds
    }
    
    fileprivate func drawBackgroundCircle(_ partial : Bool) {
        let startAngle : CGFloat = CGFloat(M_PI) / CGFloat(2.0)
        var endAngle : CGFloat = (2.0 * CGFloat(M_PI)) + startAngle
        
        let x: Float = ceilf(Float(self.bounds.size.width / 2))
        let y: Float = ceilf(Float(self.bounds.size.height / 2.0))
        
        let center : CGPoint = CGPoint(x: CGFloat(x), y: CGFloat(y))
        let radius : CGFloat = (CGFloat(self.bounds.size.width) - CGFloat(self.lineWidth!)) / CGFloat(2.0)
        
        let processBackgroundPath : UIBezierPath = UIBezierPath()
        processBackgroundPath.lineWidth = CGFloat(self.lineWidth!)
        
        if (partial) {
            endAngle = (1.8 * CGFloat(M_PI)) + startAngle
        }
        
        processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.backgroundLayer?.path = processBackgroundPath.cgPath;
    }
    
    /**
    Start and stop spinning
    */
    
    fileprivate func start() {
        self.isSpinning? = true
        self.drawBackgroundCircle(false)
        
        let rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: M_PI * 2.0 as Double)
        rotationAnimation.duration = 1.0;
        rotationAnimation.isCumulative = true;
        rotationAnimation.repeatCount = HUGE;
        self.backgroundLayer?.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    fileprivate func stop() {
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
    var spinnerColor = UIColor.black
    
    /**
    *  S
    */
    var spinnerLineWidth :Float = 4.0
    
    /**
    *  Color of title text
    */
    var titleTextColor = UIColor.black
    
    /**
    *  Font for title text in loader
    */
    var titleTextFont : UIFont = UIFont.boldSystemFont(ofSize: 16.0)
    
    /**
    *  Background color for loader
    */
    var backgroundColor = UIColor.white
    
    /**
    *  Corner radius for loader
    */
    var cornerRadius : CGFloat = 10.0
    
}




