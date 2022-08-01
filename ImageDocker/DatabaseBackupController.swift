//
//  DatabaseBackupController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2022/2/13.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Cocoa

final class DatabaseBackupController: NSViewController {
    
    let logger = ConsoleLogger(category: "DatabaseBackupController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
