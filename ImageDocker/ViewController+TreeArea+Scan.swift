//
//  ViewController+TreeArea+Scan.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func startScanRepositories(){
        DispatchQueue.global().async {
            ExportManager.default.disable()
            self.creatingRepository = true
            DispatchQueue.main.async {
                self.btnScanState.image = NSImage(named: NSImage.Name.statusAvailable)
            }
            self.treeLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true,
                                                    lblMessage: self.indicatorMessage,
                                                    presetAddingMessage: "Importing images ...",
                                                    onCompleted: {data in
                                                        print("COMPLETE SCAN REPO")
                                                        ExportManager.default.enable()
                                                        self.creatingRepository = false
                                                        DispatchQueue.main.async {
                                                            self.btnScanState.image = NSImage(named: NSImage.Name.statusPartiallyAvailable)
                                                        }
            },
                                                    onDataChanged: {
                                                        self.updateLibraryTree()
            }
            )
            autoreleasepool(invoking: { () -> Void in
                ImageFolderTreeScanner.default.scanRepositories(indicator: self.treeLoadingIndicator, onCompleted: {
                    //                    self.chbScan.state = .off
                    //                    self.onScanDisabled()
                })
            })
            
        }
    }
    
    internal func onScanEnabled() {
        print("enabled scan")
        self.suppressedScan = false
        ImageFolderTreeScanner.default.suppressedScan = false
        
        self.btnScanState.isHidden = false
        self.btnScanState.image = NSImage(named: NSImage.Name.statusPartiallyAvailable)
        
        // start scaning immediatetly
        self.startScanRepositories()
    }
    
    internal func onScanDisabled() {
        print("disabled scan")
        self.suppressedScan = true
        ImageFolderTreeScanner.default.suppressedScan = true
        
        self.btnScanState.image = NSImage(named: NSImage.Name.statusNone)
        self.btnScanState.isHidden = true
    }
    
    internal func startScanRepositoriesToLoadExif(){
        if !ExportManager.default.working && !self.scaningRepositories && !self.creatingRepository {
            DispatchQueue.global().async {
                
                ExportManager.default.suppressed = true
                self.scaningRepositories = true
                
                print("EXTRACTING EXIF")
                DispatchQueue.main.async {
                    self.btnScanState.image = NSImage(named: NSImage.Name.statusAvailable)
                }
                self.treeLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true,
                                                        lblMessage: self.indicatorMessage,
                                                        presetAddingMessage: "Extracting EXIF ...",
                                                        onCompleted: { data in
                                                            print("COMPLETE SCAN PHOTOS TO LOAD EXIF")
                                                            
                                                            ExportManager.default.suppressed = false
                                                            self.scaningRepositories = false
                                                            DispatchQueue.main.async {
                                                                self.btnScanState.image = NSImage(named: NSImage.Name.statusPartiallyAvailable)
                                                                self.indicatorMessage.stringValue = ""
                                                            }
                }
                )
                ImageFolderTreeScanner.default.scanPhotosToLoadExif(indicator: self.treeLoadingIndicator)
            }
        }
    }
}
