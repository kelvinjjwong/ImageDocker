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
    @IBOutlet weak var lblContent2: NSTextField!
    
    var status1 = ""
    var status2 = ""
    
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
        
        self.reloadControls()
    }
    
    func reloadControls() {
        self.lblContent.stringValue = "\(self.data?.host ?? ""):\(self.data?.port ?? -9999) \(self.data?.ssl ?? false ? "(ssl)" : "")"
        self.lblContent2.stringValue = "\(self.data?.user ?? ""):\(self.data?.database ?? "")"
        self.lblStatus1.stringValue = status1
        self.lblStatus2.stringValue = status2
        self.checkbox.state = (self.data?.selected ?? false) ? .on : .off
        
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
        
        if status1.starts(with: "Un") {
            self.lblStatus1.textColor = Colors.Red
        }else if status1 == "Connectable" {
            self.lblStatus1.textColor = Colors.Green
        }else{
            self.lblStatus1.textColor = Colors.White
        }
    }
    
    func initView(databaseProfile:DatabaseProfile, status1:String = "", status2:String = "",
                  onSelect:(() -> Void)? = nil,
                  onEdit:(() -> Void)? = nil,
                  onDelete:(() -> Void)? = nil) {
        self.data = databaseProfile
//        self.imageView.image = nsImage
        self.status1 = status1
        self.status2 = status2
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    func updateFields(databaseProfile:DatabaseProfile) {
        self.data = databaseProfile
        self.reloadControls()
    }
    
    func updateStatus1(_ value:String) {
        self.status1 = value
        self.reloadControls()
    }
    
    func updateStatus2(_ value:String) {
        self.status2 = value
        self.reloadControls()
    }
    
    func select() {
        self.checkbox.state = .on
        self.data?.selected = true
    }
    
    func unselect() {
        self.checkbox.state = .off
        self.data?.selected = false
    }
    
    func isConnectable() -> Bool {
        return self.lblStatus1.stringValue == "Connectable"
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
