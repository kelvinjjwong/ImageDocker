//
//  CollectionFilterViewController.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/9/24.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

public enum HiddenState : Int {
    case ShowAndHidden
    case ShowOnly
    case HiddenOnly
}

class CollectionFilter {
    
    var repositoryOwners:[String] = []
    var eventCategories:[String] = []
    var imageSources:[String] = []
    var includeHidden:HiddenState = .ShowOnly
    var includePhoto = true
    var includeVideo = true
    var limitWidth = false
    var opWidth = "="
    var width:Int = 0
    var limitHeight = false
    var opHeight = "="
    var height:Int = 0
    
    public init() { }
    
    public func clone() -> CollectionFilter {
        let n = CollectionFilter()
        n.repositoryOwners = self.repositoryOwners
        n.eventCategories = self.eventCategories
        n.imageSources = self.imageSources
        n.includeHidden = self.includeHidden
        n.includePhoto = self.includePhoto
        n.includeVideo = self.includeVideo
        n.limitWidth = self.limitWidth
        n.opWidth = self.opWidth
        n.width = self.width
        n.limitHeight = self.limitHeight
        n.opHeight = self.opHeight
        n.height = self.height
        return n
    }
    
    public func represent() -> String {
        return """
{
    repositoryOwners: \(self.repositoryOwners),
    eventCategories: \(self.eventCategories),
    imageSources: \(self.imageSources),
    includeHidden: \(self.includeHidden),
    includePhoto: \(self.includePhoto),
    includeVideo: \(self.includeVideo),
    limitWidth: \(self.limitWidth),
    opWidth: \(self.opWidth),
    width: \(self.width),
    limitHeight: \(self.limitHeight),
    opHeight: \(self.opHeight),
    height: \(self.height)
}
"""
    }
    
    public func getRepositoryIds() -> [Int] {
        return RepositoryDao.default.getRepositoryIdsByOwners(owners: self.repositoryOwners)
    }
    
    public func getEvents() -> [String] {
        return EventDao.default.getEventsByCategories(categories: self.eventCategories)
    }
    
    public func getImageSources() -> [String] {
        return self.imageSources
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
    @IBOutlet weak var chkLimitWidth: NSButton!
    @IBOutlet weak var ddlOpWidth: NSPopUpButton!
    @IBOutlet weak var txtWidth: NSTextField!
    @IBOutlet weak var chkLimitHeight: NSButton!
    @IBOutlet weak var ddlOpHeight: NSPopUpButton!
    @IBOutlet weak var txtHeight: NSTextField!
    
    
    
    var peopleTableController : DictionaryTableViewController!
    
    var eventCategoryTableController : DictionaryTableViewController!
    
    var sourceTableController : DictionaryTableViewController!
    
    var persist:((CollectionFilter) -> Void)? = nil
    var loadPreset:(() -> CollectionFilter)? = nil // TODO: load preset in viewDidLoad
    
    
    func initView() {
    }
    
    func persistFilter() {
        let filter = CollectionFilter()
        filter.repositoryOwners = self.peopleTableController.getCheckedItems(column: "id")
        filter.imageSources = self.sourceTableController.getCheckedItems(column: "name")
        filter.eventCategories = self.eventCategoryTableController.getCheckedItems(column: "name")
        filter.includeHidden = (self.chkHidden.state == .on) ? .HiddenOnly : .ShowOnly
        filter.includePhoto = self.chkPhoto.state == .on
        filter.includeVideo = self.chkVideo.state == .on
        filter.limitWidth = self.chkLimitWidth.state == .on
        filter.limitHeight = self.chkLimitHeight.state == .on
        filter.opWidth = self.ddlOpWidth.stringValue
        filter.opHeight = self.ddlOpHeight.stringValue
        filter.width = self.txtWidth.integerValue
        filter.height = self.txtHeight.integerValue
        
        self.persist?(filter)
    }
    
    func setFilter(_ filter:CollectionFilter) {
        self.peopleTableController.uncheckAll()
        self.sourceTableController.uncheckAll()
        self.eventCategoryTableController.uncheckAll()
        self.peopleTableController.setCheckedItems(column: "id", from: filter.repositoryOwners)
        self.sourceTableController.setCheckedItems(column: "name", from: filter.imageSources)
        self.eventCategoryTableController.setCheckedItems(column: "name", from: filter.eventCategories)
        self.chkHidden.state = filter.includeHidden == .HiddenOnly ? .on : .off
        self.chkPhoto.state = filter.includePhoto ? .on : .off
        self.chkVideo.state = filter.includeVideo ? .on : .off
        self.chkLimitWidth.state = filter.limitWidth ? .on : .off
        self.chkLimitHeight.state = filter.limitHeight ? .on : .off
        self.ddlOpWidth.selectItem(withTitle: filter.opWidth)
        self.ddlOpHeight.selectItem(withTitle: filter.opHeight)
        self.txtWidth.integerValue = filter.width
        self.txtHeight.integerValue = filter.height
        
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
    
    @IBAction func onLimitWidthClicked(_ sender: NSButton) {
        self.persistFilter()
    }
    
    @IBAction func onLimitHeightClicked(_ sender: NSButton) {
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
        let coreMembers = FaceDao.default.getCoreMembers()
        let ownerIds = RepositoryDao.default.getOwners()
        for ownerId in ownerIds {
            var item:[String:String] = [:]
            
            if let cm = coreMembers.first(where: { p in
                return p.id == ownerId
            }) {
                item["id"] = cm.id
                item["name"] = cm.name
                item["nickName"] = cm.shortName ?? cm.name
            }else{
                item["id"] = "shared"
                item["name"] = Words.owner_public_shared.word()
                item["nickName"] = Words.owner_public_shared.word()
            }
            
            if selected.contains(ownerId) {
                item["check"] = "true"
            }else{
                item["check"] = "false"
            }
            
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
