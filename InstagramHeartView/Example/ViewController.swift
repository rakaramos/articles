//
//  ViewController.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 27/08/14.
//  Copyright (c) 2014 Wojtek Lukaszuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var heartView: WavyView!
    @IBOutlet weak var likeButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handlePhotoLongPress:")
        photoImageView.addGestureRecognizer(gestureRecognizer)
        
        self.setupLikeButton()
    }
    
    func handlePhotoLongPress(recognizer: UILongPressGestureRecognizer) -> ()
    {
        if recognizer.state == UIGestureRecognizerState.Began {
            
            self.heartView.startWavyAnimation {
                
                [unowned self] in
                self.likeButton.selected = true
            }
            
            return;
        }
        
        if recognizer.state == UIGestureRecognizerState.Cancelled
            || recognizer.state == UIGestureRecognizerState.Ended {
            
            self.heartView.stopAnimation()
        }
    }
    
    func setupLikeButton() -> ()
    {
        var normalBackgroundImage = UIImage.imageWithColor(UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0))
        var highlightedBackgroundImage = UIImage.imageWithColor(UIColor(red: 159.0/255.0, green: 161.0/255.0, blue: 163.0/255.0, alpha: 1.0))
        
        likeButton.setBackgroundImage(normalBackgroundImage, forState: UIControlState.Normal)
        likeButton.setBackgroundImage(highlightedBackgroundImage, forState: UIControlState.Highlighted)
        likeButton.setBackgroundImage(highlightedBackgroundImage, forState: UIControlState.Selected)
    }
}