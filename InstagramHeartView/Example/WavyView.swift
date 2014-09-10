//
//  WavyView.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 27/08/14.
//  Copyright (c) 2014 Wojtek Lukaszuk. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class WavyView: UIView
{
    internal var maskLayer: CALayer!
    internal var waveColor: UIColor!
    
    private var waveLayer: CAShapeLayer = CAShapeLayer()
    private var animations: [CAAnimation] = []
    private var completionBlock: (() -> ())?
    
    private let kFadeInAnimationKey = "fadeInAnimationKey"
    private let kFadeOutAnimationKey = "fadeOutAnimationKey"
    private let kWavesAnimationKey = "wavesAnimationKey"
    private let kScaleUpAnimationKey = "scaleupAnimationKey"
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.setUp()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.setUp()
    }
    
    private func setUp() -> ()
    {
        self.layer.opacity = 0
        self.waveColor = UIColor(white: 1.0, alpha: 0.95)
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        self.layer.mask = self.defaultMaskLayer()
        
        self.waveLayer.bounds = CGRectMake(0, 0, 216, 85)
        self.waveLayer.anchorPoint = CGPointMake(0, 0)
        self.waveLayer.position = CGPointMake(0, self.frame.height)
        self.waveLayer.path = self.wavePath()
        self.waveLayer.fillColor = self.waveColor.CGColor
        self.layer.addSublayer(waveLayer)
    }
    
    func defaultMaskLayer() -> CALayer
    {
        var layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = self.heartPath()
        
        return layer
    }
    
    //PRAGMA: sequential animations handling
    
    internal func startWavyAnimation(completionBlock: () -> ()) -> ()
    {
        self.layer.opacity = 0
        self.waveLayer.position = CGPointMake(0, self.frame.height)
        self.layer.transform = CATransform3DIdentity
        
        self.completionBlock = completionBlock
        self.animations = [self.fadeInAnimation(), self.wavesAnimation(), self.scaleUpAnimation(), self.fadeOutAnimation()]
        self.startNextAnimation()
    }
    
    private func startNextAnimation() -> ()
    {
        if self.animations.count == 0 {
            self.layer.removeAllAnimations()
            self.waveLayer.removeAllAnimations()
            
            self.completionBlock!()
            
            return
        }
        
        var animation = animations[0]
        animation.valueForKey("layer").addAnimation(animation, forKey: animation.valueForKey("key") as String)
        self.animations.removeAtIndex(0)
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool)
    {
        if flag == true {
            self.startNextAnimation()
        }
    }
    
    func stopAnimation() -> ()
    {
        if self.animations.count > 0 {
            
            // get values from presentation layer
            var presentationLayer = self.layer.presentationLayer() as CALayer
            var wavePresentationLayer = self.waveLayer.presentationLayer() as CALayer
            
            var waveLayerPosition = wavePresentationLayer.position
            var transform = presentationLayer.transform
            var opacity = presentationLayer.opacity
            
            // remove animations
            self.layer.removeAnimationForKey(kFadeInAnimationKey)
            self.layer.removeAnimationForKey(kFadeOutAnimationKey)
            self.layer.removeAnimationForKey(kScaleUpAnimationKey)
            self.waveLayer.removeAnimationForKey(kWavesAnimationKey)
            self.animations.removeAll(keepCapacity: false)
            
            // update model
            self.waveLayer.position = waveLayerPosition
            self.layer.opacity = presentationLayer.opacity
            self.layer.transform = transform
            
            // add opacity animation
            var opacityAnimation  = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = self.layer.opacity
            opacityAnimation.duration = 0.2
            self.layer.addAnimation(opacityAnimation, forKey: nil)

            self.layer.opacity = 0
        }
    }
    
    
    //MARK: animations
    
    private func fadeInAnimation() -> CAAnimation
    {
        var opacityAnimation  = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.duration = 0.25
        
        var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = 0.25
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        var animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.25
        animationGroup.delegate = self
        animationGroup.removedOnCompletion = false
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.animations = [opacityAnimation, scaleAnimation]
        animationGroup.setValue(self, forKey: "layer")
        animationGroup.setValue(kFadeInAnimationKey, forKey: "key")

        return animationGroup
    }
    
    private func wavesAnimation() -> CAAnimation
    {
        var positionYAnimation = CABasicAnimation(keyPath: "position.y")
        positionYAnimation.fromValue = self.frame.height
        positionYAnimation.toValue = self.frame.height - self.waveLayer.bounds.height
        positionYAnimation.duration = 1
        positionYAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        var positionXAnimation = CABasicAnimation(keyPath: "position.x")
        positionXAnimation.fromValue = 0
        positionXAnimation.toValue = self.bounds.width - self.waveLayer.bounds.width
        positionXAnimation.duration = 1
        positionYAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        var animationGroup = CAAnimationGroup()
        animationGroup.duration = 1
        animationGroup.delegate = self
        animationGroup.removedOnCompletion = false
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.animations = [positionXAnimation, positionYAnimation]
        animationGroup.beginTime = CACurrentMediaTime() - 0.05
        animationGroup.setValue(self.waveLayer, forKey: "layer")
        animationGroup.setValue(kWavesAnimationKey, forKey: "key")
        
        return animationGroup
    }
    
    private func scaleUpAnimation() -> CAAnimation
    {
        var scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleUpAnimation.fromValue = 1.0
        scaleUpAnimation.toValue = 1.08
        scaleUpAnimation.duration = 0.3
        scaleUpAnimation.delegate = self
        scaleUpAnimation.removedOnCompletion = false
        scaleUpAnimation.fillMode = kCAFillModeForwards
        scaleUpAnimation.setValue(self, forKey: "layer")
        scaleUpAnimation.setValue(kScaleUpAnimationKey, forKey: "key")
        
        return scaleUpAnimation
    }
    
    private func fadeOutAnimation() -> CAAnimation
    {
        var opacityAnimation  = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 0.3

        var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.08
        scaleAnimation.toValue = 0.6
        scaleAnimation.duration = 0.3
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        var animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.3
        animationGroup.delegate = self
        animationGroup.removedOnCompletion = false
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.animations = [opacityAnimation, scaleAnimation]
        animationGroup.setValue(self, forKey: "layer")
        animationGroup.setValue(kFadeOutAnimationKey, forKey: "key")

        return animationGroup
    }
    
    //MARK: custom paths
    
    private func wavePath() -> CGPath
    {
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(216, 7))
        bezierPath.addCurveToPoint(CGPointMake(202, 12), controlPoint1: CGPointMake(212, 9), controlPoint2: CGPointMake(208, 12))
        bezierPath.addCurveToPoint(CGPointMake(182, 6), controlPoint1: CGPointMake(191, 12), controlPoint2: CGPointMake(191, 6))
        bezierPath.addCurveToPoint(CGPointMake(163, 12), controlPoint1: CGPointMake(173, 6), controlPoint2: CGPointMake(173, 12))
        bezierPath.addCurveToPoint(CGPointMake(122, 0), controlPoint1: CGPointMake(146, 12), controlPoint2: CGPointMake(143, 0))
        bezierPath.addCurveToPoint(CGPointMake(82, 12), controlPoint1: CGPointMake(102, 0), controlPoint2: CGPointMake(99, 12))
        bezierPath.addCurveToPoint(CGPointMake(63, 6), controlPoint1: CGPointMake(72, 12), controlPoint2: CGPointMake(71, 6))
        bezierPath.addLineToPoint(CGPointMake(63, 6))
        bezierPath.addCurveToPoint(CGPointMake(63, 6), controlPoint1: CGPointMake(63, 6), controlPoint2: CGPointMake(63, 6))
        bezierPath.addCurveToPoint(CGPointMake(63, 6), controlPoint1: CGPointMake(63, 6), controlPoint2: CGPointMake(63, 6))
        bezierPath.addLineToPoint(CGPointMake(63, 6))
        bezierPath.addCurveToPoint(CGPointMake(44, 12), controlPoint1: CGPointMake(54, 6), controlPoint2: CGPointMake(54, 12))
        bezierPath.addCurveToPoint(CGPointMake(19, 3), controlPoint1: CGPointMake(33, 12), controlPoint2: CGPointMake(28, 3))
        bezierPath.addCurveToPoint(CGPointMake(0, 9), controlPoint1: CGPointMake(10, 3), controlPoint2: CGPointMake(10, 9))
        bezierPath.addLineToPoint(CGPointMake(0, 85))
        bezierPath.addLineToPoint(CGPointMake(24, 85))
        bezierPath.addLineToPoint(CGPointMake(43, 85))
        bezierPath.addLineToPoint(CGPointMake(62, 85))
        bezierPath.addLineToPoint(CGPointMake(62, 85))
        bezierPath.addLineToPoint(CGPointMake(122, 85))
        bezierPath.addLineToPoint(CGPointMake(182, 85))
        bezierPath.addLineToPoint(CGPointMake(202, 85))
        bezierPath.addLineToPoint(CGPointMake(216, 85))
        bezierPath.addLineToPoint(CGPointMake(216, 7))
        bezierPath.closePath()

        return bezierPath.CGPath
    }
    
    private func heartPath() -> CGPath
    {
        var bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(84, 28))
        bezierPath.addCurveToPoint(CGPointMake(60, 0), controlPoint1: CGPointMake(84, 2), controlPoint2: CGPointMake(65, 0))
        bezierPath.addCurveToPoint(CGPointMake(42, 11), controlPoint1: CGPointMake(46, 0), controlPoint2: CGPointMake(42, 11))
        bezierPath.addCurveToPoint(CGPointMake(24, 0), controlPoint1: CGPointMake(42, 11), controlPoint2: CGPointMake(38, 0))
        bezierPath.addCurveToPoint(CGPointMake(0, 28), controlPoint1: CGPointMake(19, 0), controlPoint2: CGPointMake(0, 2))
        bezierPath.addCurveToPoint(CGPointMake(42, 73), controlPoint1: CGPointMake(0, 55), controlPoint2: CGPointMake(40, 73))
        bezierPath.addLineToPoint(CGPointMake(42, 73))
        bezierPath.addLineToPoint(CGPointMake(42, 73))
        bezierPath.addLineToPoint(CGPointMake(42, 73))
        bezierPath.addLineToPoint(CGPointMake(42, 73))
        bezierPath.addCurveToPoint(CGPointMake(84, 27), controlPoint1: CGPointMake(43, 73), controlPoint2: CGPointMake(84, 55))
        bezierPath.closePath()
        
        return bezierPath.CGPath
    }
}