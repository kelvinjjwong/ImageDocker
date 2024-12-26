//
//  DatabaseProfileFlowListItemController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/11/20.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa
import PostgresModelFactory

class DatabaseProfileFlowListItemController : NSViewController {
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var lblStatus1: NSTextField!
    @IBOutlet weak var lblStatus2: NSTextField!
    @IBOutlet weak var lblContent: NSTextField!
    @IBOutlet weak var checkbox: NSButton!
    @IBOutlet weak var btnEdit: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
    
    var status1 = ""
    var status2 = ""
    var checkState = false
    
    var data:DatabaseProfile?
    var onSelect:(() -> Void)?
    var onEdit:(() -> Void)?
    var onDelete:(() -> Void)?
    
    init() {
        super.init(nibName: "DatabaseProfileFlowListItemController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.wantsLayer = true
        
        self.lblContent.stringValue = "\(self.data?.database ?? "") @ \(self.data?.host ?? "")"
        self.lblStatus1.stringValue = status1
        self.lblStatus2.stringValue = status2
        self.checkbox.state = checkState ? .on : .off
        
        switch(self.data?.engine.lowercased() ?? "") {
            case "postgresql":
                self.imageView.image = Icons.database_postgresql
                break
            case "mysql":
                self.imageView.image = Icons.database_mysql
                break
            default:
                break
        }
        
    }
    
    func initView(databaseProfile:DatabaseProfile, status1:String = "", status2:String = "", checkState:Bool = false,
                  onSelect:(() -> Void)? = nil,
                  onEdit:(() -> Void)? = nil,
                  onDelete:(() -> Void)? = nil) {
        self.data = databaseProfile
//        self.imageView.image = nsImage
        self.status1 = status1
        self.status2 = status2
        self.checkState = checkState
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    @IBAction func onSelectClicked(_ sender: NSButton) {
        self.onSelect?()
    }
    
    
    @IBAction func onEditClicked(_ sender: NSButton) {
        self.onEdit?()
    }
    
    @IBAction func onDeleteClicked(_ sender: NSButton) {
        self.onDelete?()
    }
    
}
