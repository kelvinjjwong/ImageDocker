//
//  MomentsTreeHeaderMoreViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/7/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

class MomentsTreeHeaderMoreViewController: NSViewController {
    
    @IBOutlet weak var btnReload: NSButton!

    var onReload: (() -> Void)? = nil
    
    init(onReload: (() -> Void)? = nil) {
        super.init(nibName: "MomentsTreeHeaderMoreViewController", bundle: nil)
        self.onReload = onReload
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnReload.title = Words.tree_reload_tree.word()
    }
    
    @IBAction func onReloadClicked(_ sender: NSButton) {
        if self.onReload != nil {
            self.onReload!()
        }
    }
    
    
}
