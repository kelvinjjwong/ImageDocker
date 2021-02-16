//
//  LibraryTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    fileprivate func countImagesOfContainer(container:ImageContainer) -> Int{
        return ImageCountDao.default.countImages(repositoryRoot: container.path.withStash())
    }
    
    fileprivate func countHiddenImagesOfContainer(container:ImageContainer) -> Int {
        return ImageCountDao.default.countHiddenImages(repositoryRoot: container.path.withStash())
    }
    
    func reloadCollectionFromImageContainer(sender:NSButton) {
        
        if let container = self.selectedImageContainer {
            self.createCollectionPaginationPopover()
            self.collectionPaginationViewController
                .initView(self.imagesLoader.lastRequest,
                          onCountTotal: {
                            return self.countImagesOfContainer(container: container)
                },
                          onCountHidden: {
                            return self.countHiddenImagesOfContainer(container: container)
                },
                          onLoad: { pageSize, pageNumber in
                            print("CALLED ONLOAD \(pageSize) \(pageNumber)")
                            
                            self.loadCollectionByContainer(container: container, pageSize: pageSize, pageNumber: pageNumber, subdirectories: true)
                },
                          onPaginationStateChanges: {currentPage, totalPages in
                          self.changePaginationState(currentPage: currentPage, totalPages: totalPages)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }else{
            print("no folder selected \(self.selectedImageFolder == nil)")
        }
    }
    
    internal func loadCollectionByContainer(container:ImageContainer, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        
        var totalRecords = self.countImagesOfContainer(container: container)
        if self.chbShowHidden.state == .off {
            totalRecords -= self.countHiddenImagesOfContainer(container: container)
        }
        self.changePaginationState(currentPage: pageNumber, pageSize: pageSize, totalRecords: totalRecords)
        
        self.loadCollectionByContainer(name: container.name, url:URL(fileURLWithPath: container.path), pageSize: pageSize, pageNumber: pageNumber, subdirectories: true)
    }
    
    internal func loadCollectionByContainer(name:String, url:URL, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        
        loadCollection {
            self.imagesLoader.load(
                from: url,
                indicator:self.collectionLoadingIndicator,
                pageSize: pageSize,
                pageNumber: pageNumber,
                subdirectories: subdirectories)
        }
    }
}
