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

class ViewController: NSViewController {
    
    var metaInfo:[MetaInfo] = [MetaInfo]()
    var img:ImageData!
    
    var zoomSize:Int = 16
    var previousTick:Int = 3
    
    var lastSelectedMetaInfoRow: Int?

    
    // MARK: Properties
    
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var metaInfoTableView: NSTableView!
    @IBOutlet weak var playerContainer: NSView!
    
    var stackedImageViewController : StackedImageViewController!
    var stackedVideoViewController : StackedVideoViewController!
    
    // MARK: init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if url.lastPathComponent.split(separator: Character(".")).count < 2 {return}
        let fileExt:String = (url.lastPathComponent.split(separator: Character(".")).last?.lowercased())!
        guard fileExt == "jpg" || fileExt == "jpeg" || fileExt == "mov" || fileExt == "mp4" || fileExt == "mpeg" else {return}
        
        // init meta data
        self.metaInfo = [MetaInfo]()
        self.img = ImageData(url: url, metaInfoStore: self)
        
        for sView in self.playerContainer.subviews {
            sView.removeFromSuperview()
        }
        
        if stackedVideoViewController != nil && stackedVideoViewController.videoDisplayer != nil && stackedVideoViewController.videoDisplayer.player != nil {
            stackedVideoViewController.videoDisplayer.player?.pause()
        }
        
        if fileExt == "jpg" || fileExt == "jpeg" {
            
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
        let width:Int = Int(min(CGFloat(512), webLocation.frame.size.width))
        let height:Int = Int(min(CGFloat(512), webLocation.frame.size.height))
        let requestBaiduUrl = BaiduLocation.urlForMap(width: width, height: height, zoom: zoomSize, lat: img.latitudeBaidu, lon: img.longitudeBaidu)
        guard let requestUrl = URL(string: requestBaiduUrl) else {return}
        let req = URLRequest(url: requestUrl)
        webLocation.load(req)
        
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

