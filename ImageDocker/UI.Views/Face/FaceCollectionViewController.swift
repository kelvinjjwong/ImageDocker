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
    
    var selectedFaceIds:[String] = []
    
    func withoutName() {
        self.enableNameLabel = false
    }
    
    // MARK: Properties
    @IBOutlet weak var collectionView : NSCollectionView!
    
    let imagesLoader = FaceCollectionViewItemsLoader()
    
    var onItemClicked: ((PeopleFace, Bool) -> Void)? = nil
    
    
    fileprivate var selectedIndexPaths:Set<IndexPath> = []
    
    // MARK: Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func addSelectedFace(_ id:String) {
        for existId in self.selectedFaceIds {
            if existId == id {
                return
            }
        }
        self.selectedFaceIds.append(id)
    }
    
    fileprivate func removeSelectedFace(_ id:String) {
        if self.selectedFaceIds.count > 0 {
            var removeIndex = -1
            for i in 0..<self.selectedFaceIds.count {
                let faceid = self.selectedFaceIds[i]
                if id == faceid {
                    removeIndex = i
                }
            }
            if removeIndex >= 0 {
                self.selectedFaceIds.remove(at: removeIndex)
            }
        }
    }
    
    func clearSelections() {
        self.selectedFaceIds = []
    }
    
    func removeSelections() {
        if self.selectedIndexPaths.count > 0 {
            collectionView.deleteItems(at: self.selectedIndexPaths)
            self.selectedIndexPaths.removeAll()
        }
        self.selectedFaceIds = []
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
        
//        if isItemSelected {
//            self.addSelectedFace(face.data.id)
//        }else{
//            self.removeSelectedFace(face.data.id)
//        }
//
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        
        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderView"), for: indexPath as IndexPath) as! HeaderView
        view.sectionTitle.stringValue = imagesLoader.titleOfSection(indexPath.section)
        let numberOfItemsInSection = imagesLoader.numberOfItems(in: indexPath.section)
        view.imageCount.stringValue = Words.n_images.fill(arguments: numberOfItemsInSection)
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
            
            if click && self.onItemClicked != nil {
                self.onItemClicked!(viewItem.face!, selected)
            }
            
            let face = imagesLoader.item(for: indexPath as NSIndexPath)
            if selected {
                self.addSelectedFace(face.data.id)
            }else{
                self.removeSelectedFace(face.data.id)
            }
        }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        self.selectedIndexPaths = indexPaths
        //self.logger.log(.trace, "selected: \(indexPaths.first?.item)")
        highlightItems(selected: true, atIndexPaths: indexPaths)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths)
    }
    
}
