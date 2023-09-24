//
//  CollectionFilterViewController.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/9/24.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

class CollectionFilterViewController: NSViewController {
    
    @IBOutlet weak var boxSource: NSBox!
    @IBOutlet weak var boxEvent: NSBox!
    @IBOutlet weak var boxRepository: NSBox!
    @IBOutlet weak var tblPeople: NSTableView!
    @IBOutlet weak var tblEventCategory: NSTableView!
    @IBOutlet weak var tblSource: NSTableView!
    @IBOutlet weak var chkHidden: NSButton!
    
    var peopleTableController : DictionaryTableViewController!
    
    var eventCategoryTableController : DictionaryTableViewController!
    
    var sourceTableController : DictionaryTableViewController!
    
    
    func initView() {
        
        self.peopleTableController.load(self.loadPeople(), afterLoaded: {
        })
        
        self.eventCategoryTableController.load(self.loadEventCategory(), afterLoaded: {
        })
        
        self.sourceTableController.load(self.loadSource(), afterLoaded: {
        })
    }
    
    @IBAction func onHiddenClicked(_ sender: NSButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.peopleTableController = DictionaryTableViewController(self.tblPeople)
        self.eventCategoryTableController = DictionaryTableViewController(self.tblEventCategory)
        self.sourceTableController = DictionaryTableViewController(self.tblSource)
    }
    
    func loadPeople() -> [[String:String]] {
        var values:[[String:String]] = []
        let members = FaceDao.default.getCoreMembers()
        for c in members {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["id"] = c.id
            item["name"] = c.shortName
            values.append(item)
        }
        return values
    }
    
    func loadEventCategory() -> [[String:String]] {
        var values:[[String:String]] = []
        let cats = EventDao.default.getEventCategories()
        for c in cats {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["id"] = c
            item["name"] = c
            values.append(item)
        }
        return values
    }
    
    func loadSource() -> [[String:String]] {
        var values:[[String:String]] = []
//        let cats = EventDao.default.getEventCategories()
//        for c in cats {
//            var item:[String:String] = [:]
//            item["check"] = "false"
//            item["id"] = c
//            item["name"] = c
//            values.append(item)
//        }
        if true{
            var item:[String:String] = [:]
            item["check"] = "false"
            item["id"] = "Camera"
            item["name"] = "Camera"
            values.append(item)
        }
        if true{
            var item:[String:String] = [:]
            item["check"] = "false"
            item["id"] = "Weixin"
            item["name"] = "Weixin"
            values.append(item)
        }
        if true{
            var item:[String:String] = [:]
            item["check"] = "false"
            item["id"] = "QQ"
            item["name"] = "QQ"
            values.append(item)
        }
        if true{
            var item:[String:String] = [:]
            item["check"] = "false"
            item["id"] = "ScreenShot"
            item["name"] = "ScreenShot"
            values.append(item)
        }
        return values
    }
    
}
