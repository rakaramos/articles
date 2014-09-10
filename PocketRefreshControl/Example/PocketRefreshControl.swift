//
//  PocketRefreshControl.swift
//  Pocket
//
//  Created by Wojciech Lukaszuk on 26/06/14.
//  Copyright (c) 2014 Wojciech Lukaszuk. All rights reserved.
//

import UIKit
import QuartzCore

class PocketRefreshControl: UIControl
{
    let kTotalViewHeight: CGFloat = 480.0
    let loadingTreshold: CGFloat = -90
    
    var scrollView: UIScrollView?
    var refreshAction: (() -> ())?
    var updateAction: (() -> ())?
    
    var isRefreshing = false
    var stripesLayers = [CALayer(), CALayer()]
    var stripesColors = [UIColor(red: 143/255, green: 255/255, blue: 188/255, alpha: 1),
        UIColor(red: 91/255, green: 199/255, blue: 181/255, alpha: 1),
        UIColor(red: 221/255, green: 40/255, blue: 83/255, alpha: 1),
        UIColor(red: 246/255, green: 183/255, blue: 82/255, alpha: 1)]
    
    func attachToScrollView(scrollView: UIScrollView, refreshAction: () -> (), updateAction: () -> ()) -> ()
    {
        self.scrollView = scrollView
        self.refreshAction = refreshAction
        self.updateAction = updateAction
        
        self.frame = CGRectMake(0, -kTotalViewHeight, CGRectGetWidth(scrollView.bounds), kTotalViewHeight)
        
        for stripesLayer in stripesLayers {
            
            self.pocketAppearance(stripesLayer)
            
            stripesLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
            
            self.layer.addSublayer(stripesLayer)
        }
        
        self.scrollView!.addSubview(self)
        
        self.addPullAnimation()
    }
    
    func stopRefreshAnimation() -> ()
    {
        self.isRefreshing = false
    }
    
    // pragma mark - UIScrollViewDelegate handling
    
    func scrollViewDidScroll() -> ()
    {
        var offset = self.scrollView!.contentOffset.y + self.scrollView!.contentInset.top
        
        if offset <= 0 {
            var fractionDragged = offset/self.loadingTreshold;
            var timeOffset = 1.0 < fractionDragged ? 1.0 : fractionDragged
            self.layer.timeOffset = Double(timeOffset)
        }
        
        if(offset == 0 && self.isRefreshing) {
            self.starRefreshAnimation()
        }
    }
    
    func scrollViewDidEndDragging() -> ()
    {
        var offset = self.scrollView!.contentOffset.y + self.scrollView!.contentInset.top;
        
        if offset <= loadingTreshold {
            self.isRefreshing = true
        } else {
            self.isRefreshing = false
        }
    }
    
    // pragma mark - CAAnimationDelegate
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool)
    {
        if (anim == self.stripesLayers[0].animationForKey("refreshAnimation")) {
            
            if(self.isRefreshing) {
                self.starRefreshAnimation()
            } else {
                
                self.addPullAnimation()
                
                self.scrollView!.bounces = true
                
                self.updateAction!()
            }
        }
    }
    
    // pragma mark - animations
    
    func starRefreshAnimation() -> ()
    {
        self.layer.removeAllAnimations()
        
        self.layer.speed = 1
        
        self.refreshAction!()
        
        self.scrollView!.bounces = false
        
        for i in 0..<self.stripesLayers.count {
            
            var animation  = CAKeyframeAnimation(keyPath: "position.x")
            animation.repeatCount = 1
            animation.duration = 1.5
            animation.removedOnCompletion = false;
            
            var startPosition = CGRectGetWidth(self.bounds) * (-0.5 + CGFloat(i))
            var endPosition = CGRectGetWidth(self.bounds) * (0.5 + CGFloat(i))
            animation.values = [startPosition, endPosition]
            
            animation.delegate = self
            
            stripesLayers[i].addAnimation(animation, forKey: "refreshAnimation")
        }
    }
    
    func addPullAnimation() -> ()
    {
        self.layer.removeAllAnimations()
        
        var animation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(CATransform3D :CATransform3DMakeScale(1, 1, 1))
        animation.toValue = NSValue(CATransform3D :CATransform3DMakeScale(2, 1, 1))
        animation.duration = 1.0
        
        self.layer.addAnimation(animation, forKey: nil)
        self.layer.speed = 0;
    }
    
    func pocketAppearance(layer: CALayer) -> ()
    {
        for i in 0...3 {
            
            var stripe = CALayer()
            stripe.frame = CGRectMake(CGFloat(i) * CGRectGetWidth(self.frame)/4, 0, CGRectGetWidth(self.frame)/4, CGRectGetHeight(self.frame))
            stripe.backgroundColor = stripesColors[i].CGColor
            
            layer.addSublayer(stripe)
        }
    }
    
}