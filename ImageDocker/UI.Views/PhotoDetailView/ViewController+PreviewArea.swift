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
            print("meta double clicked row \(row)")
            let info = self.img.metaInfoHolder.getInfos()[row]
            if let value = info.value {
                print("clicked info \(value)")
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(value, forType: .string)
                
                MessageEventCenter.default.showMessage(message: "Copied image's meta value to pasteboard.")
            }
            
        }
    }

    internal func configurePreview(){
        self.splitviewPreview.dividerStyle = .thick
        
        self.imageMetaViewController = storyboard?.instantiateController(withIdentifier: "ImageMetaViewController") as! ImageMetaViewController
        self.splitviewPreview.addArrangedSubview(imageMetaViewController.view)
        
        self.scrollviewMetaInfoTable = imageMetaViewController.scrollView
        self.metaInfoTableView = imageMetaViewController.tableView
        self.metaInfoTableView.delegate = self
        self.metaInfoTableView.dataSource = self
        
        self.metaInfoTableView.toolTip = "Double click to copy value."
        self.metaInfoTableView.target = self
        self.metaInfoTableView.doubleAction = #selector(onMetaTableDoubleClicked)
        
        
            
        self.imagePreviewController = storyboard?.instantiateController(withIdentifier: "ImagePreviewController") as! ImagePreviewController
        self.splitviewPreview.addArrangedSubview(imagePreviewController.view)
        
        self.imagePreviewController.getImageFromPreview = {
            return self.getImageFromPreview()
        }
        
        self.imagePreviewController.previewImage = { nsImage in
            self.previewImage(image: nsImage)
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
        stackedVideoViewController.view.layer?.backgroundColor = Colors.DarkGray.cgColor
        stackedImageViewController.view.layer?.backgroundColor = Colors.DarkGray.cgColor
        
        self.addChild(stackedImageViewController)
        self.addChild(stackedVideoViewController)
        
        stackedImageViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(stackedImageViewController.view)
        self.playerContainer.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        self.playerContainer.layer?.borderColor = Colors.DarkGray.cgColor
        self.playerContainer.layer?.backgroundColor = Colors.DarkGray.cgColor
        
        self.imageLocationViewController = storyboard?.instantiateController(withIdentifier: "ImageLocationViewController") as! ImageLocationViewController
        self.splitviewPreview.addArrangedSubview(imageLocationViewController.view)
        
        self.webLocation = self.imageLocationViewController.locationWebView
        self.mapZoomSlider = self.imageLocationViewController.locationSlider
        
        webLocation.setValue(false, forKey: "drawsBackground")
        webLocation.load(URLRequest(url: URL(string: "about:blank")!))
        
        self.imageLocationEditViewController = storyboard?.instantiateController(withIdentifier: "ImageLocationEditViewController") as! ImageLocationEditViewController
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
        
        self.splitviewPreview.addArrangedSubview(imageLocationEditViewController.view)
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
        
        
        
    }
    
    // shared among different open-channels
    internal func processImageUrls(urls:[URL]){
        
        if urls.count == 0 {return}
        loadImage(urls[0])
    }
    
    internal func getImageFromPreview() -> NSImage? {
        return stackedImageViewController.imageDisplayer.image
    }
    
    internal func previewImage(image:NSImage) {
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
    }
    
    internal func previewImage(url:URL, isPhoto:Bool) {
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
        } else {
            
            // switch to video view
            stackedVideoViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedVideoViewController.view)
            
            // show video
            stackedVideoViewController.videoDisplayer.player = AVPlayer(url: url)
            stackedVideoViewController.videoDisplayer.player?.play()
            
            self.btnImageOptions.isEnabled = false
        }
    }
    
    internal func previewImage(image:ImageFile) {
        self.imagePreviewController.imageFile = image
        
        let rotation = Float(image.imageData?.rotation ?? 0)
        
        
        for sView in self.playerContainer.subviews {
            sView.removeFromSuperview()
        }
        
        if stackedVideoViewController != nil && stackedVideoViewController.videoDisplayer != nil && stackedVideoViewController.videoDisplayer.player != nil {
            stackedVideoViewController.videoDisplayer.player?.pause()
        }
        
        if img.isPhoto {
            
            // switch to image view
            stackedImageViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedImageViewController.view)
            
            // show image
            if rotation == 0 {
                stackedImageViewController.imageDisplayer.image = image.image
            }else{
                stackedImageViewController.imageDisplayer.image = image.image.rotate(degrees: CGFloat(rotation))
            }
            
            self.btnImageOptions.isEnabled = true
        } else {
            
            // switch to video view
            stackedVideoViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedVideoViewController.view)
            
            // show video
            stackedVideoViewController.videoDisplayer.player = AVPlayer(url: image.url)
            stackedVideoViewController.videoDisplayer.player?.play()
            
            self.btnImageOptions.isEnabled = false
        }
    }
    
    internal func loadImage(_ url:URL){
        
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
        img.loadMetaInfoFromExif(force)
        img.metaInfoHolder.sort(by: MetaCategorySequence)
        self.metaInfoTableView.reloadData()
    }
    
    internal func loadImageDescription(_ img:ImageFile){
        if let image = self.img.imageData {
            var people = ""
            if let id = image.id {
                let faces = FaceDao.default.getFaceCrops(imageId: id)
                for face in faces {
                    if let peopleId = face.peopleId, peopleId != "" {
                        var name = FaceTask.default.people(id: peopleId)
                        if name == "" {
                            name = "(unknown)"
                        }
                        people += "\(name) "
                    }
                }
            }
            self.lblImageDescription.stringValue = """
            \(people) \(image.shortDescription ?? "")
            \(image.longDescription ?? "")
            """
        }
    }
    
    internal func loadImage(imageFile:ImageFile){
        self.img = imageFile
        self.previewImage(image: img)
        //self.img.transformDomainToMetaInfo()
        img.metaInfoHolder.sort(by: MetaCategorySequence)
        self.metaInfoTableView.reloadData()
        
        self.imageLocationViewController.loadMap(image: imageFile)
        self.loadImageDescription(img)
    }
    
    internal func readImageLocationMeta(title:String) -> String{
        return self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Assign", title: title) ?? self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: title) ?? self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Google", title: title) ?? ""
    }
}
