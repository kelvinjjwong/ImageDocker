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
    var sourceListIdentifiers:[String : PXSourceListItem] = [String : PXSourceListItem] ()
    //var imageFolders:[ImageFolder] = [ImageFolder]()
    
    var librarySectionOfTree : PXSourceListItem?

    var selectedImageFolder:ImageFolder?
    var selectedImageFile:String = ""
    
    // MARK: Properties
    
    @IBOutlet weak var btnCloneLocationToFinder: NSButton!
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var metaInfoTableView: NSTableView!
    @IBOutlet weak var playerContainer: NSView!
    @IBOutlet weak var mapZoomSlider: NSSlider!
    @IBOutlet weak var addressSearcher: NSSearchField!
    @IBOutlet weak var webPossibleLocation: WKWebView!
    @IBOutlet weak var sourceList: PXSourceList!
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var collectionProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var considerPlacesCheckBox: NSButton!
    
    let imagesLoader = CollectionViewItemsLoader()
    
    var stackedImageViewController : StackedImageViewController!
    var stackedVideoViewController : StackedVideoViewController!
    
    // MARK: init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionProgressIndicator.isDisplayedWhenStopped = false
        
        view.layer?.backgroundColor = NSColor.darkGray.cgColor
        
        self.configurePreview()
        
        PreferencesController.healthCheck()
        
        self.initSourceListDataModel()
        self.loadPathToTreeFromDatabase()
        self.sourceList.backgroundColor = NSColor.darkGray
        self.sourceList.reloadData()
        
        configureCollectionView()
    }
    
    func configurePreview(){
        btnCloneLocationToFinder.title = "▼ Copy"
        
        webLocation.setValue(false, forKey: "drawsBackground")
        webPossibleLocation.setValue(false, forKey: "drawsBackground")
        
        webLocation.load(URLRequest(url: URL(string: "about:blank")!))
        webPossibleLocation.load(URLRequest(url: URL(string: "about:blank")!))
        
        self.playerContainer.layer?.borderColor = NSColor.darkGray.cgColor
        
        // Do any additional setup after loading the view.
        stackedImageViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "imageView")) as! StackedImageViewController
        stackedVideoViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "videoView")) as! StackedVideoViewController
        
        stackedImageViewController.parentController = self
        stackedVideoViewController.parentController = self
        
        self.addChildViewController(stackedImageViewController)
        self.addChildViewController(stackedVideoViewController)
        
        stackedImageViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(stackedImageViewController.view)
        
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
        self.sortMetaInfoArray()
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
    
    func loadDataForNewFolderWithUrl(folderURL: NSURL) {
        imagesLoader.load(from: folderURL)
        collectionView.reloadData()
    }
    
    private func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
        collectionView.backgroundColors = [NSColor.darkGray]
        collectionView.layer?.backgroundColor = NSColor.darkGray.cgColor
        collectionView.layer?.borderColor = NSColor.darkGray.cgColor
        
        imagesLoader.singleSectionMode = false
        imagesLoader.setupItems(urls: nil)
        collectionView.reloadData()
    }
    
    @IBAction func showHideSections(sender: AnyObject) {
        let show = (sender as! NSButton).state
        imagesLoader.singleSectionMode = (show == NSControl.StateValue.off)
        imagesLoader.setupItems(urls: nil)
        collectionView.reloadData()
    }
    
    func selectImageFile(_ filename:String){
        self.selectedImageFile = filename
        print("selected image file: \(filename)")
        let url:URL = (self.selectedImageFolder?.url.appendingPathComponent(filename, isDirectory: false))!
        DispatchQueue.main.async {
            self.loadImage(url)
        }
    }
    
    func selectImageFolder(_ imageFolder:ImageFolder){
        self.selectedImageFolder = imageFolder
        print("selected image folder: \(imageFolder.url.path)")
        
        DispatchQueue.main.async {
            self.imagesLoader.load(from: imageFolder.url as NSURL)
            self.refreshCollectionView()
            //self.collectionView.reloadData()
        }
    }
    
    @IBAction func onAddButtonClicked(_ sender: Any) {
        let window = NSApplication.shared.windows.first
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        
        openPanel.beginSheetModal(for: window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                //viewController.loadDataForNewFolderWithUrl(folderURL: URL as NSURL)
                print("want to open directory \(path)")
                DispatchQueue.main.async {
                    self.loadPathToTree(path)
                    self.sourceList.reloadData()
                }
            }
        }
    }
    
    @IBAction func onDelButtonClicked(_ sender: Any) {
        print("clicked delete button")
    }
    
    @IBAction func onRefreshButtonClicked(_ sender: Any) {
        print("clicked refresh button")
    }
    
    @IBAction func onRefreshCollectionButtonClicked(_ sender: Any) {
        self.refreshImagesLocation()
    }
    
    @IBAction func onPlacesCheckBoxClicked(_ sender: NSButton) {
        refreshCollectionView()
    }
    
    private func refreshCollectionView() {
        var needRefreshLocation = false
        for item in imagesLoader.getItems() {
            if item.place == "" {
                needRefreshLocation = true
            }
        }
        if needRefreshLocation {
            refreshImagesLocation()
        }else{
            imagesLoader.reorganizeItems(considerPlaces: (self.considerPlacesCheckBox.state == NSButton.StateValue.on))
        }
    }
    
    private func refreshImagesLocation() {
        if imagesLoader.getItems().count > 0 {
            let accumulator:Accumulator = Accumulator(target: imagesLoader.getItems().count, indicator: self.collectionProgressIndicator)
            for item in imagesLoader.getItems() {
                item.loadLocation(consumer: MetaConsumer(item, accumulator: accumulator, onComplete: self) as MetaInfoConsumeDelegate)
            }
        }
    }
    
}

protocol PlacesCompletionEvent {
    func onPlacesCompleted()
}

extension ViewController : PlacesCompletionEvent {
    
    func onPlacesCompleted() {
        imagesLoader.reorganizeItems(considerPlaces: (self.considerPlacesCheckBox.state == NSButton.StateValue.on))
        self.collectionView.reloadData()
    }
}

class MetaConsumer : MetaInfoConsumeDelegate {
    
    var imageFile:ImageFile?
    let accumulator:Accumulator?
    let onCompleteHandler:PlacesCompletionEvent?
    
    init(_ imageFile:ImageFile, accumulator:Accumulator? = nil, onComplete:PlacesCompletionEvent? = nil){
        self.imageFile = imageFile
        self.accumulator = accumulator
        self.onCompleteHandler = onComplete
    }
    
    func consume(_ infos:[MetaInfo]){
        imageFile?.recognizePlace()
        print("place: \(imageFile?.place ?? "")")
        
        if accumulator != nil && (accumulator?.add())! {
            if self.onCompleteHandler != nil {
                onCompleteHandler?.onPlacesCompleted()
            }
        }
    }
    
}

// reference accumulator
class Accumulator : NSObject {
    
    let _target:Int
    private var count:Int = 0
    private let indicator:NSProgressIndicator?
    
    init(target:Int, indicator:NSProgressIndicator? = nil){
        count = 0
        self._target = target
        self.indicator = indicator
        if indicator != nil {
            indicator?.minValue = 0
            indicator?.maxValue = Double(target)
            indicator?.doubleValue = 0
            indicator?.isHidden = false
            //indicator?.isIndeterminate = true
        }
    }
    
    func add() -> Bool{
        self.count += 1
        let completed:Bool = (count == _target)
        if indicator != nil {
            indicator?.increment(by: 1)
            if completed {
                indicator?.isHidden = true
            }
        }
        return completed
    }
    
    func working() -> Bool {
        return count < _target
    }
    
    func current() -> Int {
        return count
    }
    
    func target() -> Int {
        return _target
    }
    
    func reset() {
        count = 0
    }
}




