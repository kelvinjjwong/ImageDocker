//
//  LibraryTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func loadCollectionByContainer(_ imageFolder:ImageFolder, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        self.selectedImageFolder = imageFolder
        if imageFolder.url.path == "/" {
            print("ERROR: imageFolder.url.path is null")
            return
        }
        self.loadCollectionByContainer(name: imageFolder.name, url: imageFolder.url,
                                       pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
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
