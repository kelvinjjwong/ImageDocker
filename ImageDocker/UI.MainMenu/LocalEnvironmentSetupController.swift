//
//  LocalEnvironmentSetupController.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/4.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

final class LocalEnvironmentSetupController: NSViewController {
    
    let logger = ConsoleLogger(category: "LocalEnvironmentSetupController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
