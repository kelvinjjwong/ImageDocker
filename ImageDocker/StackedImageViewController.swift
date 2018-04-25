//
//  StackedImageViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/24.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class StackedImageViewController: NSViewController {
    
    @IBOutlet weak var imageDisplayer: ImageDropView!
    
    var parentController:DropPlaceDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageDisplayer.dropDelegate = self
        // Do view setup here.
    }
    
}

extension StackedImageViewController: DropPlaceDelegate {
    func dropURLs(_ urls: [URL]) {
        parentController?.dropURLs(urls)
    }
}
