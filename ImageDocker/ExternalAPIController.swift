//
//  ExternalAPIController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2022/2/12.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Cocoa

final class ExternalAPIController: NSViewController {
    
    let logger = ConsoleLogger(category: "ExternalAPIController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
