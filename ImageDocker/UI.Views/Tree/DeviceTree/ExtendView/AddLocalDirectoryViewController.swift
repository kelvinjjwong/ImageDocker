//
//  AddLocalDirectoryViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import SharedDeviceLib

struct DirectoryViewShortcut {
    
    var title:String
    var path:String
}

protocol DirectoryViewDelegate {
    func listSubFolders(in:String) -> [String]
    func listFiles(in:String, ext:Set<String>?) -> [String]
    func home() -> String
    func shortcuts() -> [DirectoryViewShortcut]
}

protocol DirectoryViewGotoDelegate {
    func goto(path:String)
    func currentUrl() -> URL
}

class AddLocalDirectoryViewController: NSViewController, DirectoryViewGotoDelegate {
    
    // MARK: PROPERTIES
    
    var currentPath:URL
    
    // MARK: EVENT
    var onApply: ((_ directory:String, _ toSubFolder:String, _ exclude:Bool, _ hasManyChildren:Bool) -> Void)?
    
    // MARK: CONTROLS
    
    @IBOutlet weak var txtDirectory: NSTextField!
    @IBOutlet weak var txtSubFolder: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var tblShortcut: NSTableView!
    @IBOutlet weak var tblFolders: NSTableView!
    @IBOutlet weak var tblFiles: NSTableView!
    @IBOutlet weak var btnParent: NSButton!
    @IBOutlet weak var btnHome: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    @IBOutlet weak var lblToFolder: NSTextField!
    @IBOutlet weak var chkExclude: NSButton!
    @IBOutlet weak var chkManyChildren: NSButton!
    
    
    
    // MARK: TABLE DELEGATES
    
    let tblShortcutDelegate = DirectoryShortcutTableDelegate()
    let tblFoldersDelegate = DirectoryFolderTableDelegate()
    let tblFilesDelegate = DirectoryFilesTableDelegate()
    
    var directoryViewDelegate:DirectoryViewDelegate
    var defaultToFolder:String = ""
    var labelToFolder:String = ""
    
    // MARK: INIT
    
    private var destinationType:DeviceCopyDestinationType = .onDevice
    
    init(directoryViewDelegate:DirectoryViewDelegate, deviceType:MobileType, destinationType:DeviceCopyDestinationType, onApply: ((_ directory:String, _ toSubFolder:String, _ exclude:Bool, _ hasManyChildren:Bool) -> Void)? = nil){
        self.currentPath = URL(fileURLWithPath: "/")
        self.directoryViewDelegate = directoryViewDelegate
        self.onApply = onApply
        self.destinationType = destinationType
        if deviceType == .Android {
            if destinationType == .onDevice {
                self.defaultToFolder = "Camera"
            }else if destinationType == .localDirectory {
                self.defaultToFolder = "/sdcard/DCIM/Camera/"
            }
        }else if deviceType == .iPhone {
            if destinationType == .onDevice {
                self.defaultToFolder = "Camera"
            }else if destinationType == .localDirectory {
                self.defaultToFolder = "/sdcard/DCIM/Camera/"
            }
        }
        super.init(nibName: "AddLocalDirectoryViewController", bundle: nil)
        self.tblShortcutDelegate.gotoDelegate = self
        self.tblFoldersDelegate.gotoDelegate = self
    }
    
    
    required init?(coder: NSCoder) {
        self.directoryViewDelegate = LocalDirectoryViewDelegate()
        self.currentPath = URL(fileURLWithPath: "/")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPath = URL(fileURLWithPath: directoryViewDelegate.home())
        txtDirectory.stringValue = directoryViewDelegate.home()
        txtSubFolder.stringValue = self.defaultToFolder
        btnOK.isEnabled = true
        
        tblShortcut.delegate = tblShortcutDelegate
        tblShortcut.dataSource = tblShortcutDelegate
        
        tblFolders.delegate = tblFoldersDelegate
        tblFolders.dataSource = tblFoldersDelegate
        
        tblFiles.delegate = tblFilesDelegate
        tblFiles.dataSource = tblFilesDelegate
        
        lblToFolder.stringValue = labelToFolder
        
        viewInit()
        
    }
    
    func viewInit(){
        viewInit(path: directoryViewDelegate.home(), shortcuts: directoryViewDelegate.shortcuts())
    }
    
    func viewInit(path:String, shortcuts:[DirectoryViewShortcut]){
        
        
        chkExclude.state = .off
        chkManyChildren.state = .off
        if destinationType == .onDevice {
            labelToFolder = "To SubFolder:"
            chkExclude.isHidden = false
            chkManyChildren.isHidden = false
        }else{
            labelToFolder = "Pretend as:"
            chkExclude.isHidden = true
            chkManyChildren.isHidden = true
        }
        
        tblShortcutDelegate.shortcuts = shortcuts
        tblShortcut.reloadData()
        
        goto(path: path)
    }

    // MARK: ACTION
    
    @IBAction func onBrowseClicked(_ sender: NSButton) {
        self.goto(path: txtDirectory.stringValue)
    }
    
    @IBAction func onParentClicked(_ sender: NSButton) {
        self.gotoParent()
    }
    
    @IBAction func onHomeClicked(_ sender: NSButton) {
        self.gotoHome()
    }
    
    func goto(path:String){
        currentPath = URL(fileURLWithPath: path)
        goto(url: currentPath)
    }
    
    func goto(url:URL){
        
        let path = url.path
        
        self.txtDirectory.stringValue = path
        
        let folders = self.directoryViewDelegate.listSubFolders(in: path)
        self.tblFoldersDelegate.folders = folders
        
        let files = self.directoryViewDelegate.listFiles(in: path, ext: nil)
        self.tblFilesDelegate.files = files
        
        self.tblFolders.reloadData()
        self.tblFiles.reloadData()
        
        btnOK.isEnabled = true
    }
    
    func currentUrl() -> URL {
        return self.currentPath
    }
    
    func gotoParent() {
//        self.logger.log(.trace, "current: \(currentPath.path)")
        let parent = currentPath.deletingLastPathComponent()
        self.currentPath = parent
//        self.logger.log(.trace, "parent: \(currentPath.path)")
        goto(url: parent)
    }
    
    func gotoHome() {
        self.currentPath = URL(fileURLWithPath: self.directoryViewDelegate.home())
        goto(path: self.directoryViewDelegate.home())
    }
    
    // MARK: OK BUTTON
    
    @IBAction func onOKClicked(_ sender: NSButton) {
        guard txtDirectory.stringValue != "" else {return}
        if self.chkExclude.state == .off && txtSubFolder.stringValue == "" {
            return
        }
        if let call = onApply {
            call(txtDirectory.stringValue, txtSubFolder.stringValue, chkExclude.state == .on, chkManyChildren.state == .on)
        }
    }
    
}

// MARK: SHORTCUTS

class DirectoryShortcutTableDelegate : NSObject {
    
    var gotoDelegate:DirectoryViewGotoDelegate?
    
    var shortcuts:[DirectoryViewShortcut] = []
    var lastSelectedRow:Int? {
        didSet {
            
            if let row = lastSelectedRow, row >= 0 {
                let shortcut:DirectoryViewShortcut = self.shortcuts[row]
                if let call = gotoDelegate {
                    call.goto(path: shortcut.path)
                }
            }
        }
    }
}

extension DirectoryShortcutTableDelegate : NSTableViewDelegate {
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.shortcuts.count - 1) {
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSize = 3
        
        let info:DirectoryViewShortcut = self.shortcuts[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("shortcut"):
                value = info.title
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
//            if row == tableView.selectedRow {
//                lastSelectedRow = row
//            } else {
//                lastSelectedRow = nil
//            }
            
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        //        rowView.backgroundColor = row % 2 == 1
        //            ? NSColor.white
        //            : NSColor.lightGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

extension DirectoryShortcutTableDelegate : NSTableViewDataSource {
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.shortcuts.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}


// MARK: FOLDERS

class DirectoryFolderTableDelegate : NSObject {
    var gotoDelegate:DirectoryViewGotoDelegate?
    
    var folders:[String] = []
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil {
                let folder:String = self.folders[lastSelectedRow!]
                if let call = gotoDelegate {
                    let url = call.currentUrl().appendingPathComponent(folder)
                    call.goto(path: url.path)
                }
            }
        }
    }
}

extension DirectoryFolderTableDelegate : NSTableViewDelegate {
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.folders.count - 1) {
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSize = 3
        
        let info:String = self.folders[row]
        //self.logger.log(info)
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("folder"):
                value = info
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
//            if row == tableView.selectedRow {
//                lastSelectedRow = row
//            } else {
//                lastSelectedRow = nil
//            }
            
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        //        rowView.backgroundColor = row % 2 == 1
        //            ? NSColor.white
        //            : NSColor.lightGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

extension DirectoryFolderTableDelegate : NSTableViewDataSource {
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.folders.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}


// MARK: FILES

class DirectoryFilesTableDelegate : NSObject {
    var files:[String] = []
    var lastSelectedRow:Int?
}

extension DirectoryFilesTableDelegate : NSTableViewDelegate {
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.files.count - 1) {
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSize = 3
        
        let info:String = self.files[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("filename"):
                value = info
                
//            case NSUserInterfaceItemIdentifier("datetime"):
//                value = info
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
//            if row == tableView.selectedRow {
//                lastSelectedRow = row
//            } else {
//                lastSelectedRow = nil
//            }
            
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
//        guard let tableView = tableView as? CustomTableView else { return }
//
//                rowView.backgroundColor = row % 2 == 1
//                    ? NSColor.white
//                    : NSColor.lightGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

extension DirectoryFilesTableDelegate : NSTableViewDataSource {
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.files.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}
