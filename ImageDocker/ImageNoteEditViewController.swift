//
//  ImageNoteEditViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/3.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa
import WebKit
import LoggerFactory

class ImageNoteEditViewController : NSViewController {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "EditNote")
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
