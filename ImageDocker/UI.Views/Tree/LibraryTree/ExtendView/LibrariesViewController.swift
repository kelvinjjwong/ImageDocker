//
//  LibrariesViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class LibrariesViewController: NSViewController {
    
    @IBOutlet weak var btnReload: NSButton!
    @IBOutlet weak var btnCalculate: NSButton!
    @IBOutlet weak var btnNewRepository: NSButton!
    
    @IBOutlet weak var tblSpaceOccupation: NSTableView!
    
    var records:[(String,String,String,String,String, String,String)] = []
    var onReload: (() -> Void)? = nil
    
    // MARK: INIT VIEW
    
    init(onReload: (() -> Void)? = nil) {
        super.init(nibName: "LibrariesViewController", bundle: nil)
        self.onReload = onReload
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnReload.title = Words.tree_reload_tree.word()
        self.btnCalculate.title = Words.library_tree_calculate_space.word()
        self.btnNewRepository.title = Words.library_tree_new_repository.word()
        
        self.tblSpaceOccupation.delegate = self
        self.tblSpaceOccupation.dataSource = self
    }
    
    @IBAction func onNewRepositoryClicked(_ sender: NSButton) {
        let viewController = EditRepositoryViewController()
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 980
        let windowHeight = 820
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "New Repository"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initNew(window: window)
    }
    
    
    @IBAction func onReloadClicked(_ sender: NSButton) {
        if self.onReload != nil {
            self.onReload!()
        }
    }
    
    private func getBytesText(_ value:Double) -> String {
        return value < 1 ? "\(Int(value * 1000)) M" : "\(value) G"
    }
    
    @IBAction func onCalculateClicked(_ sender: NSButton) {
        self.btnCalculate.isEnabled = false
        DispatchQueue.global().async {
            self.records.removeAll()
            let (lastImportDates, notyetScanDevices) = DeviceDao.default.getLastImportDateOfDevices()
            let lastPhotoTakenDates = RepositoryDao.default.getLastPhotoTakenDateOfRepositories()
            
            let repos = RepositoryDao.default.getRepositoriesV2().sorted(by: { (left, right) -> Bool in
                return left.name < right.name
            })
            var totalTotal = 0.0
            var totalRepo = 0.0
            var totalBackup = 0.0
            var totalFace = 0.0
            var diskUsage:[String:Double] = [:]
            for repo in repos {
                let (repoSize, backupSize, faceSize, totalSize, usage) = LocalDirectory.bridge.getRepositorySpaceOccupationInGB(repository: repo, diskUsage: diskUsage)
                diskUsage = usage
                let total = self.getBytesText(totalSize)
                let repoTxt = self.getBytesText(repoSize)
                let backupTxt = self.getBytesText(backupSize)
                let faceTxt = self.getBytesText(faceSize)
                
                let lastImportDate = lastImportDates[repo.name] ?? ""
                var lastPhotoTakenDate = lastPhotoTakenDates[repo.name] ?? ""
                lastPhotoTakenDate = lastPhotoTakenDate.components(separatedBy: " ")[0]
                
                self.records.append((repo.name, total, repoTxt, backupTxt, faceTxt, lastImportDate, lastPhotoTakenDate))
                DispatchQueue.main.async {
                    self.tblSpaceOccupation.reloadData()
                }
                totalTotal += totalSize
                totalRepo += repoSize
                totalBackup += backupSize
                totalFace += faceSize
            }
            for notScanDevice in notyetScanDevices {
                let name = notScanDevice.0
                let lastImportDate = notScanDevice.1
                var totalSize = 0.0
                var repoTxt = ""
                var backupTxt = ""
                if let repoPath = notScanDevice.2 {
                    let (repoSize, _, repoDisk, _) = LocalDirectory.bridge.getDiskSpace(path: repoPath)
                    repoTxt = self.getBytesText(repoSize)
                    totalSize += repoSize
                    
                    let repoDiskUsed = diskUsage[repoDisk]
                    if repoDiskUsed == nil {
                        diskUsage[repoDisk] = repoSize
                    }else{
                        diskUsage[repoDisk] = repoDiskUsed! + repoSize
                    }
                    totalRepo += repoSize
                }
                if let backupPath = notScanDevice.3 {
                    let (backupSize, _, backupDisk, _) = LocalDirectory.bridge.getDiskSpace(path: backupPath)
                    backupTxt = self.getBytesText(backupSize)
                    totalSize += backupSize
                    
                    let backupDiskUsed = diskUsage[backupDisk]
                    if backupDiskUsed == nil {
                        diskUsage[backupDisk] = backupSize
                    }else{
                        diskUsage[backupDisk] = backupDiskUsed! + backupSize
                    }
                    totalBackup += backupSize
                }
                totalTotal += totalSize
                let total = self.getBytesText(totalSize)
                
                var exists = false
                for rec in self.records {
                    if rec.0 == name {
                        exists = true
                        break
                    }
                }
                if !exists {
                    self.records.append((name, total, repoTxt, backupTxt, "", lastImportDate, "(NOT SCANNED)"))
                }
                DispatchQueue.main.async {
                    self.tblSpaceOccupation.reloadData()
                }
            }
            self.records.sort(by: { (left, right) -> Bool in
                return left.0 < right.0
            })
            
            self.records.append(("TOTAL",
                                 self.getBytesText(totalTotal),
                                 self.getBytesText(totalRepo),
                                 self.getBytesText(totalBackup),
                                 self.getBytesText(totalFace),
                                 "", ""))
            
            self.records.append(("", "", "", "", "", "", ""))
            self.records.append(("Disk", "Used", "Free", "Total", "", "", ""))
            
            for key in diskUsage.keys {
                if key.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    continue
                }
                let (diskTotal, diskFree, _) = LocalDirectory.bridge.freeSpace(path: key)
                self.records.append((key, "\(diskUsage[key] ?? 0) G", diskFree, diskTotal, "", "", ""))
            }
            
            DispatchQueue.main.async {
                self.tblSpaceOccupation.reloadData()
                self.btnCalculate.isEnabled = true
            }
            
        }
    }
    
    
}

extension LibrariesViewController: NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.records.count - 1) {
            return nil
        }
        let info:(String,String,String,String,String,String,String) = self.records[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("name"):
                value = info.0
            case NSUserInterfaceItemIdentifier("total"):
                value = info.1
            case NSUserInterfaceItemIdentifier("repo"):
                value = info.2
            case NSUserInterfaceItemIdentifier("backup"):
                value = info.3
            case NSUserInterfaceItemIdentifier("face"):
                value = info.4
            case NSUserInterfaceItemIdentifier("lastImportDate"):
                value = info.5
            case NSUserInterfaceItemIdentifier("lastPhotoTakenDate"):
                value = info.6
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
            if row == tableView.selectedRow {
                colView.textField?.textColor = NSColor.yellow
            } else {
                colView.textField?.textColor = nil
            }
            /*
             if let tooltip = tip {
             colView.textField?.toolTip = tooltip
             }
             */
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
}

// MARK: TableView data source functions

extension LibrariesViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.records.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}
