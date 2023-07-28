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
//        self.logger.log("countImagesOfContainer(container:\(container.id)")
        return ImageCountDao.default.countImages(repositoryRoot: container.path.withLastStash())
    }
    
    fileprivate func countHiddenImagesOfContainer(container:ImageContainer) -> Int {
//        self.logger.log("countHiddenImagesOfContainer(container:\(container.id)")
        return ImageCountDao.default.countHiddenImages(repositoryRoot: container.path.withLastStash())
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
                    self.logger.log("CALLED ONLOAD \(pageSize) \(pageNumber)")
                            
                            self.loadCollectionByContainer(container: container, pageSize: pageSize, pageNumber: pageNumber, subdirectories: true)
                },
                          onPaginationStateChanges: {currentPage, totalPages in
                          self.changePaginationState(currentPage: currentPage, totalPages: totalPages)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }else{
            logger.log("no folder selected \(self.selectedImageFolder == nil)")
        }
    }
    
    internal func loadCollectionByContainer(container:ImageContainer, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        self.logger.log("loadCollectionByContainer(container:\(container.id), repositoryId:\(repositoryId ?? -999999), repositoryVolume:\(repositoryVolume ?? "nil"), rawVolume:\(rawVolume ?? "nil"), pageSize:\(pageSize), pageNumber:\(pageNumber), subdirectories:\(subdirectories)")
        var totalRecords = self.countImagesOfContainer(container: container)
//        if self.chbShowHidden.state == .off {
//            totalRecords -= self.countHiddenImagesOfContainer(container: container)
//        }
        self.changePaginationState(currentPage: pageNumber, pageSize: pageSize, totalRecords: totalRecords)
        
        self.loadCollectionByContainer(name: container.name,
                                       containerId: container.id,
                                       //url:URL(fileURLWithPath: container.path),
                                       repositoryId: repositoryId,
                                       repositoryVolume: repositoryVolume,
                                       rawVolume: rawVolume,
                                       pageSize: pageSize, pageNumber: pageNumber)
    }
    
    internal func loadCollectionByContainer(name:String, containerId:Int, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        self.logger.log("loadCollectionByContainer(name:\(name), containerId:\(containerId), repositoryId:\(repositoryId ?? -999999), repositoryVolume:\(repositoryVolume ?? "nil"), rawVolume:\(rawVolume ?? "nil"), pageSize:\(pageSize), pageNumber:\(pageNumber), subdirectories:\(subdirectories)")
        loadCollection {
            self.imagesLoader.load(containerId:containerId,
                repositoryId: repositoryId,
                repositoryVolume: repositoryVolume,
                rawVolume: rawVolume,
                indicator:self.collectionLoadingIndicator,
                pageSize: pageSize,
                pageNumber: pageNumber)
        }
    }
    
//    internal func loadCollectionByContainer(name:String, url:URL, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
//        self.logger.log("loadCollectionByContainer(name:\(name), url:\(url), repositoryId:\(repositoryId ?? -999999), repositoryVolume:\(repositoryVolume ?? "nil"), rawVolume:\(rawVolume ?? "nil"), pageSize:\(pageSize), pageNumber:\(pageNumber), subdirectories:\(subdirectories)")
//        loadCollection {
//            self.imagesLoader.load(from: url,
//                repositoryId: repositoryId,
//                repositoryVolume: repositoryVolume,
//                rawVolume: rawVolume,
//                indicator:self.collectionLoadingIndicator,
//                pageSize: pageSize,
//                pageNumber: pageNumber,
//                subdirectories: subdirectories)
//        }
//    }
}
