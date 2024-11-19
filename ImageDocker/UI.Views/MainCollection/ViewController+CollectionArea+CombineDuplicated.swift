//
//  ViewController+CollectionArea+CombineDuplicated.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func selectCombineMenuInCollectionArea(_ i:Int) {
        if i == 1 {
            self.combineDuplicatesInCollectionView()
        }else if i == 2 {
            self.combineDuplicatesInAllLibraries()
        }
    }
    
    internal func combineDuplicatesInCollectionView() {
        guard self.imagesLoader.getItems().count > 0 else {
            Alert.noImageSelected()
            return
        }
        
        self.disableCollectionViewControls()
        
        let accumulator:Accumulator = Accumulator(target: self.imagesLoader.getItems().count, indicator: self.collectionProgressIndicator, suspended: false, lblMessage: nil)
        
        DispatchQueue.global().async {
            
            for image in self.imagesLoader.getItems() {
                if image.hasDuplicates {
                    if let list = ImageDuplicationDao.default.getDuplicatePhotos().keyToPath[image.duplicatesKey] {
                        if image.url.path == list[0] {
                            //self.logger.log(.trace, "\(image.duplicatesKey) MAJOR \(image.url.path)")
                            ImageDuplicationDao.default.markImageDuplicated(path: image.url.path, duplicatesKey: image.duplicatesKey, hide: false)
                        }else{
                            //self.logger.log(.trace, "\(image.duplicatesKey) SLAVE \(image.url.path)")
                            ImageDuplicationDao.default.markImageDuplicated(path: image.url.path, duplicatesKey: image.duplicatesKey, hide: true)
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    let _ = accumulator.add()
                }
            }
            
            self.imagesLoader.reload()
            self.imagesLoader.reorganizeItems()
            
            DispatchQueue.main.async {
                self.enableCollectionViewControls()
                self.collectionView.reloadData()
            }
        }
    }
    
    internal func combineDuplicatesInAllLibraries() {
        self.disableCollectionViewControls()
        
        let accumulator:Accumulator = Accumulator(target: ImageDuplicationDao.default.getDuplicatePhotos().keyToPath.keys.count, indicator: self.collectionProgressIndicator, suspended: false, lblMessage: self.indicatorMessage)
        
        DispatchQueue.global().async {
            
            for key in ImageDuplicationDao.default.getDuplicatePhotos().keyToPath.keys {
                if let list = ImageDuplicationDao.default.getDuplicatePhotos().keyToPath[key] {
                    
                    for i in 0..<list.count {
                        let path = list[i]
                        if i == 0 {
                            ImageDuplicationDao.default.markImageDuplicated(path: path, duplicatesKey: key, hide: false)
                        }else{
                            ImageDuplicationDao.default.markImageDuplicated(path: path, duplicatesKey: key, hide: true)
                        }
                    }
                }
                DispatchQueue.main.async {
                    let _ = accumulator.add("Combining duplicated images ...")
                }
            }
            
            if self.imagesLoader.getItems().count > 0 {
                self.imagesLoader.reload()
                self.imagesLoader.reorganizeItems()
                
                DispatchQueue.main.async {
                    self.enableCollectionViewControls()
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
