//
//  ViewController+Search.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func search(_ keyword:String) {
        guard !runningSearch else {
            return
        }
        runningSearch = true
        if keyword != "" {
            let condition = SearchCondition.get(from: keyword)
            
            TaskManager.loadingImagesCollection = true
            
            self.imagesLoader.clean()
            collectionView.reloadData()
            
            self.imagesLoader.showHidden = self.chbShowHidden.state == .on
            
            DispatchQueue.global().async {
                self.collectionLoadingIndicator = Accumulator(target: 100, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
                    TaskManager.loadingImagesCollection = false
                    //                let total:Int = data["total"] ?? 0
                    //                let hidden:Int = data["hidden"] ?? 0
                    //                let message:String = "\(total) images, \(hidden) hidden"
                    //                self.indicatorMessage.stringValue = message
                })
                if self.imagesLoader.isLoading() {
                    DispatchQueue.main.async {
                        self.indicatorMessage.stringValue = "Cancelling last request ..."
                    }
                    self.imagesLoader.cancel(onCancelled: {
                        self.imagesLoader.search(conditions: condition, indicator: self.collectionLoadingIndicator, pageSize: 200, pageNumber: 1)
                        self.refreshCollectionView()
                        TaskManager.loadingImagesCollection = false
                    })
                }else{
                    self.imagesLoader.search(conditions: condition, indicator: self.collectionLoadingIndicator, pageSize: 200, pageNumber: 1)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                }
                self.runningSearch = false
                
            }
        }else{
            self.imagesLoader.clean()
            collectionView.reloadData()
            self.imagesLoader.clearSearch(pageSize: 200, pageNumber: 1)
            DispatchQueue.global().async {
                self.imagesLoader.reload()
                self.refreshCollectionView()
                self.runningSearch = false
            }
        }
    }
}
