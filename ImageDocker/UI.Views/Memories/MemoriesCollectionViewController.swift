//
//  MemoriesCollectionViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/15.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class MemoriesCollectionViewController : NSViewController {
    
    // MARK: Properties
    @IBOutlet weak var collectionView : NSCollectionView!
    
    let imagesLoader = CollectionViewItemsLoader()
    
    var onItemClicked: ((ImageFile) -> Void)? = nil
    
    var selectedIndexSet:Set<IndexPath> = []
    
    // MARK: Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


// MARK: - NSCollectionViewDataSource
extension MemoriesCollectionViewController : NSCollectionViewDataSource {
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return imagesLoader.numberOfSections
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesLoader.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MemoryCollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? MemoryCollectionViewItem else {return item}
        //print("created item")
        let imageFile = imagesLoader.item(for: indexPath as NSIndexPath)
        DispatchQueue.main.async {
            collectionViewItem.imageFile = imageFile
        }
        imageFile.memoryCollectionViewItem = collectionViewItem
        
        let isItemSelected = collectionView.selectionIndexPaths.contains(indexPath)
        if selectedIndexSet.count == 0 && isItemSelected {
            selectedIndexSet = [indexPath]
        }
        collectionViewItem.setHighlight(selected: isItemSelected)
        
        return item
    }
    
    /// unused
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderView"), for: indexPath as IndexPath) as! HeaderView
        view.sectionTitle.stringValue = imagesLoader.titleOfSection(indexPath.section)
        let numberOfItemsInSection = imagesLoader.numberOfItems(in: indexPath.section)
        view.imageCount.stringValue = "\(numberOfItemsInSection) images"
        return view
    }
    
}

// MARK: - NSCollectionViewDelegateFlowLayout
/// unused
extension MemoriesCollectionViewController : NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return imagesLoader.singleSectionMode ? NSZeroSize : NSSize(width: 1000, height: 40)
    }
    
}

// MARK: - NSCollectionViewDelegate
extension MemoriesCollectionViewController : NSCollectionViewDelegate {
    
    func highlightItems(selected: Bool, atIndexPaths: Set<IndexPath>) {
        self.selectedIndexSet = atIndexPaths
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath) else {continue}
            let viewItem = item as! MemoryCollectionViewItem
            viewItem.setHighlight(selected: selected)
            
            if selected && self.onItemClicked != nil {
                self.onItemClicked!(viewItem.imageFile!)
            }
        }
    }
    
    func cleanHighlights() {
        for indexPath in self.selectedIndexSet {
            guard let item = collectionView.item(at: indexPath) else {continue}
            let viewItem = item as! MemoryCollectionViewItem
            viewItem.setHighlight(selected: false)
        }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths)
    }
    
}
