//
//  ViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/22.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import CryptoSwift
import CoreLocation
import SwiftyJSON
import WebKit
import AVFoundation
import AVKit
import PXSourceList

class ViewController: NSViewController {
    
    var metaInfo:[MetaInfo] = [MetaInfo]()
    var img:ImageData!
    
    var zoomSize:Int = 16
    var zoomSizeForPossibleAddress:Int = 16
    var previousTick:Int = 3
    var previousTickForPossibleAddress:Int = 3
    
    var lastSelectedMetaInfoRow: Int?
    
    // MARK: PXSourceList
    var modelObjects:NSMutableArray?
    var sourceListItems:NSMutableArray?

    
    // MARK: Properties
    
    @IBOutlet weak var btnCloneLocationToFinder: NSButton!
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var metaInfoTableView: NSTableView!
    @IBOutlet weak var playerContainer: NSView!
    @IBOutlet weak var mapZoomSlider: NSSlider!
    @IBOutlet weak var addressSearcher: NSSearchField!
    @IBOutlet weak var webPossibleLocation: WKWebView!
    @IBOutlet weak var sourceList: PXSourceList!
    
    var stackedImageViewController : StackedImageViewController!
    var stackedVideoViewController : StackedVideoViewController!
    
    // MARK: init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCloneLocationToFinder.title = "▼ Copy"
        
        webLocation.setValue(false, forKey: "drawsBackground")
        webPossibleLocation.setValue(false, forKey: "drawsBackground")
        
        webLocation.load(URLRequest(url: URL(string: "about:blank")!))
        webPossibleLocation.load(URLRequest(url: URL(string: "about:blank")!))
        
        // Do any additional setup after loading the view.
        stackedImageViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "imageView")) as! StackedImageViewController
        stackedVideoViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "videoView")) as! StackedVideoViewController
        
        stackedImageViewController.parentController = self
        stackedVideoViewController.parentController = self
        
        self.addChildViewController(stackedImageViewController)
        self.addChildViewController(stackedVideoViewController)
        
        stackedImageViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(stackedImageViewController.view)
        
        PreferencesController.healthCheck()
        
        self.setUpSourceListDataModel()
        self.sourceList.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction func onMapSliderClick(_ sender: NSSliderCell) {
        let tick:Int = sender.integerValue
        if tick == previousTick {
            return
        }
        switch tick {
        case 1:
            zoomSize = 14
        case 2:
            zoomSize = 15
        case 3:
            zoomSize = 16
        case 4:
            zoomSize = 17
        default:
            zoomSize = 17
        }
        
        self.loadBaiduMap()
        previousTick = tick
    }
    
    @IBAction func onButtonOpenClick(_ sender: NSButton) {
        
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["jpg", "jpeg", "mov", "mp4", "mpg"] //CGImageSourceCopyTypeIdentifiers() as? [String]
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        if panel.runModal().rawValue == NSApplication.ModalResponse.OK.rawValue {
            processImageUrls(urls: panel.urls)
        }
    }
    
    // shared among different open-channels
    func processImageUrls(urls:[URL]){
        
        if urls.count == 0 {return}
        loadImage(urls[0])
    }
    
    private func loadImage(_ url:URL){
        
        // init meta data
        self.metaInfo = [MetaInfo]()
        self.img = ImageData(url: url, metaInfoStore: self)
        
        guard img.isPhoto || img.isVideo else {return}
        
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
            stackedImageViewController.imageDisplayer.image = img.image
            
        } else {
            
            // switch to video view
            stackedVideoViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedVideoViewController.view)
            
            // show video
            stackedVideoViewController.videoDisplayer.player = AVPlayer(url: url)
            stackedVideoViewController.videoDisplayer.player?.play()
            
        }
        img.loadExif()
        self.metaInfoTableView.reloadData()
        img.getBaiduLocation()
        self.loadBaiduMap()
    }
    
    private func loadBaiduMap() {
        webLocation.load(URLRequest(url: URL(string: "about:blank")!))
        if img.hasCoordinate {
            BaiduLocation.queryForMap(lat: img.latitudeBaidu, lon: img.longitudeBaidu, view: webLocation, zoom: zoomSize)
        }
    }
    
    @IBAction func onButtonFindClick(_ sender: NSButton) {
        let address:String = addressSearcher.stringValue
        if address == "" {return}
        BaiduLocation.queryForCoordinate(address: address, locationDelegate: self)
    }
    @IBAction func onAddressSearcherAction(_ sender: Any) {
        let address:String = addressSearcher.stringValue
        if address == "" {return}
        BaiduLocation.queryForCoordinate(address: address, locationDelegate: self)
    }
    
    
}

extension ViewController: DropPlaceDelegate {
    func dropURLs(_ urls: [URL]) {
        processImageUrls(urls: urls)
    }
}

extension ViewController: MetaInfoStoreDelegate {
    
    func setMetaInfo(_ info:MetaInfo){
        setMetaInfo(info, ifNotExists: false)
    }
    
    func setMetaInfo(_ info:MetaInfo, ifNotExists: Bool){
        if info.value == nil || info.value == "" || info.value == "null" {return}
        var exists:Int = 0
        for exist:MetaInfo in self.metaInfo {
            if exist.category == info.category && exist.subCategory == info.subCategory && exist.title == info.title {
                if ifNotExists == false {
                    exist.value = info.value
                }
                exists = 1
            }
        }
        if exists == 0 {
            self.metaInfo.append(info)
        }
    }
    
    func updateMetaInfoView() {
        self.metaInfoTableView.reloadData()
    }
}

extension ViewController: LocationDelegate {
    
    func handleLocation(address: String, latitude: Double, longitude: Double) {
        BaiduLocation.queryForMap(lat: latitude, lon: longitude, view: webPossibleLocation, zoom: zoomSizeForPossibleAddress)
    }
    
    func handleMessage(status: Int, message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
        alert.messageText = NSLocalizedString("Location Service", comment: "")
        alert.informativeText = NSLocalizedString(message, comment: "")
        alert.runModal()
    }
}

