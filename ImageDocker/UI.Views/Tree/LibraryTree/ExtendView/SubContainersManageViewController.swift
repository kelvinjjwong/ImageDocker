//
//  SubContainersManageViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/11.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa

class SubContainersManageViewController: NSViewController {
    
    @IBOutlet weak var btnReload: NSButton!
    @IBOutlet weak var tblSubContainers: NSTableView!
    
    var containersTableController : DictionaryTableViewController!
    
    init(){
        super.init(nibName: "SubContainersManageViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containersTableController = DictionaryTableViewController(self.tblSubContainers)
    }
    
    func initView(containerPath: String) {
        
        self.loadSubContainers(parentPath: containerPath)
    }
    
    func loadSubContainers(parentPath: String) {
        var containers:[[String:String]] = []
        if let _ = RepositoryDao.default.getContainer(path: parentPath) {
            let subContainers = RepositoryDao.default.getSubContainers(parent: parentPath, condition: nil)
            if subContainers.count > 0 {
                for subContainer in subContainers {
                    var container:[String:String] = [:]
                    container["checkbox"] = "false"
                    container["path"] = subContainer.path
                    container["name"] = subContainer.name
                    container["parentFolder"] = subContainer.parentFolder
                    
                    containers.append(container)
                    
                }
            }
        }
        self.containersTableController.load(containers)
    }
    
    
    @IBAction func onReloadClicked(_ sender: NSButton) {
    }
    
}
