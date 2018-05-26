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
                self.selectImageFile((viewItem.imageFile?.fileName)!)
            }
        }
    }
    
    func refreshCollectionView() {
        var needRefreshLocation = false
        for item in imagesLoader.getItems() {
            if item.place == "" {
                needRefreshLocation = true
            }
        }
        if needRefreshLocation {
            refreshImagesLocation()
        }else{
            DispatchQueue.main.async{
                self.imagesLoader.reorganizeItems(considerPlaces: (self.considerPlacesCheckBox.state == NSButton.StateValue.on))
            }
        }
    }
    
    func refreshImagesLocation() {
        if imagesLoader.getItems().count > 0 {
            let accumulator:Accumulator = Accumulator(target: imagesLoader.getItems().count, indicator: self.collectionProgressIndicator, lblMessage:self.indicatorMessage)
            for item in imagesLoader.getItems() {
                item.loadLocation(consumer: MetaConsumer(item, accumulator: accumulator, onComplete: self) as MetaInfoConsumeDelegate)
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

        let imageFile = imagesLoader.item(for: indexPath as NSIndexPath)
        DispatchQueue.main.async {
            collectionViewItem.imageFile = imageFile
        }

        let isItemSelected = collectionView.selectionIndexPaths.contains(indexPath)
        collectionViewItem.setHighlight(selected: isItemSelected)

        return item
    }
  
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.SupplementaryElementKind.sectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderView"), for: indexPath as IndexPath) as! HeaderView
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
    func onCollectionViewItemCheck(_ item:CollectionViewItem)
    func onCollectionViewItemUncheck(_ item:CollectionViewItem)
}

extension ViewController : CollectionViewItemCheckDelegate {
    func onCollectionViewItemCheck(_ item: CollectionViewItem) {
        print("checked: \(item.imageFile?.url.lastPathComponent ?? "")")
    }
    
    func onCollectionViewItemUncheck(_ item: CollectionViewItem) {
        print("unchecked: \(item.imageFile?.url.lastPathComponent ?? "")")
    }
    
    
}

class MetaConsumer : MetaInfoConsumeDelegate {
    
    var imageFile:ImageFile?
    let accumulator:Accumulator?
    let onCompleteHandler:PlacesCompletionEvent?
    
    init(_ imageFile:ImageFile, accumulator:Accumulator? = nil, onComplete:PlacesCompletionEvent? = nil){
        self.imageFile = imageFile
        self.accumulator = accumulator
        self.onCompleteHandler = onComplete
    }
    
    func consume(_ infos:[MetaInfo]){
        imageFile?.recognizePlace()
        
        if accumulator != nil && (accumulator?.add("Organizing images ..."))! {
            if self.onCompleteHandler != nil {
                onCompleteHandler?.onPlacesCompleted()
            }
        }
    }
    
}

