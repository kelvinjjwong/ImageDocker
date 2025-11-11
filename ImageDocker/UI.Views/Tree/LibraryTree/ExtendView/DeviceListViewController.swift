//
//  DeviceListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/13.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import SharedDeviceLib

protocol DeviceListDelegate {
    func selectDevice(deviceId:String)
}

class DeviceListViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "DEVICE", subCategory: "LIST")
    
    var selectionDelegate:DeviceListDelegate?
    var devices:[ImageDevice] = []
    
    // MARK: CONTROLS
    
    @IBOutlet weak var tblDevices: NSTableView!
    
    fileprivate var onSelect:((ImageDevice) -> Void)?
    
    // MARK: INIT

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblDevices.delegate = self
        self.tblDevices.dataSource = self
    }
    
    func initView(onSelect:((ImageDevice) -> Void)? = nil) {
        self.onSelect = onSelect
        
        lastSelectedRow = nil
        self.devices = DeviceDao.default.getDevices()
        
        var androidDevices:[ImageDevice] = []
        if DeviceBridge.Android().isBridgeReady() {
            let androidDeviceIds = DeviceBridge.Android().devices()
            if androidDeviceIds.count > 0 {
                for deviceId in androidDeviceIds {
                    if !self.devices.contains(where: { dev in
                        return dev.deviceId == deviceId
                    }){
                        if let androidDevice = DeviceBridge.Android().device(id: deviceId) {
                            let manufacture = androidDevice.manufacture
                            let marketName = androidDevice.name
                            let model = androidDevice.model
                            
                            let androidDevice = ImageDevice()
                            androidDevice.type = "Android"
                            androidDevice.manufacture = manufacture
                            androidDevice.marketName = marketName
                            androidDevice.model = model
                            androidDevice.deviceId = deviceId
                            
                            androidDevices.append(androidDevice)
                        }
                    }
                }
            }
        }
        self.devices.append(contentsOf: androidDevices)
        
        var iphoneDevices:[ImageDevice] = []
        if DeviceBridge.IPHONE().validCommands() {
            let iphoneDeviceIds = DeviceBridge.IPHONE().devices()
            if iphoneDeviceIds.count > 0 {
                for deviceId in iphoneDeviceIds {
                    if !self.devices.contains(where: { dev in
                        return dev.deviceId == deviceId
                    }){
                        if let iphoneDevice = DeviceBridge.IPHONE().device() {
                            let manufacture = iphoneDevice.manufacture
                            let model = iphoneDevice.model
                            let marketName = iphoneDevice.name
                            
                            let iphoneDevice = ImageDevice()
                            iphoneDevice.type = "iPhone"
                            iphoneDevice.manufacture = manufacture
                            iphoneDevice.model = model
                            iphoneDevice.marketName = marketName
                            iphoneDevice.deviceId = deviceId
                            
                            iphoneDevices.append(iphoneDevice)
                        }
                    }
                }
            }
        }
        self.devices.append(contentsOf: iphoneDevices)
        
        self.logger.log(devices.count)
        self.tblDevices.reloadData()
    }
    
    // MARK: ACTION
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && devices.count > 0 && lastSelectedRow! < devices.count {
//                if let selectedDeviceId = devices[lastSelectedRow!].deviceId {
                    //self.logger.log(.trace, "selected device id \(selectedDeviceId)")
//                    if self.selectionDelegate != nil {
//                        self.selectionDelegate?.selectDevice(deviceId: selectedDeviceId)
//                    }
                    let device = devices[lastSelectedRow!]
                    
                    self.onSelect?(device)
//                }
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
            case NSUserInterfaceItemIdentifier("manufacture"):
                value = info.manufacture ?? ""
            case NSUserInterfaceItemIdentifier("model"):
                value = info.model ?? ""
            case NSUserInterfaceItemIdentifier("deviceId"):
                value = info.deviceId ?? ""
            case NSUserInterfaceItemIdentifier("marketName"):
                value = info.marketName ?? ""
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedRow = row
//                colView.textField?.textColor = NSColor.yellow
            } else {
                lastSelectedRow = nil
//                colView.textField?.textColor = nil
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
