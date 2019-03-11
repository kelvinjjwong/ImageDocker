//
//  FaceCollectionViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/2.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class FaceCollectionViewController : NSViewController {
    
    private var enableNameLabel = true
    
    func withoutName() {
        self.enableNameLabel = false
    }
    
    // MARK: Properties
    @IBOutlet weak var collectionView : NSCollectionView!
    
    let imagesLoader = FaceCollectionViewItemsLoader()
    
    var onItemClicked: ((PeopleFace) -> Void)? = nil
    
    
    fileprivate var selectedIndexPaths:Set<IndexPath> = []
    
    // MARK: Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


// MARK: - NSCollectionViewDataSource
extension FaceCollectionViewController : NSCollectionViewDataSource {
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return imagesLoader.numberOfSections
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesLoader.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FaceCollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? FaceCollectionViewItem else {return item}
        
        collectionViewItem.enableNameLabel = self.enableNameLabel
        
        let face = imagesLoader.item(for: indexPath as NSIndexPath)
        
        DispatchQueue.main.async {
            collectionViewItem.face = face
        }
        face.collectionViewItem = collectionViewItem
        
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
extension FaceCollectionViewController : NSCollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return imagesLoader.singleSectionMode ? NSZeroSize : NSSize(width: 1000, height: 40)
    }
    
}

// MARK: - NSCollectionViewDelegate
extension FaceCollectionViewController : NSCollectionViewDelegate {
    
    func restoreHighlightedItems() {
        if self.selectedIndexPaths.count > 0 {
            self.highlightItems(selected: true, atIndexPaths: self.selectedIndexPaths, click: false)
        }
    }
    
    
    func highlightItems(selected: Bool, atIndexPaths: Set<IndexPath>, click:Bool = true) {
        for indexPath in atIndexPaths {
            guard let item = collectionView.item(at: indexPath) else {continue}
            let viewItem = item as! FaceCollectionViewItem
            viewItem.setHighlight(selected: selected)
            
            if click && selected && self.onItemClicked != nil {
                self.onItemClicked!(viewItem.face!)
            }
        }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        self.selectedIndexPaths = indexPaths
        print("selected: \(indexPaths.first?.item)")
        highlightItems(selected: true, atIndexPaths: indexPaths)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths)
    }
    
}
