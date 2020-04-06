//
//  FilterViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/7/4.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class FilterViewController: NSViewController {
    
    // MARK: Tables
    
    @IBOutlet weak var imageSourceTable: NSTableView!
    @IBOutlet weak var cameraModelTable: NSTableView!
    private var imageSourceTableController:CheckTableViewController?
    private var cameraModelTableController:CheckTableViewController?
    var onApply: ((_ imageSource:[String], _ cameraModel:[String]) -> Void)?
    
    init(onApply: ((_ imageSource:[String], _ cameraModel:[String]) -> Void)? = nil){
        super.init(nibName: "FilterViewController", bundle: nil)
        self.onApply = onApply
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        self.imageSourceTableController = CheckTableViewController()
        self.imageSourceTableController?.checkAction = #selector(FilterViewController.onCheckImageSource(sender:))
        self.imageSourceTableController?.dataSet = ImageSearchDao.default.getImageSources()
        self.imageSourceTable.delegate = self.imageSourceTableController
        self.imageSourceTable.dataSource = self.imageSourceTableController
        self.cameraModelTableController = CheckTableViewController()
        self.cameraModelTableController?.checkAction = #selector(FilterViewController.onCheckCameraModel(sender:))
        self.cameraModelTableController?.dataSet = ImageSearchDao.default.getCameraModel()
        self.cameraModelTable.delegate = self.cameraModelTableController
        self.cameraModelTable.dataSource = self.cameraModelTableController
        self.imageSourceTable.reloadData()
        self.cameraModelTable.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction func onButtonApplyClicked(_ sender: Any) {
        var imageSource:[String] = []
        var cameraModels:[String] = []
        var cameraModel:[String] = []
        for name in (imageSourceTableController?.names)! {
            if imageSourceTableController?.dataSet![name] == true {
                imageSource.append(name)
            }
        }
        for name in (cameraModelTableController?.names)! {
            if cameraModelTableController?.dataSet![name] == true {
                cameraModels.append(name)
            }
        }
        if imageSource.count == imageSourceTableController?.names.count {
            imageSource = []
        }
        if cameraModel.count == cameraModelTableController?.names.count {
            cameraModels = []
        }
        
        if cameraModels.count > 0 {
            for model in cameraModels {
                let parts = model.components(separatedBy: ",")
                cameraModel.append(parts[1])
            }
        }
        if onApply != nil {
            onApply!(imageSource, cameraModel)
        }
    }
    
    @IBAction func onButtonClearClicked(_ sender: Any) {
        for name in (imageSourceTableController?.names)! {
            imageSourceTableController?.dataSet![name] = false
        }
        for name in (cameraModelTableController?.names)! {
            cameraModelTableController?.dataSet![name] = false
        }
        self.imageSourceTable.reloadData()
        self.cameraModelTable.reloadData()
    }
    
    @objc func onCheckImageSource(sender: NSButton) {
        if sender.toolTip != nil && (sender.toolTip?.starts(with: "Select "))! {
            let name = sender.toolTip!.replacingOccurrences(of: "Select ", with: "")
            print(name)
            if sender.state == .on {
                imageSourceTableController?.dataSet![name] = true
            }else if sender.state == .off {
                imageSourceTableController?.dataSet![name] = false
            }
        }
    }
    
    @objc func onCheckCameraModel(sender: NSButton) {
        if sender.toolTip != nil && (sender.toolTip?.starts(with: "Select "))! {
            let name = sender.toolTip!.replacingOccurrences(of: "Select ", with: "")
            print(name)
            if sender.state == .on {
                cameraModelTableController?.dataSet![name] = true
            }else if sender.state == .off {
                cameraModelTableController?.dataSet![name] = false
            }
        }
    }
    
}

class CheckTableViewController: NSViewController {
    
    var names:[String] = []
    var dataSet:[String:Bool]? {
        didSet {
            names = Array(dataSet!.keys).sorted(by: <)
        }
    }
    var checkAction:Selector?
}

extension CheckTableViewController: NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if self.dataSet == nil || self.dataSet!.count == 0 || row > (self.dataSet!.count - 1) {
            return nil
        }
        let name = names[row]
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            if id == NSUserInterfaceItemIdentifier("checkbox") {
                colView.subviews.removeAll()
                let button:NSButton = NSButton(frame: NSRect(x: 2, y: 2, width: 12, height: 12))
                button.setButtonType(NSButton.ButtonType.switch)
                button.action = self.checkAction!
                button.toolTip = "Select " + name
                button.state = dataSet![name]! ? NSButton.StateValue.on : NSButton.StateValue.off
                colView.addSubview(button)
                
            }else if id == NSUserInterfaceItemIdentifier("name") {
                colView.textField?.stringValue = name;
                colView.textField?.lineBreakMode = .byWordWrapping
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        rowView.backgroundColor = row % 2 == 1
            ? NSColor.gray
            : NSColor.darkGray
    }
}

// MARK: TableView data source functions

extension CheckTableViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        if dataSet == nil {
            return 0
        }
        return self.dataSet!.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}
