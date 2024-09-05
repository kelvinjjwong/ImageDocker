//
//  ImageFlowListItemViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/5.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa

class ImageFlowListItemViewController : NSViewController {
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var lblDateTime: NSTextField!
    @IBOutlet weak var lblContent: NSTextField!
    
    
    init() {
        super.init(nibName: "ExportProfileViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.wantsLayer = true
        
    }
    
    func initView(image:Image, nsImage:NSImage, dateTime:String, content:String) {
        self.imageView.image = nsImage
        self.lblDateTime.stringValue = dateTime
        self.lblContent.stringValue = content
    }
}
