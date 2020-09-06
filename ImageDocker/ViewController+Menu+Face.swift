//
//  ViewController+Main+Menu.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func setupFacesMenu() {
        self.btnStop.isHidden = true
        
        self.btnFaces.menu?.addItem(NSMenuItem.separator())
        self.btnFaces.menu?.addItem(withTitle: "Manage faces", action: #selector(faceMenuManageAction(_:)), keyEquivalent: "")
        self.btnFaces.menu?.addItem(NSMenuItem.separator())
        
        let menuScan = NSMenuItem(title: "Scan faces in pictures", action: nil, keyEquivalent: "")
        let subMenuScan = NSMenu()
        let menuForceScan = NSMenuItem(title: "Force Re-Scan all pictures", action: nil, keyEquivalent: "")
        let subMenuForceScan = NSMenu()
        
        let menuRecognize = NSMenuItem(title: "Recognize faces in pictures", action: nil, keyEquivalent: "")
        let subMenuRecognize = NSMenu()
        let menuForceRecognize = NSMenuItem(title: "Force Re-Recognize all pictures", action: nil, keyEquivalent: "")
        let subMenuForceRecognize = NSMenu()
        
        let years = ImageSearchDao.default.getYears()
        subMenuScan.addItem(withTitle: "Pictures in collection", action: #selector(faceMenuScanAction(_:)), keyEquivalent: "")
        subMenuRecognize.addItem(withTitle: "Pictures in collection", action: #selector(faceMenuRecognizeAction(_:)), keyEquivalent: "")
        subMenuForceScan.addItem(withTitle: "Pictures in collection", action: #selector(faceMenuForceScanAction(_:)), keyEquivalent: "")
        subMenuForceRecognize.addItem(withTitle: "Pictures in collection", action: #selector(faceMenuForceRecognizeAction(_:)), keyEquivalent: "")
        
        subMenuScan.addItem(withTitle: "Pictures in all-years", action: #selector(faceMenuScanAction(_:)), keyEquivalent: "")
        subMenuRecognize.addItem(withTitle: "Pictures in all-years", action: #selector(faceMenuRecognizeAction(_:)), keyEquivalent: "")
        subMenuForceScan.addItem(withTitle: "Pictures in all-years", action: #selector(faceMenuForceScanAction(_:)), keyEquivalent: "")
        subMenuForceRecognize.addItem(withTitle: "Pictures in all-years", action: #selector(faceMenuForceRecognizeAction(_:)), keyEquivalent: "")
        for year in years {
            if year == 0 {
                continue
            }
            
            subMenuScan.addItem(withTitle: "Pictures in \(year)", action: #selector(faceMenuScanAction(_:)), keyEquivalent: "")
            subMenuRecognize.addItem(withTitle: "Pictures in \(year)", action: #selector(faceMenuRecognizeAction(_:)), keyEquivalent: "")
            subMenuForceScan.addItem(withTitle: "Pictures in \(year)", action: #selector(faceMenuForceScanAction(_:)), keyEquivalent: "")
            subMenuForceRecognize.addItem(withTitle: "Pictures in \(year)", action: #selector(faceMenuForceRecognizeAction(_:)), keyEquivalent: "")
        }
        menuScan.submenu = subMenuScan
        menuRecognize.submenu = subMenuRecognize
        menuForceScan.submenu = subMenuForceScan
        menuForceRecognize.submenu = subMenuForceRecognize
        
        self.btnFaces.menu?.addItem(menuScan)
        self.btnFaces.menu?.addItem(menuForceScan)
        self.btnFaces.menu?.addItem(NSMenuItem.separator())
        self.btnFaces.menu?.addItem(menuRecognize)
        self.btnFaces.menu?.addItem(menuForceRecognize)
    }
    
    @objc func faceMenuManageAction(_ menuItem:NSMenuItem) {
        print("manage action \(menuItem.title)")
        self.btnFaces.selectItem(at: 0)
        
        let storyboard = NSStoryboard(name: "PeopleFaceViewItems", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "PeopleViewController") as! PeopleViewController
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 1220
        let windowHeight = 820
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "Export Manager"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView()
        
//        if let window = self.peopleWindowController.window {
//            if self.peopleWindowController.isWindowLoaded {
//                window.makeKeyAndOrderFront(self)
//                print("order to front")
//            }else{
//                self.peopleWindowController.showWindow(self)
//                print("show window")
//            }
//            let vc = window.contentViewController as! PeopleViewController
//            vc.initView()
//            //            vc.initNew(window: window, onOK: {
//            //                window.close()
//            //            })
//        }
    }
    
    @objc func faceMenuScanAction(_ menuItem:NSMenuItem) {
        self.doFaceMenuAction("Scan \(menuItem.title)")
    }
    
    
    @objc func faceMenuRecognizeAction(_ menuItem:NSMenuItem) {
        self.doFaceMenuAction("Recognize \(menuItem.title)")
    }
    
    @objc func faceMenuForceScanAction(_ menuItem:NSMenuItem) {
        self.doFaceMenuAction("Force-Scan \(menuItem.title)")
    }
    
    
    @objc func faceMenuForceRecognizeAction(_ menuItem:NSMenuItem) {
        self.doFaceMenuAction("Force-Recognize \(menuItem.title)")
    }
    
    @objc func faceMenuForceRecognizeUnknownAction(_ menuItem:NSMenuItem) {
        self.doFaceMenuAction("Recognize-Unknown \(menuItem.title)")
    }
    
    internal func openFaceManager() {
        let storyboard = NSStoryboard(name: "PeopleFaceViewItems", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "PeopleViewController") as! PeopleViewController
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 1220
        let windowHeight = 820
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "Export Manager"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView()
        
//        if let window = self.peopleWindowController.window {
//            if self.peopleWindowController.isWindowLoaded {
//                window.makeKeyAndOrderFront(self)
//                print("order to front")
//            }else{
//                self.peopleWindowController.showWindow(self)
//                print("show window")
//            }
//            let vc = window.contentViewController as! PeopleViewController
//            vc.initView()
//            //            vc.initNew(window: window, onOK: {
//            //                window.close()
//            //            })
//        }
    }
    
    internal func doFaceMenuAction(_ title:String) {
        if !runningFaceTask && title != "" && title != "Faces" {
            let parts = title.components(separatedBy: " ")
            let action = parts[0]
            var area = parts[parts.count-1]
            print("\(action) \(area)")
            if area == "collection" {
                if self.imagesLoader.getItems().count > 0 {
                    let tasklet = TaskletManager.default.task(type: "face", name: "\(action) faces in collection")
                    tasklet.total = self.imagesLoader.getItems().count
                    tasklet.progress = 0
                    tasklet.running = true
                    tasklet.changeListener(selector: #selector(taskletObserver(notification:)))
                    self.runningFaceTask = true
                    self.stopFacesTask = false
                    self.btnStop.isHidden = false
                    self.lblProgressMessage.stringValue = "\(action) faces in collection: loading images ..."
                    
                    DispatchQueue.global().async {
                        for imageFile in self.imagesLoader.getItems() {
                            if self.stopFacesTask {
                                tasklet.forceStop = true
                                tasklet.running = false
                                tasklet.forceStopped = true
                                DispatchQueue.main.async {
                                    self.btnStop.isHidden = true
                                }
                                self.runningFaceTask = false
                                self.stopFacesTask = false
                                tasklet.removeListener()
                                break
                            }
                            let url = imageFile.url
                            if action == "Scan" {
                                let _ = FaceTask.default.findFaces(path: url.path)
                            }else if action == "Recognize" {
                                let _ = FaceTask.default.recognizeFaces(path: url.path)
                            }
                            tasklet.progress += 1
                            tasklet.notifyChange()
                        }
                    }
                }else{
                    print("no item in collection")
                }
            }else{
                let tasklet = TaskletManager.default.task(type: "face", name: "\(action) faces in \(area)")
                tasklet.total = 1
                tasklet.progress = 0
                tasklet.running = true
                tasklet.changeListener(selector: #selector(taskletObserver(notification:)))
                self.runningFaceTask = true
                self.stopFacesTask = false
                self.btnStop.isHidden = false
                
                self.lblProgressMessage.stringValue = "\(action) faces in \(area): loading images ..."
                
                if area == "all-years" {
                    area = ""
                }
                DispatchQueue.global().async {
                    
                    var images:[Image] = []
                    if action == "Scan" {
                        images = ImageSearchDao.default.getImagesByYear(year: area, scannedFace: false)
                    }else if action == "Recognize" {
                        images = ImageSearchDao.default.getImagesByYear(year: area, recognizedFace: false)
                    }else if action == "Force-Scan" || action == "Force-Recognize" {
                        images = ImageSearchDao.default.getImagesByYear(year: area)
                    }
                    if images.count > 0 {
                        tasklet.total = images.count
                        
                        let limitRam = PreferencesController.peakMemory() * 1024
                        var continousWorking = true
                        var index = 0
                        var attempt = 0
                        
                        while(index < images.count ){
                            //for image in images {
                            if self.stopFacesTask {
                                tasklet.forceStop = true
                                tasklet.running = false
                                tasklet.forceStopped = true
                                DispatchQueue.main.async {
                                    self.btnStop.isHidden = true
                                }
                                self.runningFaceTask = false
                                self.stopFacesTask = false
                                tasklet.removeListener()
                                break
                            }
                            
                            if limitRam > 0 {
                                var taskInfo = mach_task_basic_info()
                                var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
                                let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
                                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                                        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                                    }
                                }
                                
                                if kerr == KERN_SUCCESS {
                                    let usedRam = taskInfo.resident_size / 1024 / 1024
                                    
                                    if usedRam >= limitRam {
                                        attempt += 1
                                        print("waiting for releasing memory for face detection, attempt: \(attempt)")
                                        continousWorking = false
                                        sleep(10)
                                    }else{
                                        print("continue for face detection, last attempt: \(attempt)")
                                        continousWorking = true
                                    }
                                }
                            }
                            
                            if continousWorking {
                                autoreleasepool { () -> Void in
                                    let image = images[index]
                                    if action == "Scan" || action == "Force-Scan" {
                                        let _ = FaceTask.default.findFaces(image: image)
                                    }else if action == "Recognize" || action == "Force-Recognize" {
                                        let _ = FaceTask.default.recognizeFaces(image: image)
                                    }
                                    tasklet.progress += 1
                                    tasklet.notifyChange()
                                    
                                    index += 1
                                }
                            }
                        }
                    }else{
                        tasklet.forceStop = false
                        tasklet.forceStopped = false
                        tasklet.running = false
                        self.btnStop.isHidden = true
                        self.runningFaceTask = false
                        self.stopFacesTask = false
                        tasklet.removeListener()
                    }
                }
            }
        }else{
            print("no selection")
        }
    }
}
