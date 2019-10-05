//
//  ExportProfileViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ExportProfileViewController : NSViewController {
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblDirectory: NSTextField!
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var btnEdit: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var lblRepository: NSTextField!
    @IBOutlet weak var lblDuplicatedStrategy: NSTextField!
    @IBOutlet weak var lblEXIFPatching: NSTextField!
    @IBOutlet weak var lblSubFolder: NSTextField!
    
    var onEdit: (() -> Void)? = nil
    
    var onDelete: (() -> Void)? = nil
    
    init() {
        super.init(nibName: NSNib.Name(rawValue: "ExportProfileViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("export profile view didload")
        
        view.wantsLayer = true
        self.lblName.stringValue = name
        self.lblDirectory.stringValue = path
        self.lblDescription.stringValue = options
    }
    
    var id = ""
    var name = ""
    var path = ""
    var options = ""
    
    func initView(id:String, name:String, path:String, options:String,
                  onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil){
        self.id = id
        self.name = name
        self.path = path
        self.options = options
        self.onEdit = onEdit
        self.onDelete = onDelete
        print("init profile view id=\(id) name=\(name)")
    }
    
    @IBAction func onEditClicked(_ sender: NSButton) {
        print("edit profile \(id) -> \(name)")
        if onEdit != nil {
            onEdit!()
        }
    }
    
    @IBAction func onDeleteClicked(_ sender: NSButton) {
        print("delete profile \(id) -> \(name)")
        if onDelete != nil {
            onDelete!()
        }
    }
    
}
