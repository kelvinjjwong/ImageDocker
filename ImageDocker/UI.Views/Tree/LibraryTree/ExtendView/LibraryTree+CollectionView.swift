//
//  LibraryTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func loadCollectionByContainer(name:String, containerId:Int, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        self.logger.log("loadCollectionByContainer(name:\(name), containerId:\(containerId), repositoryId:\(repositoryId ?? -999999), repositoryVolume:\(repositoryVolume ?? "nil"), rawVolume:\(rawVolume ?? "nil"), pageSize:\(pageSize), pageNumber:\(pageNumber), subdirectories:\(subdirectories)")
        
        self.collectionPaginationController?.initPageSize(pageSize: pageSize)
        self.collectionPaginationController?.initPageNumber(pageNumber: pageNumber)
        self.collectionPaginationController?.initCounter(onCountTotal: {
            return RepositoryDao.default.countSubImages(containerId: containerId)
        }, onCountHidden: {
            return RepositoryDao.default.countSubHiddenImages(containerId: containerId)
        })
        self.collectionPaginationController?.initLoader(onLoad: { pageSize, pageNumber in
            self.loadCollection {
                self.imagesLoader.load(containerId:containerId,
                    repositoryId: repositoryId,
                    repositoryVolume: repositoryVolume,
                    rawVolume: rawVolume,
                    indicator:self.collectionLoadingIndicator,
                    pageSize: pageSize,
                    pageNumber: pageNumber)
            }
        })
        self.collectionPaginationController?.load()
        
        
    }
    
}
