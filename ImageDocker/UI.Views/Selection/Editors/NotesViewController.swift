//
//  NotesViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/10/11.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class NotesViewController: NSViewController {
    
    // MARK: CONTROLS
    
    @IBOutlet weak var chkBrief: NSButton!
    @IBOutlet weak var chkDetailed: NSButton!
    @IBOutlet weak var txtBrief: NSTextField!
    @IBOutlet weak var txtDetailed: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    
    
    // MARK: INIT
    
    init(){
        super.init(nibName: "NotesViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate var onCompleted: (() -> Void)?
    fileprivate var images:[ImageFile] = []
    
    func loadFrom(images:[ImageFile], onApplyChanges: (() -> Void)? = nil ){
        self.onCompleted = onApplyChanges
        self.images = images
        
        self.txtBrief.stringValue = ""
        self.txtDetailed.stringValue = ""
        self.txtBrief.placeholderString = ""
        self.txtDetailed.placeholderString = ""
        
        var briefs:Set<String> = []
        var details:Set<String> = []
        for img in images {
            if let image = img.imageData {
                if let brief = image.shortDescription {
                    briefs.insert(brief)
                }else{
                    briefs.insert("")
                }
                if let detail = image.longDescription {
                    details.insert(detail)
                }else{
                    details.insert("")
                }
            }
        }
        if briefs.count > 0 {
            if briefs.count == 1 {
                self.txtBrief.stringValue = briefs.first!
                self.txtBrief.placeholderString = briefs.first!
            }else{
                self.txtBrief.placeholderString = "<multiple values>"
            }
        }
        if details.count > 0 {
            if details.count == 1 {
                self.txtDetailed.stringValue = details.first!
                self.txtDetailed.placeholderString = details.first!
            }else{
                self.txtDetailed.placeholderString = "<multiple values>"
            }
        }
    }
    
    // MARK: ACTION
    
    fileprivate var accumulator:Accumulator?
    
    @IBAction func onOKClicked(_ sender: NSButton) {
        guard self.chkBrief.state == .on || self.chkDetailed.state == .on else {
            return
        }
        self.btnOK.isEnabled = false
        
        self.accumulator = Accumulator(target: self.images.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
        
        let brief:String? = self.chkBrief.state == .on ? self.txtBrief.stringValue : nil
        let detailed:String? = self.chkDetailed.state == .on ? self.txtDetailed.stringValue : nil
        
        DispatchQueue.global().async {
            for image in self.images {
                if let img = image.imageData {
                    
                    ModelStore.default.storeImageDescription(path: img.path,
                                                             shortDescription: brief,
                                                             longDescription: detailed)
                    
                }
                
                DispatchQueue.main.async {
                    let _ = self.accumulator?.add("")
                }
            }
            DispatchQueue.main.async {
                self.btnOK.isEnabled = true
                if self.onCompleted != nil {
                    self.onCompleted!()
                }
            }
        }
    }
    
}
