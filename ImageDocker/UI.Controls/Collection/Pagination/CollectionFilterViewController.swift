//
//  CollectionFilterViewController.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/9/24.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class CollectionFilter {
    
    var repositoryOwners:[String] = []
    var eventCategories:[String] = []
    var imageSources:[String] = []
    var includeHidden = false
    var includePhoto = true
    var includeVideo = true
    
    public init() { }
    
    public func represent() -> String {
        return """
{
    repositoryOwners: \(self.repositoryOwners),
    eventCategories: \(self.eventCategories),
    imageSources: \(self.imageSources),
    includeHidden: \(self.includeHidden),
    includePhoto: \(self.includePhoto),
    includeVideo: \(self.includeVideo)
}
"""
    }
}

class CollectionFilterViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "Collection", subCategory: "Filter", includeTypes: [.trace, .debug])
    
    @IBOutlet weak var boxSource: NSBox!
    @IBOutlet weak var boxEvent: NSBox!
    @IBOutlet weak var boxRepository: NSBox!
    @IBOutlet weak var tblPeople: NSTableView!
    @IBOutlet weak var tblEventCategory: NSTableView!
    @IBOutlet weak var tblSource: NSTableView!
    @IBOutlet weak var chkHidden: NSButton!
    @IBOutlet weak var chkPhoto: NSButton!
    @IBOutlet weak var chkVideo: NSButton!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    var peopleTableController : DictionaryTableViewController!
    
    var eventCategoryTableController : DictionaryTableViewController!
    
    var sourceTableController : DictionaryTableViewController!
    
    var persist:((CollectionFilter) -> Void)? = nil
    var loadPreset:(() -> CollectionFilter)? = nil // TODO: load preset in viewDidLoad
    
    
    func initView() {
    }
    
    func persistFilter() {
        let filter = CollectionFilter()
        filter.repositoryOwners = self.peopleTableController.getCheckedItems(column: "name")
        filter.imageSources = self.sourceTableController.getCheckedItems(column: "name")
        filter.eventCategories = self.eventCategoryTableController.getCheckedItems(column: "name")
        filter.includeHidden = self.chkHidden.state == .on
        filter.includePhoto = self.chkPhoto.state == .on
        filter.includeVideo = self.chkVideo.state == .on
        self.persist?(filter)
    }
    
    func setFilter(_ filter:CollectionFilter) {
        self.peopleTableController.uncheckAll()
        self.sourceTableController.uncheckAll()
        self.eventCategoryTableController.uncheckAll()
        self.peopleTableController.setCheckedItems(column: "name", from: filter.repositoryOwners)
        self.sourceTableController.setCheckedItems(column: "name", from: filter.imageSources)
        self.eventCategoryTableController.setCheckedItems(column: "name", from: filter.eventCategories)
        self.chkHidden.state = filter.includeHidden ? .on : .off
        self.chkPhoto.state = filter.includePhoto ? .on : .off
        self.chkVideo.state = filter.includeVideo ? .on : .off
    }
    
    @IBAction func onHiddenClicked(_ sender: NSButton) {
        self.persistFilter()
    }
    
    @IBAction func onPhotoClicked(_ sender: NSButton) {
        self.persistFilter()
    }
    
    @IBAction func onVideoClicked(_ sender: NSButton) {
        self.persistFilter()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.peopleTableController = DictionaryTableViewController(self.tblPeople)
        self.eventCategoryTableController = DictionaryTableViewController(self.tblEventCategory)
        self.sourceTableController = DictionaryTableViewController(self.tblSource)
        
        self.peopleTableController.onCheck = { id, state in
            self.persistFilter()
        }
        
        self.eventCategoryTableController.onCheck = { id, state in
            self.persistFilter()
        }
        
        self.sourceTableController.onCheck = { id, state in
            self.persistFilter()
        }
        
        self.peopleTableController.load(self.loadPeople(), afterLoaded: {
        })
        
        self.eventCategoryTableController.load(self.loadEventCategory(), afterLoaded: {
        })
        
        self.sourceTableController.load(self.loadSource(), afterLoaded: {
        })
    }
    
    func loadPeople(selected:[String] = []) -> [[String:String]] {
        self.logger.log(.trace, "[loadPeople] selected:\(selected)")
        var values:[[String:String]] = []
        let members = RepositoryDao.default.getOwners()
        for name in members {
            var item:[String:String] = [:]
            if selected.contains(name) {
                item["check"] = "true"
            }else{
                item["check"] = "false"
            }
            item["id"] = name
            item["name"] = name
            values.append(item)
        }
        return values
    }
    
    func loadEventCategory(selected:[String] = []) -> [[String:String]] {
        self.logger.log(.trace, "[loadEventCategory] selected:\(selected)")
        var values:[[String:String]] = []
        let cats = EventDao.default.getEventCategories()
        for c in cats {
            var item:[String:String] = [:]
            if selected.contains(c) {
                item["check"] = "true"
            }else{
                item["check"] = "false"
            }
            item["id"] = c
            item["name"] = c
            values.append(item)
        }
        return values
    }
    
    func loadSource(selected:[String] = []) -> [[String:String]] {
        self.logger.log(.trace, "[loadSource] selected:\(selected)")
        var values:[[String:String]] = []
        let imageSources = ImageSearchDao.default.getImageSources()
        for (imageSource, _) in imageSources {
            var item:[String:String] = [:]
            if selected.contains(imageSource) {
                item["check"] = "true"
            }else{
                item["check"] = "false"
            }
            item["id"] = imageSource
            item["name"] = imageSource
            values.append(item)
        }
        return values
    }
    
    @IBAction func onApplyClicked(_ sender: NSButton) {
        self.persistFilter()
    }
    
    @IBAction func onRemoveClicked(_ sender: NSButton) {
        self.setFilter(CollectionFilter())
        self.persistFilter()
    }
    
    
}
