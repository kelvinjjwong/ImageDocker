//
//  StackedVideoViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/24.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class StackedVideoViewController: NSViewController {
    
    @IBOutlet weak var videoDisplayer: VideoDropView!
    
    var parentController:DropPlaceDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoDisplayer.dropDelegate = self
        
        // Do view setup here.
    }
    
}

extension StackedVideoViewController: DropPlaceDelegate {
    func dropURLs(_ urls: [URL]) {
        parentController?.dropURLs(urls)
    }
}
