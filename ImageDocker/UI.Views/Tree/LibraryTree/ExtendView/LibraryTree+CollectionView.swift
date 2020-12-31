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
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: { data in
                    TaskManager.loadingImagesCollection = false
                }
            )
            if self.imagesLoader.isLoading() {
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(from: url, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                print("LOADING from library entry name:\(name) -> url:\(url.path) | page: \(pageNumber), pageSize: \(pageSize) | sub: \(subdirectories)")
                self.imagesLoader.load(from: url, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
        }
    }
}
