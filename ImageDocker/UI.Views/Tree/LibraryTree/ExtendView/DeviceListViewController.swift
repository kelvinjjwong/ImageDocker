//
//  DeviceListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/13.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

protocol DeviceListDelegate {
    func selectDevice(deviceId:String)
}

class DeviceListViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "DEVICE", subCategory: "LIST")
    
    var selectionDelegate:DeviceListDelegate?
    var devices:[ImageDevice] = []
    
    // MARK: CONTROLS
    
    @IBOutlet weak var tblDevices: NSTableView!
    
    // MARK: INIT

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblDevices.delegate = self
        self.tblDevices.dataSource = self
    }
    
    func initView() {
        lastSelectedRow = nil
        self.devices = DeviceDao.default.getDevices()
        self.logger.log(devices.count)
        self.tblDevices.reloadData()
    }
    
    // MARK: ACTION
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && devices.count > 0 && lastSelectedRow! < devices.count {
                if let selectedDeviceId = devices[lastSelectedRow!].deviceId {
                    //self.logger.log("selected device id \(selectedDeviceId)")
                    if self.selectionDelegate != nil {
                        self.selectionDelegate?.selectDevice(deviceId: selectedDeviceId)
                    }
                }
            }
        }
    }
    
}


// MARK: TableView delegate functions

extension DeviceListViewController: NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.devices.count - 1) {
            return nil
        }
        let info:ImageDevice = self.devices[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("name"):
                value = info.name ?? ""
            case NSUserInterfaceItemIdentifier("repository"):
                value = info.repositoryPath ?? ""
            case NSUserInterfaceItemIdentifier("home"):
                value = info.homePath ?? ""
            case NSUserInterfaceItemIdentifier("deviceId"):
                value = info.deviceId ?? ""
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedRow = row
                colView.textField?.textColor = NSColor.yellow
            } else {
                lastSelectedRow = nil
                colView.textField?.textColor = nil
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        rowView.backgroundColor = row % 2 == 1
            ? Colors.MidGray
            : Colors.DarkGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        logger.log("selected row \(row)")
        lastSelectedRow = row
        return true
    }
}

// MARK: TableView data source functions

extension DeviceListViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.devices.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // do nothing
    }

}
