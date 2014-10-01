//
//  ViewController.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 19/09/14.
//  Copyright (c) 2014 Wojtek Lukaszuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var kenBurnsView: KenBurnsView!
   
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        var images = [UIImage(named:"img_login1"),
            UIImage(named:"img_login2"),
            UIImage(named:"img_login3"),
            UIImage(named:"img_login4")]
        
        self.kenBurnsView.animateWithImages(images, duration: 8, isLooped: true)
    }
}

