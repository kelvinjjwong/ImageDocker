//
//  ViewController+Main+PreviewArea.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//


import Cocoa
import AVFoundation
import AVKit

extension ViewController {
    
    @objc func onMetaTableDoubleClicked() {
        let row = self.metaInfoTableView.clickedRow
        if row >= 0 && row < self.img.metaInfoHolder.getInfos().count {
            self.logger.log(.trace, "meta double clicked row \(row)")
            let info = self.img.metaInfoHolder.getInfos()[row]
            if let value = info.value {
                self.logger.log(.trace, "clicked info \(value)")
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(value, forType: .string)
                
                MessageEventCenter.default.showMessage(type: "IMAGE", name: "META_COPIER", message: Words.copied_meta_value_to_pasteboard.word())
            }
            
        }
    }

    internal func configurePreview(){
        self.splitviewPreview.dividerStyle = .thin
        
        // MARK: Stacked Player Preview
            
        self.imagePreviewController = (storyboard?.instantiateController(withIdentifier: "ImagePreviewController") as! ImagePreviewController)
        self.splitviewPreview.addArrangedSubview(imagePreviewController.view)
        
        self.imagePreviewController.getImageFromPreview = {
            return self.getImageFromPreview()
        }
        
        self.imagePreviewController.previewImage = { imageFile in
            self.previewImage(image: imageFile)
        }
        
        self.imagePreviewController.zoomOutImage = { imageFile in
            self.onCollectionViewItemQuickLook(imageFile)
        }
        
        self.playerContainer = imagePreviewController.playerContainer
        self.lblImageDescription = imagePreviewController.lblDescription
        
        // Do any additional setup after loading the view.
        stackedImageViewController = (storyboard?.instantiateController(withIdentifier: "imageView") as! StackedImageViewController)
        stackedVideoViewController = (storyboard?.instantiateController(withIdentifier: "videoView") as! StackedVideoViewController)
        
        stackedImageViewController.parentController = self
        stackedVideoViewController.parentController = self
        stackedImageViewController.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        stackedVideoViewController.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        stackedVideoViewController.view.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        stackedImageViewController.view.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        
        self.addChild(stackedImageViewController)
        self.addChild(stackedVideoViewController)
        
        stackedImageViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(stackedImageViewController.view)
        self.playerContainer.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        self.playerContainer.layer?.borderColor = Colors.DeepDarkGray.cgColor
        self.playerContainer.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        
        // MARK: Image Edit Tab View
        
        self.imageEditTabViewController = (storyboard?.instantiateController(withIdentifier: "ImageEditTabViewController") as! ImageEditTabViewController)
        self.splitviewPreview.addArrangedSubview(imageEditTabViewController.view)
        
        imageEditTabViewController.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        imageEditTabViewController.view.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        
        self.splitviewPreview.subviews[1].setHeight(self.splitviewPreview.visibleRect.height - self.playerContainer.bounds.height)
        imageEditTabViewController.view.setHeight(self.splitviewPreview.visibleRect.height - self.playerContainer.bounds.height)
        
        
        // MARK: Meta View
        
        self.imageMetaViewController = (storyboard?.instantiateController(withIdentifier: "ImageMetaViewController") as! ImageMetaViewController)
        
        let metaTab = NSTabViewItem(identifier: "tabMeta")
        metaTab.label = Words.imageEdit_tabs_Meta.word()
        self.imageEditTabViewController.tabs.addTabViewItem(metaTab)
        metaTab.view = self.imageMetaViewController.view
        self.imageMetaViewController.view.setHeight(self.splitviewPreview.subviews[1].bounds.height - 40)
        metaTab.view?.setHeight(self.splitviewPreview.subviews[1].bounds.height - 40)
        
        imageMetaViewController.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        imageMetaViewController.view.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        
        self.scrollviewMetaInfoTable = imageMetaViewController.scrollView
        self.metaInfoTableView = imageMetaViewController.tableView
        self.metaInfoTableView.delegate = self
        self.metaInfoTableView.dataSource = self
        
        self.metaInfoTableView.toolTip = Words.double_click_to_copy_value.word()
        self.metaInfoTableView.target = self
        self.metaInfoTableView.doubleAction = #selector(onMetaTableDoubleClicked)
        
        
        // MARK: Location View
        
        self.imageLocationViewController = (storyboard?.instantiateController(withIdentifier: "ImageLocationViewController") as! ImageLocationViewController)
        
        let locationViewMapTab = NSTabViewItem(identifier: "tabViewMap")
        locationViewMapTab.label = Words.imageEdit_tabs_Map.word()
        self.imageEditTabViewController.tabs.addTabViewItem(locationViewMapTab)
        locationViewMapTab.view = self.imageLocationViewController.view
        self.imageLocationViewController.view.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        locationViewMapTab.view?.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        
        imageLocationViewController.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        imageLocationViewController.view.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        
        self.webLocation = self.imageLocationViewController.locationWebView
        self.mapZoomSlider = self.imageLocationViewController.locationSlider
        
        webLocation.setValue(false, forKey: "drawsBackground")
        webLocation.load(URLRequest(url: URL(string: "about:blank")!))
        
        // MARK: Location Edit View
        
        self.imageLocationEditViewController = (storyboard?.instantiateController(withIdentifier: "ImageLocationEditViewController") as! ImageLocationEditViewController)
        self.imageLocationEditViewController.reloadCollectionView = {
            self.imagesLoader.reorganizeItems(considerPlaces: true)
            self.collectionView.reloadData()
        }
        self.imageLocationEditViewController.reloadSelectionView = {
            self.selectionViewController.collectionViewController.imagesLoader.reorganizeItems()
            self.selectionViewController.collectionViewController.collectionView.reloadData()
        }
        self.imageLocationEditViewController.getSelectionItems = {
            return self.selectionViewController.collectionViewController.imagesLoader.getItems()
        }
        self.imageLocationEditViewController.getSelectionItem = { path in
            return self.selectionViewController.collectionViewController.imagesLoader.getItem(path: path)
        }
        self.imageLocationEditViewController.reloadImageMetaTable = { img in
            self.img = img
            self.metaInfoTableView.reloadData()
        }
        self.imageLocationEditViewController.getSampleImage = {
            return self.img
        }
        self.imageLocationEditViewController.getSelectionViewIndicator = {
            return self.selectionViewController.batchEditIndicator
        }
        
        let locationEditTab = NSTabViewItem(identifier: "tabEditMap")
        locationEditTab.label = Words.imageEdit_tabs_EditMap.word()
        self.imageEditTabViewController.tabs.addTabViewItem(locationEditTab)
        locationEditTab.view = self.imageLocationEditViewController.view
        self.imageLocationEditViewController.view.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        locationEditTab.view?.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        
        imageLocationEditViewController.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        imageLocationEditViewController.view.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        
        self.imageLocationEditViewController.locationTextDelegate = LocationTextDelegate()
        self.imageLocationEditViewController.locationTextDelegate?.textField = self.imageLocationEditViewController.lblLocation
        self.imageLocationEditViewController.lblLocation.textColor = NSColor.white
        
        self.webPossibleLocation = self.imageLocationEditViewController.locationWebView
        self.possibleLocationText = self.imageLocationEditViewController.lblLocation
        self.btnChoiceMapService = self.imageLocationEditViewController.apiSwitch
        self.btnCopyLocation = self.imageLocationEditViewController.btnCopyLocation
        self.btnReplaceLocation = self.imageLocationEditViewController.btnReplaceLocation
        self.btnManagePlaces = self.imageLocationEditViewController.btnManagePlaces
        self.addressSearcher = self.imageLocationEditViewController.locationSearcher
        self.comboPlaceList = self.imageLocationEditViewController.lstPlaces
        
        webPossibleLocation.setValue(false, forKey: "drawsBackground")
        webPossibleLocation.load(URLRequest(url: URL(string: "about:blank")!))
        
        // MARK: Note Edit View
        
        self.imageNoteEditViewController = (storyboard?.instantiateController(withIdentifier: "ImageNoteEditViewController") as! ImageNoteEditViewController)
        
        let noteEditTab = NSTabViewItem(identifier: "tabEditNote")
        noteEditTab.label = Words.imageEdit_tabs_Note.word()
        self.imageEditTabViewController.tabs.addTabViewItem(noteEditTab)
        noteEditTab.view = self.imageNoteEditViewController.view
        self.imageNoteEditViewController.view.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        noteEditTab.view?.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        
        // MARK: Event Edit View
        
        self.imageEventEditViewController = (storyboard?.instantiateController(withIdentifier: "ImageEventEditViewController") as! ImageEventEditViewController)
        
        let eventEditTab = NSTabViewItem(identifier: "tabEditEvent")
        eventEditTab.label = Words.imageEdit_tabs_Event.word()
        self.imageEditTabViewController.tabs.addTabViewItem(eventEditTab)
        eventEditTab.view = self.imageEventEditViewController.view
        self.imageEventEditViewController.view.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        eventEditTab.view?.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        
        // MARK: Family Edit View
        
        self.imageFamilyEditViewController = (storyboard?.instantiateController(withIdentifier: "ImageFamilyEditViewController") as! ImageFamilyEditViewController)
        
        let familyEditTab = NSTabViewItem(identifier: "tabEditFamily")
        familyEditTab.label = Words.imageEdit_tabs_People.word()
        self.imageEditTabViewController.tabs.addTabViewItem(familyEditTab)
        familyEditTab.view = self.imageFamilyEditViewController.view
        self.imageFamilyEditViewController.view.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
        familyEditTab.view?.setHeight(self.splitviewPreview.subviews[1].bounds.height - 30)
    }
    
    // DropPlaceDelegate
    // shared among different open-channels
    internal func processImageUrls(urls:[URL]){
        
        if urls.count == 0 {return}
        loadImageMetaAndPreview(urls[0])
    }
    
    internal func getImageFromPreview() -> NSImage? {
        return stackedImageViewController.imageDisplayer.image
    }
    
    internal func getImageFileFromPreview() -> ImageFile? {
        return self.imagePreviewController.imageFile
    }
    
    internal func previewImage(image:NSImage) {
        self.logger.log(.info, "previewImage(NSImage)")
        for sView in self.playerContainer.subviews {
            sView.removeFromSuperview()
        }
        
        if stackedVideoViewController != nil && stackedVideoViewController.videoDisplayer != nil && stackedVideoViewController.videoDisplayer.player != nil {
            stackedVideoViewController.videoDisplayer.player?.pause()
        }
        
        stackedImageViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(stackedImageViewController.view)
        
        // show image
        stackedImageViewController.imageDisplayer.image = image
        
        self.btnImageOptions.isEnabled = true
        self.setupPreviewMenu()
    }
    
    func degreeToRadian(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
    
    internal func previewImage(url:URL, isPhoto:Bool) {
        self.logger.log(.info, "previewImage(url, isPhoto) - \(url) - \(isPhoto)")
        for sView in self.playerContainer.subviews {
            sView.removeFromSuperview()
        }
        
        if stackedVideoViewController != nil && stackedVideoViewController.videoDisplayer != nil && stackedVideoViewController.videoDisplayer.player != nil {
            stackedVideoViewController.videoDisplayer.player?.pause()
        }
        
        if isPhoto {
            
            // switch to image view
            stackedImageViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedImageViewController.view)
            
            // show image
            stackedImageViewController.imageDisplayer.image = url.loadImage(maxDimension: 512)
            
            self.btnImageOptions.isEnabled = true
            self.setupPreviewMenu()
        } else {
            
            // switch to video view
            stackedVideoViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedVideoViewController.view)
            
            // show video
            stackedVideoViewController.videoDisplayer.player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer.init(player: stackedVideoViewController.videoDisplayer.player)
            let affineTransform = CGAffineTransform(rotationAngle: degreeToRadian(180))
            playerLayer.setAffineTransform(affineTransform)
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            stackedVideoViewController.videoDisplayer.updateLayer()
            stackedVideoViewController.videoDisplayer.player?.play()
            
            self.btnImageOptions.isEnabled = true
            self.setupPreviewMenu(isVideo: true)
        }
    }
    
    internal func previewImage(image:ImageFile, isRawVersion:Bool = false) {
        self.logger.log(.trace, "previewImage(ImageFile)")
        self.imagePreviewController.imageFile = image
        let rotation = Float(image.imageData?.rotation ?? 0)
        
        
        
        if stackedVideoViewController != nil && stackedVideoViewController.videoDisplayer != nil && stackedVideoViewController.videoDisplayer.player != nil {
            stackedVideoViewController.videoDisplayer.player?.pause()
        }
        
        for sView in self.playerContainer.subviews {
            sView.removeFromSuperview()
        }
        
        if img.isPhoto {
            
            // switch to image view
            stackedImageViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedImageViewController.view)
            
            // show image
            if rotation == 0 {
                if isRawVersion {
                    stackedImageViewController.imageDisplayer.image = image.loadBackupVersionPreview()
                }else{
                    stackedImageViewController.imageDisplayer.image = image.image
                }
            }else{
                if isRawVersion {
                    stackedImageViewController.imageDisplayer.image = image.loadBackupVersionPreview().rotate(degrees: CGFloat(rotation))
                }else{
                    stackedImageViewController.imageDisplayer.image = image.image.rotate(degrees: CGFloat(rotation))
                }
            }
            
            self.btnImageOptions.isEnabled = true
            self.setupPreviewMenu()
        } else {
            
            // switch to video view
            stackedVideoViewController.view.frameCenterRotation = CGFloat(0) // must be step 1
            stackedVideoViewController.view.frame = self.playerContainer.bounds // must be step 2
            self.playerContainer.addSubview(stackedVideoViewController.view)
            
            // show video
            if isRawVersion {
                stackedVideoViewController.videoDisplayer.player = AVPlayer(url: image.getBackupUrl() ?? image.url)
            }else{
                stackedVideoViewController.videoDisplayer.player = AVPlayer(url: image.url)
            }
            if rotation != 0 {
            }else{
                stackedVideoViewController.view.frameCenterRotation = CGFloat(rotation)
            }
            stackedVideoViewController.videoDisplayer.player?.play()
            
            self.btnImageOptions.isEnabled = true
            self.setupPreviewMenu(isVideo: true)
        }
    }
    
    internal func loadImageMetaAndPreview(_ url:URL){
        
        // init meta data
        //self.metaInfo = [MetaInfo]()
        self.img = ImageFile(url: url )
        
        guard img.isPhoto || img.isVideo else {return}
        self.previewImage(image: img)
        
        //img.loadMetaInfoFromExif()
        self.loadImageExif()
        img.loadLocation()
        self.imageLocationViewController.loadMap(image: self.img)
        self.loadImageDescription(img)
    }
    
    internal func loadImageExif(_ force:Bool = false) {
        img.loadMetaInfoFromDatabase()
//        img.loadMetaInfoFromExif(force)
        img.metaInfoHolder.sort(by: MetaCategorySequence)
        self.metaInfoTableView.reloadData()
    }
    
    internal func loadImageDescription(_ img:ImageFile){
        if let image = self.img.imageData {
            var family = ""
            if let id = image.id {
                let families = ImageFamilyDao.default.getFamilies(imageId: id)
                var fam:[String] = []
                for f in families {
                    fam.append("\(f.owner)的\(f.familyName)")
                }
                family = fam.joined(separator: ", ")
            }
            self.lblImageDescription.stringValue = """
            \(family) \(image.shortDescription ?? "")
            \(image.longDescription ?? "")
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    internal func loadImageMetaAndPreview(imageFile:ImageFile){
        self.img = imageFile
        self.previewImage(image: img)
        
        self.img.metaInfoHolder.clearInfos()
        self.metaInfoTableView.reloadData()
        DispatchQueue.global().async {
            self.img.transformDomainToMetaInfo()
            self.img.metaInfoHolder.sort(by: MetaCategorySequence)
            DispatchQueue.main.async {
                self.metaInfoTableView.reloadData()
            }
        }
        
        self.imageLocationViewController.loadMap(image: imageFile)
        self.loadImageDescription(img)
    }
    
    internal func readImageLocationMeta(title:String) -> String{
        return self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Assign", title: title) ?? self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: title) ?? self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Google", title: title) ?? ""
    }
    
}
