//
//  ViewController+Main+Menu.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class FaceMenu {
    
    var action = ""
    var area = ""
    
    init(action:String, area: String) {
        self.action = action
        self.area = area
    }
}

extension ViewController {
    
    internal func addSubMenu(_ menu:NSMenu, title: String, action: Selector, representedObject:Any) {
        let submenu = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
        submenu.representedObject = representedObject
    }
    
    internal func setupFacesMenu() {
        self.btnFaces.menu?.item(at: 0)?.title = Words.mainmenu_face.word()
        
        self.btnFaces.menu?.addItem(NSMenuItem.separator())
        self.btnFaces.menu?.addItem(withTitle: Words.mainmenu_face_manageFaces.word(), action: #selector(faceMenuManageAction(_:)), keyEquivalent: "")
        self.btnFaces.menu?.addItem(NSMenuItem.separator())
        
        let menuScan = NSMenuItem(title: Words.mainmenu_face_scan.word(), action: nil, keyEquivalent: "")
        let subMenuScan = NSMenu()
        let menuForceScan = NSMenuItem(title: Words.mainmenu_face_reScan.word(), action: nil, keyEquivalent: "")
        let subMenuForceScan = NSMenu()
        
        let menuRecognize = NSMenuItem(title: Words.mainmenu_face_recognize.word(), action: nil, keyEquivalent: "")
        let subMenuRecognize = NSMenu()
        let menuForceRecognize = NSMenuItem(title: Words.mainmenu_face_reRecognize.word(), action: nil, keyEquivalent: "")
        let subMenuForceRecognize = NSMenu()
        
        let years = ImageSearchDao.default.getYears()
        self.addSubMenu(subMenuScan,
                        title: Words.mainmenu_face_in_collection.word(),
                        action: #selector(faceMenuScanAction(_:)),
                        representedObject: FaceMenu(action: "scan", area: "collection"))
        self.addSubMenu(subMenuRecognize,
                        title: Words.mainmenu_face_in_collection.word(),
                        action: #selector(faceMenuRecognizeAction(_:)),
                        representedObject: FaceMenu(action: "recognize", area: "collection"))
        
        self.addSubMenu(subMenuForceScan,
                        title: Words.mainmenu_face_in_collection.word(),
                        action: #selector(faceMenuForceScanAction(_:)),
                        representedObject: FaceMenu(action: "scan", area: "collection"))
        self.addSubMenu(subMenuForceRecognize,
                        title: Words.mainmenu_face_in_collection.word(),
                        action: #selector(faceMenuForceRecognizeAction(_:)),
                        representedObject: FaceMenu(action: "recognize", area: "collection"))
        
        self.addSubMenu(subMenuScan,
                        title: Words.mainmenu_face_in_allYears.word(),
                        action: #selector(faceMenuScanAction(_:)),
                        representedObject: FaceMenu(action: "scan", area: Words.imagesInAllYears.word()))
        self.addSubMenu(subMenuRecognize,
                        title: Words.mainmenu_face_in_allYears.word(),
                        action: #selector(faceMenuRecognizeAction(_:)),
                        representedObject: FaceMenu(action: "recognize", area: Words.imagesInAllYears.word()))
        
        self.addSubMenu(subMenuForceScan,
                        title: Words.mainmenu_face_in_allYears.word(),
                        action: #selector(faceMenuForceScanAction(_:)),
                        representedObject: FaceMenu(action: "scan", area: Words.imagesInAllYears.word()))
        self.addSubMenu(subMenuForceRecognize,
                        title: Words.mainmenu_face_in_allYears.word(),
                        action: #selector(faceMenuForceRecognizeAction(_:)),
                        representedObject: FaceMenu(action: "recognize", area: Words.imagesInAllYears.word()))
        
        for year in years {
            if year == 0 {
                continue
            }
            
            self.addSubMenu(subMenuScan,
                            title: "\(Words.mainmenu_face_in_year.word("%s", year))",
                            action: #selector(faceMenuScanAction(_:)),
                            representedObject: FaceMenu(action: "scan", area: "\(year)"))
            self.addSubMenu(subMenuRecognize,
                            title: "\(Words.mainmenu_face_in_year.word("%s", year))",
                            action: #selector(faceMenuRecognizeAction(_:)),
                            representedObject: FaceMenu(action: "recognize", area: "\(year)"))
            self.addSubMenu(subMenuForceScan,
                            title: "\(Words.mainmenu_face_in_year.word("%s", year))",
                            action: #selector(faceMenuForceScanAction(_:)),
                            representedObject: FaceMenu(action: "scan", area: "\(year)"))
            self.addSubMenu(subMenuForceRecognize,
                            title: "\(Words.mainmenu_face_in_year.word("%s", year))",
                            action: #selector(faceMenuForceRecognizeAction(_:)),
                            representedObject: FaceMenu(action: "recognize", area: "\(year)"))
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
//        print("manage action \(menuItem.title)")
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
        window.title = Words.faceManager.word()
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
        if let obj = menuItem.representedObject as? FaceMenu {
            self.doFaceMenuAction("\(Words.scan.word()) \(obj.area)")
        }
    }
    
    
    @objc func faceMenuRecognizeAction(_ menuItem:NSMenuItem) {
        if let obj = menuItem.representedObject as? FaceMenu {
            self.doFaceMenuAction("\(Words.recognize.word()) \(obj.area)")
        }
    }
    
    @objc func faceMenuForceScanAction(_ menuItem:NSMenuItem) {
        if let obj = menuItem.representedObject as? FaceMenu {
            self.doFaceMenuAction("\(Words.forceScan.word()) \(obj.area)")
        }
    }
    
    
    @objc func faceMenuForceRecognizeAction(_ menuItem:NSMenuItem) {
        if let obj = menuItem.representedObject as? FaceMenu {
            self.doFaceMenuAction("\(Words.forceRecognize.word()) \(obj.area)")
        }
    }
    
    @objc func faceMenuForceRecognizeUnknownAction(_ menuItem:NSMenuItem) {
        if let obj = menuItem.representedObject as? FaceMenu {
            self.doFaceMenuAction("Recognize-Unknown \(obj.area)")
        }
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
        window.title = Words.faceManager.word()
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
        if !runningFaceTask && title != "" && title != Words.mainmenu_face.word() {
            let parts = title.components(separatedBy: " ")
            let action = parts[0]
            var area = parts[parts.count-1]
//            print("\(action) \(area)")
            if area == "collection" {
                if self.imagesLoader.getItems().count > 0 {
                    let tasklet = TaskletManager.default.task(type: "face", name: "\(action)\(Words.facesInCollection.word())")
                    tasklet.total = self.imagesLoader.getItems().count
                    tasklet.progress = 0
                    tasklet.running = true
                    tasklet.changeListener(selector: #selector(taskletObserver(notification:)))
                    self.runningFaceTask = true
                    self.stopFacesTask = false
//                    self.btnStop.isHidden = false
//                    self.lblProgressMessage.stringValue = "\(action) faces in collection: loading images ..."
//
                    DispatchQueue.global().async {
                        for imageFile in self.imagesLoader.getItems() {
                            if self.stopFacesTask {
                                tasklet.forceStop = true
                                tasklet.running = false
                                tasklet.forceStopped = true
//                                DispatchQueue.main.async {
//                                    self.btnStop.isHidden = true
//                                }
                                self.runningFaceTask = false
                                self.stopFacesTask = false
                                tasklet.removeListener()
                                break
                            }
                            let url = imageFile.url
                            if action == Words.scan.word() {
                                let _ = FaceTask.default.findFaces(path: url.path)
                            }else if action == Words.recognize.word() {
                                let _ = FaceTask.default.recognizeFaces(path: url.path)
                            }
                            tasklet.progress += 1
                            tasklet.notifyChange()
                        }
                    }
                }else{
//                    print("no item in collection")
                }
            }else{
                let tasklet = TaskletManager.default.task(type: "face", name: "\(action)\(Words.facesInArea.word("%s", area))")
                tasklet.total = 1
                tasklet.progress = 0
                tasklet.running = true
                tasklet.changeListener(selector: #selector(taskletObserver(notification:)))
                self.runningFaceTask = true
                self.stopFacesTask = false
//                self.btnStop.isHidden = false
//
//                self.lblProgressMessage.stringValue = "\(action) faces in \(area): loading images ..."
                
                if area == Words.imagesInAllYears.word() {
                    area = ""
                }
                DispatchQueue.global().async {
                    
                    var images:[Image] = []
                    if action == Words.scan.word() {
                        images = ImageSearchDao.default.getImagesByYear(year: area, scannedFace: false)
                    }else if action == Words.recognize.word() {
                        images = ImageSearchDao.default.getImagesByYear(year: area, recognizedFace: false)
                    }else if action == Words.forceScan.word() || action == Words.forceRecognize.word() {
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
//                                DispatchQueue.main.async {
//                                    self.btnStop.isHidden = true
//                                }
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
//                                        print("waiting for releasing memory for face detection, attempt: \(attempt)")
                                        continousWorking = false
                                        sleep(10)
                                    }else{
//                                        print("continue for face detection, last attempt: \(attempt)")
                                        continousWorking = true
                                    }
                                }
                            }
                            
                            if continousWorking {
                                autoreleasepool { () -> Void in
                                    let image = images[index]
                                    if action == Words.scan.word() || action == Words.forceScan.word() {
                                        let _ = FaceTask.default.findFaces(image: image)
                                    }else if action == Words.recognize.word() || action == Words.forceRecognize.word() {
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
//                        self.btnStop.isHidden = true
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
