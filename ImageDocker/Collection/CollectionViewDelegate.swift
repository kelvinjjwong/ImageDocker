//
//  CollectionViewDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func highlightItems(selected: Bool, atIndexPaths: Set<IndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath) else {continue}
            let viewItem = item as! CollectionViewItem
            viewItem.setHighlight(selected: selected)
            if selected {
                //print("SELECTED IMAGE COORD IS ZERO ? \(viewItem.imageFile?.location.coordinate?.isZero) - \(viewItem.imageFile?.fileName)")
                self.selectImageFile(viewItem.imageFile!)
            }
        }
    }
    
    func refreshCollectionView() {
        //print("REFRESH COLLECTION VIEW")
        var needRefreshLocation = false
        for item in imagesLoader.getItems() {
            if item.location.place == "" && item.location.coordinate != nil && (item.location.coordinate?.isNotZero)! {
                needRefreshLocation = true
            }
        }
        if needRefreshLocation {
            //print("REFRESH LOCATIONS")
            refreshImagesLocation()
        }else{
            //print("REORG ITEMS")
            DispatchQueue.main.async{
                self.imagesLoader.reorganizeItems(considerPlaces: (self.considerPlacesCheckBox.state == NSButton.StateValue.on))
                self.collectionView.reloadData()
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


// MARK: - NSCollectionViewDataSource
extension ViewController : NSCollectionViewDataSource {
  
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return imagesLoader.numberOfSections
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesLoader.numberOfItems(in: section)
    }
  
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        collectionViewItem.setCheckBoxDelegate(self)
        collectionViewItem.sectionIndex = indexPath.section

        let imageFile = imagesLoader.item(for: indexPath as NSIndexPath)
        DispatchQueue.main.async {
            collectionViewItem.imageFile = imageFile
        }
        imageFile.collectionViewItem = collectionViewItem
        
        let isItemSelected = collectionView.selectionIndexPaths.contains(indexPath)
        collectionViewItem.setHighlight(selected: isItemSelected)

        return item
    }
  
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.SupplementaryElementKind.sectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderView"), for: indexPath as IndexPath) as! HeaderView
        view.setCheckBoxDelegate(self)
        view.sectionIndex = indexPath.section
        
        view.sectionTitle.stringValue = imagesLoader.titleOfSection(indexPath.section)
        let numberOfItemsInSection = imagesLoader.numberOfItems(in: indexPath.section)
        view.imageCount.stringValue = "\(numberOfItemsInSection) images"
        
        return view
    }
  
}

// MARK: - NSCollectionViewDelegateFlowLayout
extension ViewController : NSCollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return imagesLoader.singleSectionMode ? NSZeroSize : NSSize(width: 1000, height: 40)
    }
  
}

// MARK: - NSCollectionViewDelegate
extension ViewController : NSCollectionViewDelegate {
  
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths)
    }

    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths)
    }
  
}


protocol PlacesCompletionEvent {
    func onPlacesCompleted()
}

extension ViewController : PlacesCompletionEvent {
    
    func onPlacesCompleted() {
        DispatchQueue.main.async{
            self.imagesLoader.reorganizeItems(considerPlaces: (self.considerPlacesCheckBox.state == NSButton.StateValue.on))
            self.collectionView.reloadData()
        }
    }
}

protocol CollectionViewItemCheckDelegate {
    func onCollectionViewItemCheck(_ item:CollectionViewItem, checkBySection:Bool)
    func onCollectionViewItemUncheck(_ item:CollectionViewItem, checkBySection:Bool)
}

extension ViewController : CollectionViewItemCheckDelegate {
    
    func checkSectionIfAllItemsChecked(_ item: CollectionViewItem) {
        if let indexPath = collectionView.indexPath(for: item) {
            let section = collectionView.supplementaryView(forElementKind: NSCollectionView.SupplementaryElementKind.sectionHeader, at: IndexPath(item: 0, section: indexPath.section))
            
            if section != nil {
                
                let section = section as! HeaderView
            
                var shouldCheckSection:Bool = true
                let sec = imagesLoader.getSection(title: section.sectionTitle.stringValue, createIfNotExist: false)
                if sec != nil {
                    
                    for item in (sec?.items)! {
                        if !(item.collectionViewItem?.isChecked())! {
                            shouldCheckSection = false
                            break
                        }
                    }
                }
                
                if shouldCheckSection {
                    section.check(ignoreDelegate: true)
                }
            }
        }
    }
    
    func uncheckSectionIfAllItemsUnchecked(_ item: CollectionViewItem) {
        if let indexPath = collectionView.indexPath(for: item) {
            let section = collectionView.supplementaryView(forElementKind: NSCollectionView.SupplementaryElementKind.sectionHeader, at: IndexPath(item: 0, section: indexPath.section))
            
            if section != nil {
                
                let section = section as! HeaderView
                
                //print("section title: \(section.sectionTitle.stringValue)")
                var shouldUncheckSection:Bool = true
                let sec = imagesLoader.getSection(title: section.sectionTitle.stringValue, createIfNotExist: false)
                if sec != nil {
                    
                    for item in (sec?.items)! {
                        if (item.collectionViewItem?.isChecked())! {
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
        //print("checked: \(item.imageFile?.url.lastPathComponent ?? "")")
        if let imageFile = item.imageFile {
            self.selectionViewController.imagesLoader.addItem(imageFile)
            self.selectionViewController.imagesLoader.reorganizeItems()
            //self.selectionViewController.collectionView.reloadData()
            self.selectionCollectionView.reloadData()
            
            if !checkBySection {
                checkSectionIfAllItemsChecked(item)
            }
        }
        
    }
    
    func onCollectionViewItemUncheck(_ item: CollectionViewItem, checkBySection:Bool) {
        //print("unchecked: \(item.imageFile?.url.lastPathComponent ?? "")")
        if let imageFile = item.imageFile {
            self.selectionViewController.imagesLoader.removeItem(imageFile)
            self.selectionViewController.imagesLoader.reorganizeItems()
            //self.selectionViewController.collectionView.reloadData()
            self.selectionCollectionView.reloadData()
            
            if !checkBySection {
                uncheckSectionIfAllItemsUnchecked(item)
            }
        }
    }
    
    
}

protocol CollectionViewHeaderCheckDelegate {
    func onCollectionViewHeaderCheck(_ header: HeaderView)
    func onCollectionViewHeaderUncheck(_ header: HeaderView)
}

extension ViewController : CollectionViewHeaderCheckDelegate {
    func onCollectionViewHeaderCheck(_ header: HeaderView) {
        let section = self.imagesLoader.getSection(title: header.sectionTitle.stringValue, createIfNotExist: false)
        if section != nil {
            for item in (section?.items)! {
                item.collectionViewItem?.check(checkBySection: true)
            }
        }
    }
    
    func onCollectionViewHeaderUncheck(_ header: HeaderView) {
        let section = self.imagesLoader.getSection(title: header.sectionTitle.stringValue, createIfNotExist: false)
        if section != nil {
            for item in (section?.items)! {
                item.collectionViewItem?.uncheck(checkBySection: true)
            }
        }
        
    }
    
}

class MetaConsumer : LocationConsumer {
    
    
    var imageFile:ImageFile
    let accumulator:Accumulator?
    let onCompleteHandler:PlacesCompletionEvent?
    
    init(_ imageFile:ImageFile, accumulator:Accumulator? = nil, onComplete:PlacesCompletionEvent? = nil){
        self.imageFile = imageFile
        self.accumulator = accumulator
        self.onCompleteHandler = onComplete
        //print("META CONSUMER INIT")
    }
    
    private func checkComplete(){
        if accumulator != nil && (accumulator?.add("Organizing images ..."))! {
            if self.onCompleteHandler != nil {
                //print("ON COMPLETE")
                onCompleteHandler?.onPlacesCompleted()
            }
        }else{
            //print("ACCUMULATOR IS NULL")
        }
    }
    
    func consume(location:Location){
        //print("CONSUME LOCATION")
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: location.country))
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: location.province))
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: location.city))
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: location.district))
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: location.street))
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: location.businessCircle))
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: location.address))
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: location.addressDescription))
        
        imageFile.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: location.place))
        
        imageFile.recognizePlace()
        //print("total \(accumulator?._target) , current \(accumulator?.current())")
        //print("======")
        
        
        checkComplete()
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        print("\(status) : \(message)")
    }
    
}

