//
//  KenBurnsView.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 19/09/14.
//  Copyright (c) 2014 Wojtek Lukaszuk. All rights reserved.
//

import UIKit
import AVFoundation

class KenBurnsView: UIView
{
    private var images: [UIImage] = []
    private var isLooped: Bool = false
    private var duration: NSTimeInterval = 0
    private var imageIndex: Int = 0
    private var finished: Bool = false
    
    internal func animateWithImages(images: [UIImage], duration: NSTimeInterval, isLooped: Bool)
    {
        self.images = images
        self.isLooped = isLooped
        self.duration = duration
        self.imageIndex = 0
        
        self.startAnimation(false)
    }
    
    internal func stopAnimation()
    {
        self.finished = true
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        
        if self.finished == false {
            self.startAnimation(true)
        }
    }
    
    private func startAnimation(transition: Bool)
    {
        var image = self.images[self.imageIndex]
        
        // image size without changing the aspect ratio
        let size = AVMakeRectWithAspectRatioInsideRect(image.size, self.bounds)
        
        // scaled image size
        var imageHeight = size.height * 1.1
        var imageWidth = size.width * 1.1
        
        // max translate
        var maxTranslateX = imageWidth - self.bounds.width
        var maxTranslateY = imageHeight - self.bounds.height
        
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        var translateX: CGFloat = 0
        var translateY: CGFloat = 0
        var zoom: CGFloat = 1.1 + CGFloat(arc4random()%10)/100
        var rotation: CGFloat = CGFloat(arc4random()%5)/100
        
        var translateAnimationType: Int = Int(arc4random()%4)
        
        // set translate properties
        switch(translateAnimationType) {
            
        case 0:
            originX = 0
            originY = 0
            translateX = -maxTranslateX
            translateY = -maxTranslateY
        case 1:
            originX = 0
            originY = self.bounds.height - imageHeight
            translateX = -maxTranslateX
            translateY = maxTranslateY - tan(rotation) * imageHeight
            
        case 2:
            originX = self.bounds.width - imageWidth
            originY = 0
            translateX = maxTranslateX - tan(rotation) * imageHeight
            translateY = -maxTranslateY
        case 3:
            originX = self.bounds.width - imageWidth
            originY = self.bounds.height - imageHeight
            translateX = maxTranslateX - tan(rotation) * imageHeight
            translateY = maxTranslateY - tan(rotation) * imageWidth
        default:
            originX = 0
            originY = self.bounds.height - imageHeight
            translateX = -maxTranslateX
            translateY = maxTranslateY - tan(rotation) * imageHeight
        }
        
        // remove all sublayers
        self.layer.sublayers = nil
        
        // create image layer
        var imageLayer = CALayer()
        imageLayer.contents = image.CGImage
        imageLayer.anchorPoint = CGPointMake(0, 0)
        imageLayer.bounds = CGRectMake(0, 0, imageWidth, imageHeight)
        imageLayer.position = CGPointMake(originX, originY)
        self.layer.addSublayer(imageLayer)
        
        // calculate Ken Burns final transform
        var transform = CATransform3DMakeTranslation(translateX, translateY, 0)
        transform = CATransform3DRotate(transform, rotation, 0, 0, 1)
        transform = CATransform3DScale(transform, zoom, zoom, zoom)
        
        // Ken Burns animation
        var kenBurnsAnimation = CABasicAnimation(keyPath: "transform")
        kenBurnsAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        kenBurnsAnimation.duration = self.duration
        kenBurnsAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        kenBurnsAnimation.setValue("kenBurnsAnimation", forKey: "animationType")
        kenBurnsAnimation.delegate = self
        imageLayer.addAnimation(kenBurnsAnimation, forKey: nil)
        imageLayer.transform = transform
        
        if transition == true {
            var transition = CATransition()
            transition.duration = 1
            transition.type = kCATransitionFade
            self.layer.addAnimation(transition, forKey: nil)
        }
        
        // handle image index
        if self.imageIndex == self.images.count-1 {
            
            if self.isLooped == false {
                self.finished = true
            }
            
            self.imageIndex = 0
            
            return
        }
        
        self.imageIndex++
    }
}