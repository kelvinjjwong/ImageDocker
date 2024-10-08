//
//  ImageEditTabViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/2.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class ImageEditTabViewController : NSViewController {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "EditTabs")
    
    @IBOutlet weak var tabs: NSTabView!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
