//
//  TreeTableCellView.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/11/2.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa



class KSTableCellView: NSTableCellView {
    
    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet weak var txtField: NSTextField!
    @IBOutlet weak var valueField: NSTextField!
    @IBOutlet weak var button: NSButton!
    
    var collection:TreeCollection?
    var buttonAction:((TreeCollection,NSButton) -> Void)?
    
    @IBAction func onClicked(_ sender: NSButton) {
        if self.buttonAction != nil, let c = self.collection {
            self.buttonAction!(c, sender)
        }
    }
}

class KSTableActionCellView: NSTableCellView {
    @IBOutlet weak var button: NSButton!
    
    var collection:TreeCollection?
    var buttonAction:((TreeCollection,NSButton) -> Void)?
    
    @IBAction func onClicked(_ sender: NSButton) {
        if self.buttonAction != nil, let c = self.collection {
            self.buttonAction!(c, sender)
        }
    }
    
}
