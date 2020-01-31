//
//  ContainerViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/15.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class ContainerViewController: NSViewController {
    
    var container:ImageContainer? = nil
    
    // MARK: CONTROLS
    
    @IBOutlet weak var lblPath: NSTextField!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnStat: NSButton!
    @IBOutlet weak var btnShowHide: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    
    
    // MARK: INIT
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "ContainerViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initContainer(path:String){
        if let container = ModelStore.default.getContainer(path: path) {
            self.container = container
            self.lblPath.stringValue = path
            if container.hiddenByContainer {
                self.btnShowHide.title = "Show Images"
            }else{
                self.btnShowHide.title = "Hide Images"
            }
            self.stat()
        }else{
            self.lblMessage.stringValue = "ERROR: Invalid container path: \(path)"
            print("invalid container path: \(path)")
        }
    }
    
    fileprivate func stat() {
        var msg = ""
        if let container = self.container {
            msg = "Hidden: \(container.hiddenByContainer), Hidden by Repository: \(container.hiddenByRepository)"
        }else{
            msg = "ERROR: Container info not loaded."
        }
        self.lblMessage.stringValue = msg
    }
    
    // MARK: ACTIONS
    
    @IBAction func onStatClicked(_ sender: NSButton) {
        self.stat()
    }
    
    @IBAction func onShowHideClicked(_ sender: NSButton) {
        if let container = self.container {
            if container.hiddenByContainer {
                ModelStore.default.showContainer(path: container.path)
                self.container?.hiddenByContainer = false
                self.btnShowHide.title = "Hide Images"
            }else{
                ModelStore.default.hideContainer(path: container.path)
                self.container?.hiddenByContainer = true
                self.btnShowHide.title = "Show Images"
            }
            self.stat()
        }else{
            self.lblMessage.stringValue = "ERROR: Container info not loaded."
        }
    }
    
    @IBAction func onGotoClicked(_ sender: NSButton) {
        if let container = self.container {
            if FileManager.default.fileExists(atPath: container.path) {
                let url = URL(fileURLWithPath: container.path)
                NSWorkspace.shared.activateFileViewerSelecting([url])
            }else{
                self.lblMessage.stringValue = "ERROR: Container path doesn't exist."
            }
        }else{
            self.lblMessage.stringValue = "ERROR: Container info not loaded."
        }
    }
    
}
