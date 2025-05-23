//
//  CollectionViewDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//

import Cocoa
import LoggerFactory

extension ViewController {
    
    func highlightItems(selected: Bool, atIndexPaths: Set<IndexPath>) {
        let isMultipleSelection = atIndexPaths.count > 1
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath) else {continue}
            let viewItem = item as! CollectionViewItem
            viewItem.setHighlight(selected: selected, isMultipleSelection: isMultipleSelection)
            if selected {
                //self.logger.log(.trace, "SELECTED IMAGE COORD IS ZERO ? \(viewItem.imageFile?.location.coordinate?.isZero) - \(viewItem.imageFile?.fileName)")
                self.selectImageFile(viewItem.imageFile!)
            }
        }
    }
    
    func refreshCollectionView() {
        //self.logger.log(.trace, "REFRESHING COLLECTION VIEW")
        var needRefreshLocation = false
        for item in imagesLoader.getItems() {
            if item.location.place == "" && item.location.coordinate != nil && (item.location.coordinate?.isNotZero)! {
                needRefreshLocation = true
            }
        }
        if needRefreshLocation {
            //self.logger.log(.trace, "REFRESH LOCATIONS")
            refreshImagesLocation()
        }else{
            //self.logger.log(.trace, "REORG ITEMS")
            DispatchQueue.main.async{
                self.imagesLoader.reorganizeItems(considerPlaces: true)
                self.logger.log(.trace, "reloading data in main collection view")
                self.collectionView.reloadData()
                self.logger.log(.trace, "reloaded data in main collection view")
            }
        }
    }
    
    func refreshImagesLocation() {
        if imagesLoader.getItems().count > 0 {
            let accumulator:Accumulator = Accumulator(target: imagesLoader.getItems().count, indicator: self.collectionProgressIndicator, lblMessage:self.indicatorMessage)
            for item in imagesLoader.getItems() {
                item.loadLocation(locationConsumer: MetaConsumer(item, accumulator: accumulator, onComplete: self))
            }
        }
    }
}


// MARK: - DATA SOURCE

extension ViewController : NSCollectionViewDataSource {
  
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return imagesLoader.numberOfSections
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesLoader.numberOfItems(in: section)
    }
    
    func onSelectedCollectionItem() {
        self.btnImageOptions.isEnabled = true
    }
    
    func onUnselectedCollectionItem() {
        let rightPanel = self.verticalSplitView.arrangedSubviews[1]
        if rightPanel.isHidden {
            self.btnImageOptions.isEnabled = false
        }
    }
  
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        collectionViewItem.setCheckBoxDelegate(self)
        collectionViewItem.setShowDuplicatesDelegate(self)
        collectionViewItem.setQuickLookDelegate(self)
        collectionViewItem.setPreviewDelegate(self)
        collectionViewItem.setPreviewMessageDelegate(self)
        collectionViewItem.onSelected = self.onSelectedCollectionItem
        collectionViewItem.onUnselected = self.onUnselectedCollectionItem
        collectionViewItem.sectionIndex = indexPath.section

        let imageFile = imagesLoader.item(for: indexPath as NSIndexPath)
        DispatchQueue.main.async {
            collectionViewItem.imageFile = imageFile
            imageFile.collectionViewItem = collectionViewItem
            imageFile.collectionCheckBox = collectionViewItem.checkBox
        }
        
        let isItemSelected = collectionView.selectionIndexPaths.contains(indexPath)
        collectionViewItem.setHighlight(selected: isItemSelected)

        return item
    }
  
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderView"), for: indexPath as IndexPath) as! HeaderView
        view.uncheck(ignoreDelegate: true)
        view.setCheckBoxDelegate(self)
        view.sectionIndex = indexPath.section
        
        let title = imagesLoader.titleOfSection(indexPath.section)
        let place = imagesLoader.placeOfSection(indexPath.section)
        let peopleGroups = imagesLoader.peopleGroupsOfSection(indexPath.section)
        
        view.title = title
        view.place = place
        view.peopleGroups = peopleGroups
        
        view.sectionTitle.stringValue = "\(title)"
        
        if place != "" && peopleGroups != "" {
            view.lblPlace.stringValue = place
            view.iconPlace.image = Icons.places
            
            view.lblPeople.stringValue = peopleGroups
            view.iconPeople.image = Icons.people
            
            view.lblSummary.stringValue = ""
            view.iconSummary.image = nil
        }else {
            if place != "" {
                view.lblSummary.stringValue = place
                view.iconSummary.image = Icons.places
            }else if peopleGroups != "" {
                view.lblSummary.stringValue = peopleGroups
                view.iconSummary.image = Icons.people
            }else{
                view.lblSummary.stringValue = ""
                view.iconSummary.image = nil
            }
            
            view.lblPlace.stringValue = ""
            view.iconPlace.image = nil
            
            view.lblPeople.stringValue = ""
            view.iconPeople.image = nil
        }
        
        let numberOfItemsInSection = imagesLoader.numberOfItems(in: indexPath.section)
        view.imageCount.stringValue = Words.n_images.fill(arguments: numberOfItemsInSection)
        
        view.wantsLayer = true
        view.layer?.backgroundColor = Colors.MidGray.cgColor
        
        return view
    }
  
}

// MARK: - SELECTION

extension ViewController : NSCollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return imagesLoader.singleSectionMode ? NSZeroSize : NSSize(width: 1000, height: 40)
    }
  
}

extension ViewController : NSCollectionViewDelegate {
  
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths)
    }

    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths)
    }
  
}

// MARK: - PREVIEW

protocol CollectionViewItemPreviewDelegate {
    func onCollectionViewItemPreview(imageFile: ImageFile, isRawVersion:Bool)
}

extension ViewController : CollectionViewItemPreviewDelegate {
    
    func onCollectionViewItemPreview(imageFile: ImageFile, isRawVersion:Bool) {
        self.loadImageMetaAndPreview(imageFile: imageFile)
        self.previewImage(image: imageFile, isRawVersion: isRawVersion)
        DispatchQueue.main.async {
            if isRawVersion {
                self.lblImageDescription.stringValue = Words.backupVersion.word()
            }else{
                self.lblImageDescription.stringValue = Words.editableVersion.word()
            }
        }
    }
}

// MARK: - PREVIEW MESSAGE

protocol CollectionViewItemPreviewMessageDelegate {
    func onCollectionViewItemPreviewMessage(description:String)
}

extension ViewController : CollectionViewItemPreviewMessageDelegate {
    func onCollectionViewItemPreviewMessage(description:String) {
        MessageEventCenter.default.showMessage(type: "IMAGE", name: "DESCRIPTION", message: description)
    }
}

// MARK: - QUICK LOOK (larger view)

protocol CollectionViewItemQuickLookDelegate {
    func onCollectionViewItemQuickLook(_ image:ImageFile)
}

extension ViewController : CollectionViewItemQuickLookDelegate {
    func onCollectionViewItemQuickLook(_ image:ImageFile) {
        let viewController = TheaterViewController()
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 1200
        let windowHeight = 830
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "Image Viewer"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.viewInit(image: image)
        
//        if let window = self.theaterWindowController.window {
//            if self.theaterWindowController.isWindowLoaded {
//                window.makeKeyAndOrderFront(self)
//                self.logger.log(.trace, "order to front")
//            }else{
//                self.theaterWindowController.showWindow(self)
//                self.logger.log(.trace, "show window")
//            }
//            let vc = window.contentViewController as! TheaterViewController
//            vc.viewInit(image: image)
//        }
    }
    
    func onTreeItemQuickLook(collection: Moment, event:String? = nil){
        let viewController = TheaterViewController()
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 1200
        let windowHeight = 830
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "Image Viewer"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.viewInit(year: collection.year, month: collection.month, day: collection.day, event: event)
        
//        if let window = self.theaterWindowController.window {
//            if self.theaterWindowController.isWindowLoaded {
//                window.makeKeyAndOrderFront(self)
//                self.logger.log(.trace, "order to front")
//            }else{
//                self.theaterWindowController.showWindow(self)
//                self.logger.log(.trace, "show window")
//            }
//            let vc = window.contentViewController as! TheaterViewController
//            vc.viewInit(year: collection.year, month: collection.month, day: collection.day, event: event)
//        }
    }
}

// MARK: - DUPLICATED IMAGES

protocol CollectionViewItemShowDuplicatesDelegate {
    func onCollectionViewItemShowDuplicate(_ duplicatesKey:String)
}

extension ViewController : CollectionViewItemShowDuplicatesDelegate {
    func onCollectionViewItemShowDuplicate(_ duplicatesKey: String) {
        CachePrefetch.default.refresh()
        
        if let paths = ImageDuplicationDao.default.getDuplicatePhotos().keyToPath[duplicatesKey] {
            self.selectionViewController.collectionViewController.imagesLoader.clean()
            for path in paths {
                if let image = ImageRecordDao.default.getImage(path: path) {
                    let imageFile = ImageFile(image: image)
                    self.selectionViewController.collectionViewController.imagesLoader.addItem(imageFile)
                }
                
            }
            self.selectionViewController.collectionViewController.imagesLoader.reorganizeItems()
            self.selectionViewController.selectionCollectionView.reloadData()
        }
    }
    
}

// MARK: - CHECKBOX

protocol CollectionViewItemCheckDelegate {
    func onCollectionViewItemCheck(_ item:CollectionViewItem, checkBySection:Bool)
    func onCollectionViewItemUncheck(_ item:CollectionViewItem, checkBySection:Bool)
}

extension ViewController : CollectionViewItemCheckDelegate {
    
    func checkSectionIfAllItemsChecked(_ item: CollectionViewItem) {
        if let indexPath = collectionView.indexPath(for: item) {
            if let section = collectionView.supplementaryView(forElementKind: NSCollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) {
                
                let section = section as! HeaderView
            
                var shouldCheckSection:Bool = true
                if let sec = imagesLoader.getSection(title: section.sectionTitle.stringValue, createIfNotExist: false) {
                    
                    for item in sec.items {
                        if let i=item.collectionViewItem, !i.isChecked() {
                            shouldCheckSection = false
                            break
                        }
                    }
                }
                
                if shouldCheckSection {
                    section.check(ignoreDelegate: true)
                }else{
                    section.uncheck(ignoreDelegate: true)
                }
            }
        }
    }
    
    func uncheckSectionIfAllItemsUnchecked(_ item: CollectionViewItem) {
        if let indexPath = collectionView.indexPath(for: item) {
            if let section = collectionView.supplementaryView(forElementKind: NSCollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) {
                
                let section = section as! HeaderView
                
                //self.logger.log(.trace, "section title: \(section.sectionTitle.stringValue)")
                var shouldUncheckSection:Bool = true
                if let sec = imagesLoader.getSection(title: section.sectionTitle.stringValue, createIfNotExist: false) {
                    
                    for item in sec.items {
                        if let i = item.collectionViewItem, i.isChecked() {
                            shouldUncheckSection = false
                            break
                        }
                    }
                }
                
                if shouldUncheckSection {
                    section.uncheck(ignoreDelegate: true)
                }
            }
        }
    }
    
    func onCollectionViewItemCheck(_ item: CollectionViewItem, checkBySection:Bool) {
        //self.logger.log(.trace, "checked: \(item.imageFile?.url.lastPathComponent ?? "")")
        if let imageFile = item.imageFile {
//            self.selectionViewController.collectionViewController.imagesLoader.addItem(imageFile)
//            self.selectionViewController.collectionViewController.imagesLoader.reorganizeItems()
//            //self.selectionViewController.collectionView.reloadData()
//            self.selectionViewController.selectionCollectionView.reloadData()
            self.selectionViewController.addItem(imageFile: imageFile)
            
            if !checkBySection {
                checkSectionIfAllItemsChecked(item)
            }
        }
        
    }
    
    func onCollectionViewItemUncheck(_ item: CollectionViewItem, checkBySection:Bool) {
        //self.logger.log(.trace, "unchecked: \(item.imageFile?.url.lastPathComponent ?? "")")
        if let imageFile = item.imageFile {
            self.selectionViewController.removeOneFromSelectionArea(imageFile)
            
            if !checkBySection {
                uncheckSectionIfAllItemsUnchecked(item)
            }
        }
    }
    
    
}

// MARK: - HEADER CHECKBOX

protocol CollectionViewHeaderCheckDelegate {
    func onCollectionViewHeaderCheck(_ header: HeaderView)
    func onCollectionViewHeaderUncheck(_ header: HeaderView)
}

extension ViewController : CollectionViewHeaderCheckDelegate {
    func onCollectionViewHeaderCheck(_ header: HeaderView) {
        if let section = self.imagesLoader.getSection(title: header.title, place: header.place, peopleGroups: header.peopleGroups, createIfNotExist: false) {
            
            for item in section.items {
                if let imageFile = self.imagesLoader.getItem(id: item.imageData?.id ?? item.url.path()) {
                    imageFile.check()
                    DispatchQueue.main.async {
                        imageFile.collectionCheckBox?.state = .on
                    }
                    
                    self.selectionViewController.collectionViewController.imagesLoader.addItem(imageFile)
                }
            }
            
            self.selectionViewController.collectionViewController.imagesLoader.reorganizeItems()
            self.selectionViewController.selectionCollectionView.reloadData()
        }
    }
    
    func onCollectionViewHeaderUncheck(_ header: HeaderView) {
        if let section = self.imagesLoader.getSection(title: header.title, place: header.place, peopleGroups: header.peopleGroups, createIfNotExist: false) {
            for item in section.items {
                if let imageFile = self.imagesLoader.getItem(id: item.imageData?.id ?? item.url.path()) {
                    imageFile.uncheck()
                    DispatchQueue.main.async {
                        imageFile.collectionCheckBox?.state = .off
                    }
                    
                    self.selectionViewController.collectionViewController.imagesLoader.removeItem(imageFile)
                }
            }
            
            self.selectionViewController.collectionViewController.imagesLoader.reorganizeItems()
            self.selectionViewController.selectionCollectionView.reloadData()
            
        }
        
    }
    
}

// MARK: - PLACE LOCATION

protocol PlacesCompletionEvent {
    func onPlacesCompleted()
}

extension ViewController : PlacesCompletionEvent {
    
    func onPlacesCompleted() {
        DispatchQueue.main.async{
            self.imagesLoader.reorganizeItems(considerPlaces: true)
            self.collectionView.reloadData()
        }
    }
}

class MetaConsumer : LocationConsumer {
    
    let logger = LoggerFactory.get(category: "MetaConsumer")
    
    
    var imageFile:ImageFile
    let accumulator:Accumulator?
    let onCompleteHandler:PlacesCompletionEvent?
    
    init(_ imageFile:ImageFile, accumulator:Accumulator? = nil, onComplete:PlacesCompletionEvent? = nil){
        self.imageFile = imageFile
        self.accumulator = accumulator
        self.onCompleteHandler = onComplete
        //self.logger.log(.trace, "META CONSUMER INIT")
    }
    
    private func checkComplete(){
        if accumulator != nil && (accumulator?.add(Words.collection_organizing_images.word()))! {
            if self.onCompleteHandler != nil {
                //self.logger.log(.trace, "ON COMPLETE")
                onCompleteHandler?.onPlacesCompleted()
            }
        }else{
            //self.logger.log(.trace, "ACCUMULATOR IS NULL")
        }
    }
    
    func consume(location:Location){
        //self.logger.log(.trace, "CONSUME LOCATION")
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: location.country))
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: location.province))
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: location.city))
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: location.district))
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: location.street))
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: location.businessCircle))
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: location.address))
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: location.addressDescription))
//        
//        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: location.place))
        
        imageFile.recognizePlace()
        //self.logger.log(.trace, "total \(accumulator?._target) , current \(accumulator?.current())")
        //self.logger.log(.trace, "======")
        
        
        checkComplete()
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        self.logger.log(.trace, "\(status) : \(message)")
    }
    
}

