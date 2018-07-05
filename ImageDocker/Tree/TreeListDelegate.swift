//
//  TreeListController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList

let photosIcon:NSImage = NSImage(imageLiteralResourceName: "photos")
let eventsIcon:NSImage = NSImage(imageLiteralResourceName: "events")
let peopleIcon:NSImage = NSImage(imageLiteralResourceName: "people")
let placesIcon:NSImage = NSImage(imageLiteralResourceName: "places")
let albumIcon:NSImage = NSImage(imageLiteralResourceName: "album")
let folderIcon:NSImage = NSImage(imageLiteralResourceName: "folderOpen")
let folderAltIcon:NSImage = NSImage(imageLiteralResourceName: "folderOpenAlt")
let calendarIcon:NSImage = NSImage(imageLiteralResourceName: "calendar")
let clockIcon:NSImage = NSImage(imageLiteralResourceName: "clock")
let flagIcon:NSImage = NSImage(imageLiteralResourceName: "flag")
let anchorIcon:NSImage = NSImage(imageLiteralResourceName: "anchor")
let phoneIcon:NSImage = NSImage(imageLiteralResourceName: "phone")
let printIcon:NSImage = NSImage(imageLiteralResourceName: "print")
let shareIcon:NSImage = NSImage(imageLiteralResourceName: "share")

extension ViewController {
    
    func initTreeDataModel() {
        placesIcon.isTemplate = true
        peopleIcon.isTemplate = true
        eventsIcon.isTemplate = true
        photosIcon.isTemplate = true
        albumIcon.isTemplate = true
        
        self.sourceListItems = NSMutableArray(array:[])
        //self.modelObjects = NSMutableArray(array:[])
        
        if self.librarySectionOfTree == nil {
            self.librarySectionOfTree = self.addTreeSection(title: "LIBRARY")
        }
        
        if self.momentSectionOfTree == nil {
            self.momentSectionOfTree = self.addTreeSection(title: "MOMENTS")
        }
        
        if self.eventSectionOfTree == nil {
            self.eventSectionOfTree = self.addTreeSection(title: "EVENTS")
        }
        
        if self.placeSectionOfTree == nil {
            self.placeSectionOfTree = self.addTreeSection(title: "PLACES")
        }
 
    }
    
    func loadEventsToTreeFromDatabase() {
        let dates:[[String : AnyObject]]? = ModelStore.getAllEvents(imageSource: filterImageSource, cameraModel: filterCameraModel)
        if dates != nil {
            let events:[Event] = Events().read(dates!)
            for event in events {
                if event.event == ""{
                    continue
                }
                self.addEventTreeEntry(event: event)
                for month in event.children {
                    self.addEventMonthTreeEntry(month: month)
                    for day in month.children {
                        self.addEventDayTreeEntry(day: day)
                    }
                }
            }
            self.lastCheckEventChange = Date()
        }else{
            print("no events")
        }
    }
    
    func loadMomentsToTreeFromDatabase(groupByPlace:Bool = false, filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil){
        let dates:[[String : AnyObject]]? = ModelStore.getAllDates(groupByPlace: groupByPlace, imageSource: filterImageSource, cameraModel: filterCameraModel)
        if dates != nil {
            let moments:[Moment] = Moments().read(dates!, groupByPlace: groupByPlace)
            
            let duplicates:Duplicates = ModelStore.getDuplicatePhotos()
            
            if groupByPlace {
                for place in moments {
                    if place.place == "" {
                        continue
                    }
                    //print("PLACE \(place.place)")
                    self.addMomentPlaceTreeEntry(place: place)
                    for year in place.children {
                        //print("     YEAR \(year.year)")
                        var duplicateInYear:Bool = false
                        if duplicates.duplicates.index(where: {$0.year == year.year}) != nil {
                            duplicateInYear = true
                        }
                        year.hasDuplicates = duplicateInYear
                        
                        self.addMomentYearTreeEntry(year: year, groupByPlace: true)
                        for month in year.children {
                            //print("         MONTH \(month.month)")
                            var duplicateInMonth:Bool = false
                            if duplicates.duplicates.index(where: {$0.year == month.year && $0.month == month.month}) != nil {
                                duplicateInMonth = true
                            }
                            month.hasDuplicates = duplicateInMonth
                            
                            self.addMomentMonthTreeEntry(month: month, groupByPlace: true)
                            for day in month.children {
                                //print("              DAY \(day.day)")
                                var duplicateInDay:Bool = false
                                if duplicates.duplicates.index(where: {$0.year == day.year && $0.month == day.month && $0.day == day.day}) != nil {
                                    duplicateInDay = true
                                }
                                day.hasDuplicates = duplicateInDay
                                
                                self.addMomentDayTreeEntry(day: day, groupByPlace: true)
                            }
                        }
                    }
                }
                
                self.lastCheckLocationChange = Date()
                
            }else{
                for year in moments {
                    
                    var duplicateInYear:Bool = false
                    if duplicates.duplicates.index(where: {$0.year == year.year}) != nil {
                        duplicateInYear = true
                    }
                    year.hasDuplicates = duplicateInYear
                    
                    self.addMomentYearTreeEntry(year: year, groupByPlace: false)
                    for month in year.children {
                        
                        var duplicateInMonth:Bool = false
                        if duplicates.duplicates.index(where: {$0.year == month.year && $0.month == month.month}) != nil {
                            duplicateInMonth = true
                        }
                        month.hasDuplicates = duplicateInMonth
                        
                        self.addMomentMonthTreeEntry(month: month, groupByPlace: false)
                        for day in month.children {
                            
                            var duplicateInDay:Bool = false
                            if duplicates.duplicates.index(where: {$0.year == day.year && $0.month == day.month && $0.day == day.day}) != nil {
                                duplicateInDay = true
                            }
                            day.hasDuplicates = duplicateInDay
                            
                            self.addMomentDayTreeEntry(day: day, groupByPlace: false)
                        }
                    }
                }
                self.lastCheckPhotoTakenDateChange = Date()
            }
        }else{
            print("no dates")
        }
    }
    
    func loadDemoPathToTree() {
        self.loadPathToTree("/MacStorage/photo.huawei.honor8.wjj")
    }
    
    func loadPathToTree(_ startingPath:String){
        let imageFolders = ImageFolderTreeScanner.default.scanImageFolder(path: startingPath)
        
        if imageFolders.count > 0 {
            for imageFolder:ImageFolder in imageFolders {
                self.addLibraryTreeEntry(imageFolder: imageFolder)
            }
            
            ExportManager.disable()
            // scan photo files
            //let startingFolder:ImageFolder = imageFolders[0]
            DispatchQueue.global().async {
                for folder in imageFolders {
                    self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage,
                        onCompleted: { data in
                            self.creatingRepository = false
                            ExportManager.enable()
                    })
                    self.imagesLoader.load(from: folder.url, indicator:self.collectionLoadingIndicator)
                    //self.refreshCollectionView()
                }
                
            }
        }
    }
    
    func refreshLibraryTree() {
        //print("REFRESHING MOMENT TREE at \(Date())")
        let count = self.libraryItem().children.count
        // remove items in moments
        for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
            //let index:Int = i - 1
            
            self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                        inParent: self.libraryItem(),
                                        withAnimation: NSTableView.AnimationOptions.slideUp)
        }
        self.libraryItem().children.removeAll()
        self.loadPathToTreeFromDatabase()
        self.sourceList.reloadData()
    }
    
    func refreshEventTree() {
        //print("REFRESHING MOMENT TREE at \(Date())")
        let count = self.eventItem().children.count
        // remove items in moments
        for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
            //let index:Int = i - 1
            self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                        inParent: self.eventItem(),
                                        withAnimation: NSTableView.AnimationOptions.slideUp)
        }
        self.eventItem().children.removeAll()
        self.loadEventsToTreeFromDatabase()
        self.sourceList.reloadData()
    }
    
    func saveTreeItemsExpandState() {
        
        // save expandable state of all items, mark by moment.id
        for idItem in self.treeIdItems {
            let expanded = self.sourceList.isItemExpanded(idItem.value)
            self.treeIdItemsExpandState[idItem.key] = expanded
            //if expanded {
            //    print("EXPANDED \(idItem.key)")
            //}
        }
    }
    
    func refreshMomentTree() {
        
        
        //print("REFRESHING MOMENT TREE at \(Date())")
        let count = self.momentItem().children.count
        // remove items in moments
        for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
            //let index:Int = i - 1
            self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                        inParent: self.momentItem(),
                                        withAnimation: NSTableView.AnimationOptions.slideUp)
        }
        self.momentItem().children.removeAll()
        self.loadMomentsToTreeFromDatabase(groupByPlace: false, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel)
        self.sourceList.reloadData()
        
        
    }
    
    func restoreTreeItemsExpandState() {
        // restore expanded state of expanded items, search by moment.id
        for parent in self.treeIdItemsExpandState.sorted(by: { $0.key.localizedCaseInsensitiveCompare($1.key) == ComparisonResult.orderedAscending }) {
            if parent.value {
                //print("EXPANDING \(parent.key)")
                let item = self.treeIdItems[parent.key]
                self.sourceList.expandItem(item)
            }
        }
    }
    
    func restoreTreeSelection(){
        guard self.treeLastSelectedIdentifier != "" && !treeRefreshing else {return}
        treeRefreshing = true
        // restore selection
        for idItem in self.treeIdItems {
            if idItem.key == self.treeLastSelectedIdentifier {
                //print("SELECT \(idItem.key)")
                let row = self.sourceList.row(forItem: idItem.value)
                self.sourceList.scrollRowToVisible(row)
                self.sourceList.selectRowIndexes(NSIndexSet(index: row) as IndexSet, byExtendingSelection: false)
                //self.sourceList.highlightSelection(inClipRect: self.sourceList.rect(ofRow: row))
                break
            }
        }
        treeRefreshing = false
    }
    
    func refreshLocationTree() {
        //print("REFRESHING LOCATION TREE at \(Date())")
        let count = self.placeItem().children.count
        // remove item in places
        for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
            //let index:Int = i - 1
            self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                        inParent: self.placeItem(),
                                        withAnimation: NSTableView.AnimationOptions.slideUp)
        }
        self.placeItem().children.removeAll()
        self.loadMomentsToTreeFromDatabase(groupByPlace: true, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel)
        self.sourceList.reloadData()
    }
    
    func loadPathToTreeFromDatabase() {
        let imageFolders = ImageFolderTreeScanner.default.scanImageFolderFromDatabase()
        
        if imageFolders.count > 0 {
            for imageFolder:ImageFolder in imageFolders {
                self.addLibraryTreeEntry(imageFolder: imageFolder)
            }
        }
    }
    
    func libraryItem() -> PXSourceListItem {
        return self.sourceListItems![0] as! PXSourceListItem
    }
    
    func momentItem() -> PXSourceListItem {
        return self.sourceListItems![1] as! PXSourceListItem
    }
    
    func eventItem() -> PXSourceListItem {
        return self.sourceListItems![2] as! PXSourceListItem
    }
    
    func placeItem() -> PXSourceListItem {
        return self.sourceListItems![3] as! PXSourceListItem
    }
    
    func addTreeSection(title:String) -> PXSourceListItem {
        let item:PXSourceListItem = PXSourceListItem(title: title, identifier: "")
        self.sourceListItems?.add(item)
        self.identifiersOfLibraryTree[title] = item
        return item
    }
    
    func addLibraryTreeEntry(imageFolder:ImageFolder) {
        var _parent:PXSourceListItem
        if imageFolder.parent == nil {
            _parent = self.librarySectionOfTree!
        }else{
            _parent = self.identifiersOfLibraryTree[(imageFolder.parent?.url.path)!]!
        }
        
        let collection:PhotoCollection = PhotoCollection(title: imageFolder.getPathExcludeParent(),
                                                         identifier: imageFolder.url.path,
                                                         type: imageFolder.children.count == 0 ? .userCreated : .library,
                                                         source: .library)
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        //self.modelObjects?.add(collection)
        _parent.addChildItem(item)
        collection.photoCount = imageFolder.countOfImages
        
        self.identifiersOfLibraryTree[imageFolder.url.path] = item
        
        collection.imageFolder = imageFolder
        imageFolder.photoCollection = collection
        
        self.treeIdItems[imageFolder.url.path] = item
        
    }
    
    func addMomentPlaceTreeEntry(place:Moment){
        let collection:PhotoCollection = PhotoCollection(title: place.represent,
                                                         identifier: place.id,
                                                         type: place.photoCount == 0 ? .userCreated : .library,
                                                         source: .place)
        collection.photoCount = place.photoCount
        collection.place = place.place
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: placesIcon)
        
        // add tree relationship
        self.placeItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollectionGroupByPlace["\(place.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTreeGroupByPlace["\(place.place)"] = item
        
        self.treeIdItems[place.id] = item
    }
    
    func addMomentYearTreeEntry(year:Moment, groupByPlace:Bool = false){
        if !groupByPlace {
            //print("YEAR \(year.represent) \(year.year) , count \(year.photoCount)")
        }
        let collection:PhotoCollection = PhotoCollection(title: year.represent,
                                                         identifier: year.id,
                                                         type: year.photoCount == 0 ? .userCreated : .library,
                                                         source: groupByPlace ? .place : .moment)
        collection.photoCount = year.photoCount
        collection.year = year.year
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        if groupByPlace {
            collection.place = year.place
            
            // add tree relationship
            self.parentsOfMomentsTreeGroupByPlace["\(year.place)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollectionGroupByPlace["\(year.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTreeGroupByPlace["\(year.place)-\(year.year)"] = item
            
        }else{
            // add tree relationship
            self.momentItem().addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollection["\(year.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTree["\(year.year)"] = item
        }
        
        self.treeIdItems[year.id] = item
    }
    
    func addMomentMonthTreeEntry(month:Moment, groupByPlace:Bool = false){
        if !groupByPlace {
            //print("MONTH \(month.represent) \(month.year) , count \(month.photoCount)")
        }
        let collection:PhotoCollection = PhotoCollection(title: month.represent,
                                                         identifier: month.id,
                                                         type: month.photoCount == 0 ? .userCreated : .library,
                                                         source: groupByPlace ? .place : .moment)
        collection.photoCount = month.photoCount
        collection.year = month.year
        collection.month = month.month
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        if groupByPlace  {
            collection.place = month.place
            //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)"])
            // add tree relationship
            self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollectionGroupByPlace["\(month.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)-\(month.month)"] = item
            //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)-\(month.month)"])
            
        }else {
            // add tree relationship
            self.parentsOfMomentsTree["\(month.year)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollection["\(month.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTree["\(month.year)-\(month.month)"] = item
        }
        
        self.treeIdItems[month.id] = item
    }
    
    func addMomentDayTreeEntry(day:Moment, groupByPlace:Bool = false){
        let collection:PhotoCollection = PhotoCollection(title: day.represent,
                                                         identifier: day.id,
                                                         type: day.photoCount == 0 ? .userCreated : .library,
                                                         source: groupByPlace ? .place : .moment)
        collection.photoCount = day.photoCount
        collection.year = day.year
        collection.month = day.month
        collection.day = day.day

        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        if groupByPlace  {
            collection.place = day.place
            //print(self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"])
            // add tree relationship
            self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollectionGroupByPlace["\(day.id)"] = collection
            
        }else {
        
            // add tree relationship
            self.parentsOfMomentsTree["\(day.year)-\(day.month)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollection["\(day.id)"] = collection
        }
        
        self.treeIdItems[day.id] = item
    }
    
    
    func addEventTreeEntry(event:Event){
        let collection:PhotoCollection = PhotoCollection(title: event.represent,
                                                         identifier: event.represent,
                                                         type: event.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = event.photoCount
        collection.event = event.event
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)
        
        // add tree relationship
        self.eventItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(event.id)"] = collection
        
        // for children to find parent
        self.parentsOfEventsTree["\(event.event)"] = item
        
        self.treeIdItems[event.id] = item
    }
    
    func addEventMonthTreeEntry(month:Event){
        let collection:PhotoCollection = PhotoCollection(title: month.represent,
                                                         identifier: month.represent,
                                                         type: month.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = month.photoCount
        collection.event = month.event
        collection.year = month.year
        collection.month = month.month
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)

        //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)"])
        // add tree relationship
        self.parentsOfEventsTree["\(month.event)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(month.id)"] = collection
        
        // for children to find parent
        self.parentsOfEventsTree["\(month.event)-\(month.year)-\(month.month)"] = item
        //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)-\(month.month)"])
        
        self.treeIdItems[month.id] = item
            
    }
    
    func addEventDayTreeEntry(day:Event){
        let collection:PhotoCollection = PhotoCollection(title: day.represent,
                                                         identifier: day.represent,
                                                         type: day.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = day.photoCount
        collection.event = day.event
        collection.year = day.year
        collection.month = day.month
        collection.day = day.day
        collection.place = day.place
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)
        
        //print(self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"])
        // add tree relationship
        self.parentsOfEventsTree["\(day.event)-\(day.year)-\(day.month)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(day.id)"] = collection
        
        self.treeIdItems[day.id] = item

    }
    
}


extension ViewController : PXSourceListDelegate {
    
    func sourceList(_ sourceList: PXSourceList!, isGroupAlwaysExpanded group: Any!) -> Bool {
        return true
    }
    
    func sourceList(_ aSourceList:PXSourceList!, viewForItem item: Any!) -> NSView {
        var cellView: LCSourceListTableCellView? = nil
        if let sourceListItem: PXSourceListItem = item as? PXSourceListItem {
            
            if aSourceList.level(forItem: item) == 0 {
                let sectionCellView:PXSourceListTableCellView = (aSourceList.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: nil) as! PXSourceListTableCellView)
                sectionCellView.textField?.textColor = NSColor.white
                sectionCellView.textField?.stringValue = sourceListItem.title
                return sectionCellView
            } else {
                cellView = (aSourceList.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCell"), owner: nil) as! LCSourceListTableCellView)
            }
            if let t:String = sourceListItem.title {
                cellView?.textField?.stringValue = t
                //print(t)
            }
            
            cellView?.imageView?.image = sourceListItem.icon
            
            //print(sourceListItem.representedObject)
            
            if sourceListItem.representedObject == nil {
                // section, do nothing
                //print("COLLECTION IS NULL \(sourceListItem.title ?? "")")
                
                //if self.momentToCollection[sourceListItem.title] != nil {
                //    let _ = self.momentToCollection[sourceListItem.title]!
                    //print("found collection: \(collection.title) \(collection.photoCount)")
                //}
            }else{
                let collection: PhotoCollection = sourceListItem.representedObject as! PhotoCollection
                
                //print("COLLECTION: \(collection.title) , count: \(collection.photoCount)")
                
                let sourceTitle:String? = sourceListItem.title
                let collectionTitle:String? = collection.title
                if sourceTitle != nil && sourceTitle != "" {
                    cellView?.textField?.stringValue = sourceListItem.title
                } else {
                    if collectionTitle != nil && collectionTitle != "" {
                        cellView?.textField?.stringValue = collection.title
                    }
                }
                if sourceTitle == nil && collectionTitle != nil {
                    cellView?.textField?.stringValue = collectionTitle!
                }
                cellView?.badge?.stringValue = " \(collection.photoCount) "
                cellView?.badge?.isHidden = (collection.photoCount == 0)
                
            
            }
            return cellView!
        }else {
            return cellView!
        }
    }
    
    func sourceListSelectionDidChange(_ notification: Notification!) {
        guard !self.treeRefreshing else {return}
        //var removeButtonEnabled:Bool = false
        if let selectedItem:PXSourceListItem = self.sourceList.item(atRow: self.sourceList.selectedRow) as? PXSourceListItem {
            
            if let collection:PhotoCollection = selectedItem.representedObject as? PhotoCollection {
                
                if collection.source! == .library {
                    self.selectImageFolder(collection.imageFolder!)
                }else if collection.source! == .moment {
                    //print("selected moment \(collection.title)")
                    self.selectMoment(collection, groupByPlace: false)
                }else if collection.source! == .place {
                    //print("selected place moment \(collection.title)")
                    self.selectMoment(collection, groupByPlace: true)
                }else if collection.source! == .event {
                    //print("selected place moment \(collection.title)")
                    self.selectEvent(collection)
                }
                
                self.treeLastSelectedIdentifier = collection.identifier
            }
        }
    }
    
}

extension ViewController : PXSourceListDataSource {
    func sourceList(_ sourceList: PXSourceList!, numberOfChildrenOfItem item: Any!) -> UInt {
        if item != nil {
            if let node = item as? PXSourceListItem {
                return UInt(node.children.count)
            }else {
                return UInt(self.sourceListItems!.count)
            }
        } else{
            // when just init sections
            return UInt(4)
        }
    }
    
    func sourceList(_ aSourceList: PXSourceList!, child index: UInt, ofItem item: Any!) -> Any! {
        if let node = item as? PXSourceListItem {
            //print("getting child of item \(node.title) \(index)/\(node.children.count)")
            return node.children[Int(index)]
        }else{
            return self.sourceListItems?[Int(index)] ?? PXSourceListItem()
        }
    }
    
    func sourceList(_ aSourceList: PXSourceList!, isItemExpandable item: Any!) -> Bool {
        if let node = item as? PXSourceListItem {
            return node.hasChildren()
        }else{
            return false
        }
    }
    
    
}
