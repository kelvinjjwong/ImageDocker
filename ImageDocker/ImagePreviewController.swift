//
//  ImagePreviewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/26.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa

class ImagePreviewController : NSViewController {
    
    @IBOutlet weak var playerContainer: NSView!
    @IBOutlet weak var lblDescription: NSTextField!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
