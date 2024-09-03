//
//  ImageMetaViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/26.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class ImageMetaViewController : NSViewController {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "ViewMeta")
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: DarkTableView!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    }
    
    
}
