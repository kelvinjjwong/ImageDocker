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
    
    // MARK: Icon
    let tick:NSImage = NSImage.init(named: NSImage.Name.menuOnStateTemplate)!
    
    // MARK: Timer
    var scanLocationChangeTimer:Timer!
    var lastCheckLocationChange:Date?
    var scanPhotoTakenDateChangeTimer:Timer!
    var lastCheckPhotoTakenDateChange:Date?
    var scanEventChangeTimer:Timer!
    var lastCheckEventChange:Date?
    var exportPhotosTimers:Timer!
    var lastExportPhotos:Date?
    var scanRepositoriesTimer:Timer!
    var lastScanRepositories:Date?
    var scanPhotosToLoadExifTimer:Timer!
    
    @IBOutlet weak var splitviewPreview: DarkSplitView!
    @IBOutlet weak var scrollviewMetaInfoTable: NSScrollView!
    
    
    // MARK: Image preview
    var img:ImageFile!
    @IBOutlet weak var playerContainer: NSView!
    var stackedImageViewController : StackedImageViewController!
    var stackedVideoViewController : StackedVideoViewController!
    
    // MARK: MetaInfo table view
    //var metaInfo:[MetaInfo] = [MetaInfo]()
    var lastSelectedMetaInfoRow: Int?
    @IBOutlet weak var metaInfoTableView: NSTableView!
    
    // MARK: Image Map
    var zoomSize:Int = 16
    var previousTick:Int = 3
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var mapZoomSlider: NSSlider!
    
    // MARK: Editor - Map
    var zoomSizeForPossibleAddress:Int = 16
    var previousTickForPossibleAddress:Int = 3
    @IBOutlet weak var addressSearcher: NSSearchField!

    @IBOutlet weak var webPossibleLocation: WKWebView!
    var possibleLocation:Location?
    
    @IBOutlet weak var possibleLocationText: NSTextField!
    var locationTextDelegate:LocationTextDelegate?
    
    @IBOutlet weak var btnCopyLocation: NSButton!
    @IBOutlet weak var btnReplaceLocation: NSButton!
    @IBOutlet weak var btnManagePlaces: NSButton!
    
    @IBOutlet weak var btnChoiceMapService: NSSegmentedControl!
    
    var coordinateAPI:LocationAPI = .baidu
    
    // MARK: Tree
    //var modelObjects:NSMutableArray?
    var sourceListItems:NSMutableArray?
    var identifiersOfLibraryTree:[String : PXSourceListItem] = [String : PXSourceListItem] ()
    var parentsOfMomentsTree : [String : PXSourceListItem] = [String : PXSourceListItem] ()
    var momentToCollection : [String : PhotoCollection] = [String : PhotoCollection] ()
    var treeIdItemsExpandState : [String : Bool] = [String : Bool] ()
    var treeLastSelectedIdentifier : String = ""
    var treeIdItems : [String : PXSourceListItem] = [String : PXSourceListItem] ()
    var momentToCollectionGroupByPlace : [String : PhotoCollection] = [String : PhotoCollection] ()
    var parentsOfMomentsTreeGroupByPlace : [String : PXSourceListItem] = [String : PXSourceListItem] ()
    var treeRefreshing:Bool = false
    
    var parentsOfEventsTree : [String : PXSourceListItem] = [String : PXSourceListItem] ()
    var eventToCollection : [String : PhotoCollection] = [String : PhotoCollection] ()
    
    var deviceToCollection : [String : PhotoCollection] = [String : PhotoCollection] ()
    var deviceIdToDevice : [String : PhoneDevice] = [String : PhoneDevice] ()
    
    var deviceSectionOfTree : PXSourceListItem?
    var librarySectionOfTree : PXSourceListItem?
    var momentSectionOfTree : PXSourceListItem?
    var placeSectionOfTree : PXSourceListItem?
    var eventSectionOfTree : PXSourceListItem?

    var selectedImageFolder:ImageFolder?
    var selectedImageFile:String = ""
    
    @IBOutlet weak var btnScanState: NSButton!
    @IBOutlet weak var sourceList: PXSourceList!
    
    var treeLoadingIndicator:Accumulator?
    //@IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var btnAddRepository: NSButton!
    @IBOutlet weak var btnRemoveRepository: NSButton!
    @IBOutlet weak var btnRefreshRepository: NSButton!
    @IBOutlet weak var btnFilterRepository: NSButton!
    
    
    @IBOutlet weak var lblExportMessage: NSTextField!
    
    @IBOutlet weak var chbExport: NSButton!
    @IBOutlet weak var chbScan: NSButton!
    @IBOutlet weak var chbSelectAll: NSButton!
    
    
    // MARK: Collection View for browsing
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var collectionProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var indicatorMessage: NSTextField!
    @IBOutlet weak var btnRefreshCollectionView: NSButton!
    
    @IBOutlet weak var chbShowHidden: NSButton!
    
    let imagesLoader = CollectionViewItemsLoader()
    var collectionLoadingIndicator:Accumulator?
    
    // MARK: Collection View for selection
    var selectionViewController : SelectionCollectionViewController!
    
    @IBOutlet weak var selectionCollectionView: NSCollectionView!
    
    @IBOutlet weak var selectionCheckAllBox: NSButton!
    
    @IBOutlet weak var btnAssignEvent: NSButton!
    @IBOutlet weak var btnManageEvents: NSButton!
    @IBOutlet weak var btnRemoveSelection: NSButton!
    @IBOutlet weak var btnShow: NSButton!
    @IBOutlet weak var btnHide: NSButton!
    @IBOutlet weak var btnRemoveAllSelection: NSButton!
    @IBOutlet weak var btnShare: NSButton!
    @IBOutlet weak var btnCopyToDevice: NSButton!
    
    
    
    // MARK: Editor - DateTime
    
    @IBOutlet weak var editorDatePicker: NSDatePicker!
    @IBOutlet weak var batchEditIndicator: NSProgressIndicator!
    @IBOutlet weak var btnReplaceDateTime: NSButton!
    
    // MARK: Popover
    
    var eventPopover:NSPopover?
    var eventViewController:EventListViewController!
    
    var placePopover:NSPopover?
    var placeViewController:PlaceListViewController!
    
    var filterPopover:NSPopover?
    var filterViewController:FilterViewController!
    
    @IBOutlet weak var comboEventList: NSComboBox!
    @IBOutlet weak var comboPlaceList: NSComboBox!
    var eventListController:EventListComboController!
    var placeListController:PlaceListComboController!
    
    // MARK: Device Copy Dialog
    
    var deviceCopyWindowController:NSWindowController!
    
    // MARK: Concurrency Indicators
    
    var scaningRepositories:Bool = false
    var creatingRepository:Bool = false
    var suppressedExport:Bool = false
    var suppressedScan:Bool = false
    
    // MARK: init
    
    var windowInitial:Bool = false
    
    func resize() {
        guard !windowInitial else {return}
        let dockerHeight = 80
        let menubarHeight = 20
        
        let screenWidth = NSScreen.main?.frame.width
        let screenHeight = NSScreen.main?.frame.height
        
        let windowOriginPoint = CGPoint(x: 0, y: dockerHeight)
        let newWidth = screenWidth!
        let newHeight = screenHeight! - CGFloat(dockerHeight + menubarHeight)
        let windowSize = NSMakeSize(newWidth, newHeight)
        let windowMinSize = NSMakeSize(CGFloat(600), CGFloat(500))
        let windowMaxSize = NSMakeSize(screenWidth!, screenHeight! - CGFloat(5))
        
        var windowFrame = self.view.window?.frame
        windowFrame?.size = windowSize
        windowFrame?.origin = windowOriginPoint
        self.view.window?.maxSize = windowMaxSize
        self.view.window?.minSize = windowMinSize
        self.view.window?.setFrame(windowFrame!, display: true)
        
        self.splitviewPreview.setPosition(newHeight - CGFloat(670), ofDividerAt: 0)
        
        windowInitial = true
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
        self.resize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Date()) Loading view")
        ModelStore.default.checkData()
        
        //self.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        //progressIndicator.isDisplayedWhenStopped = false
        collectionProgressIndicator.isDisplayedWhenStopped = false
        batchEditIndicator.isDisplayedWhenStopped = false
        
        print("\(Date()) Loading view - configure dark mode")
        configureDarkMode()
        
        self.imagesLoader.hiddenCountHandler = { hiddenCount in
            DispatchQueue.main.async {
                self.chbShowHidden.title = "Hidden (\(hiddenCount))"
                print("hidden: \(hiddenCount)")
            }
        }
        
        self.chbShowHidden.state = NSButton.StateValue.off
        
        print("\(Date()) Loading view - preview zone")
        self.configurePreview()
        print("\(Date()) Loading view - selection view")
        self.configureSelectionView()
        
        PreferencesController.healthCheck()
        
        print("\(Date()) Loading view - configure tree")
        configureTree()
        print("\(Date()) Loading view - configure collection view")
        configureCollectionView()
        print("\(Date()) Loading view - configure editors")
        configureEditors()
        print("\(Date()) Loading view - setup event list")
        setupEventList()
        print("\(Date()) Loading view - setup place list")
        setupPlaceList()
        print("\(Date()) Loading view - update library tree")
        updateLibraryTree()
        print("\(Date()) Loading view - update library tree: DONE")
        
        self.deviceCopyWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DeviceCopyWindowController")) as! NSWindowController
        
        
        self.btnChoiceMapService.selectSegment(withTag: 1)
        self.coordinateAPI = .baidu
        
        self.btnChoiceMapService.setImage(nil, forSegment: 0)
        self.btnChoiceMapService.setImage(tick, forSegment: 1)
        
        self.chbScan.state = NSButton.StateValue.off
        self.suppressedScan = true
        self.btnScanState.image = NSImage(named: NSImage.Name.statusNone)
        self.btnScanState.isHidden = true
        
        self.chbExport.state = NSButton.StateValue.off
        ExportManager.messageBox = self.lblExportMessage
        ExportManager.suppressed = true
        self.suppressedExport = true
        self.lastExportPhotos = Date()
        
        self.scanLocationChangeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
            guard !ExportManager.working && !self.scaningRepositories && !self.creatingRepository && !self.treeRefreshing else {return}
            print("\(Date()) SCANING LOCATION CHANGE")
            if self.lastCheckLocationChange != nil {
                let photoFiles:[Image] = ModelStore.default.getPhotoFiles(after: self.lastCheckLocationChange!)
                if photoFiles.count > 0 {
                    self.saveTreeItemsExpandState()
                    self.refreshLocationTree()
                    self.restoreTreeItemsExpandState()
                    self.restoreTreeSelection()
                    self.lastCheckLocationChange = Date()
                }
            }
        })
        
        self.scanPhotoTakenDateChangeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
            guard !ExportManager.working && !self.scaningRepositories && !self.creatingRepository && !self.treeRefreshing else {return}
            print("\(Date()) SCANING DATE CHANGE")
            if self.lastCheckPhotoTakenDateChange != nil {
                let photoFiles:[Image] = ModelStore.default.getPhotoFiles(after: self.lastCheckPhotoTakenDateChange!)
                if photoFiles.count > 0 {
                    self.saveTreeItemsExpandState()
                    self.refreshMomentTree()
                    self.restoreTreeItemsExpandState()
                    self.restoreTreeSelection()
                    self.lastCheckPhotoTakenDateChange = Date()
                }
            }
        })
        
        self.scanEventChangeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
            guard !ExportManager.working && !self.scaningRepositories && !self.creatingRepository && !self.treeRefreshing else {return}
            print("\(Date()) SCANING EVENT CHANGE")
            if self.lastCheckEventChange != nil {
                let photoFiles:[Image] = ModelStore.default.getPhotoFiles(after: self.lastCheckEventChange!)
                if photoFiles.count > 0 {
                    self.saveTreeItemsExpandState()
                    self.refreshEventTree()
                    self.restoreTreeItemsExpandState()
                    self.restoreTreeSelection()
                    self.lastCheckEventChange = Date()
                }
            }
        })
        
        self.exportPhotosTimers = Timer.scheduledTimer(withTimeInterval: 600, repeats: true, block:{_ in
            print("\(Date()) TRYING TO EXPORT \(self.suppressedExport) \(ExportManager.suppressed) \(ExportManager.working)")
            guard !self.suppressedExport && !ExportManager.suppressed && !ExportManager.working else {return}
            print("\(Date()) EXPORTING")
            DispatchQueue.global().async {
                ExportManager.export(after: self.lastExportPhotos!)
                self.lastExportPhotos = Date()
            }
        })
        
        self.scanRepositoriesTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true, block:{_ in
            print("\(Date()) TRY TO SCAN REPOS")
            guard !self.suppressedScan && !ExportManager.working && !self.scaningRepositories && !self.creatingRepository else {return}
            print("\(Date()) SCANING REPOS")
            self.startScanRepositories()
        })
        
        self.scanPhotosToLoadExifTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block:{_ in
            print("\(Date()) TRY TO SCAN PHOTO TO LOAD EXIF")
            guard !self.suppressedScan && !ExportManager.working && !self.scaningRepositories && !self.creatingRepository else {return}
            print("\(Date()) SCANING PHOTOS TO LOAD EXIF")
            self.startScanRepositoriesToLoadExif()
        })
        
        print("\(Date()) Loading view: DONE")
    }
    
    func configureDarkMode() {
        view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        view.layer?.backgroundColor = NSColor.darkGray.cgColor
        self.btnAssignEvent.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnCopyLocation.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnManageEvents.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnManagePlaces.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnAddRepository.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRemoveSelection.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnReplaceDateTime.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnReplaceLocation.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRemoveRepository.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRefreshRepository.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnFilterRepository.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRefreshCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.comboEventList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboEventList.backgroundColor = NSColor.darkGray
        self.comboPlaceList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboPlaceList.backgroundColor = NSColor.darkGray
        self.addressSearcher.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.addressSearcher.backgroundColor = NSColor.darkGray
        self.addressSearcher.drawsBackground = true
        self.btnChoiceMapService.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.selectionCheckAllBox.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.chbExport.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.chbScan.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.chbShowHidden.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.lblExportMessage.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.editorDatePicker.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.editorDatePicker.backgroundColor = NSColor.darkGray
        self.editorDatePicker.isBordered = false
        
        self.btnShow.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnHide.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.sourceList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.metaInfoTableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.collectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.selectionCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.playerContainer.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        
    }
    
    func configureTree(){
        self.initTreeDataModel()
        print("\(Date()) Loading view - configure tree - loading path to tree from db")
        self.loadPathToTreeFromDatabase()
        print("\(Date()) Loading view - configure tree - loading moments to tree from db")
        self.loadMomentsToTreeFromDatabase()
        print("\(Date()) Loading view - configure tree - loading places to tree from db")
        self.loadPlacesToTreeFromDatabase()
        print("\(Date()) Loading view - configure tree - loading events to tree from db")
        self.loadEventsToTreeFromDatabase()
        print("\(Date()) Loading view - configure tree - reloading tree view")
        self.sourceList.backgroundColor = NSColor.darkGray
        self.sourceList.reloadData()
    }
    
    func configurePreview(){
        
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
        
        possibleLocationText.textColor = NSColor.white
        locationTextDelegate = LocationTextDelegate()
        locationTextDelegate?.textField = self.possibleLocationText
        
    }
    
    private func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 180.0, height: 150.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
        collectionView.backgroundColors = [NSColor.darkGray]
        collectionView.layer?.backgroundColor = NSColor.darkGray.cgColor
        collectionView.layer?.borderColor = NSColor.darkGray.cgColor
        
        imagesLoader.singleSectionMode = false
        imagesLoader.showHidden = false
        imagesLoader.clean()
        collectionView.reloadData()
    }
    
    func configureSelectionView(){
        
        // init controller
        selectionViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "selectionView")) as! SelectionCollectionViewController
        self.addChildViewController(selectionViewController)
        
        // outlet
        self.selectionCollectionView.dataSource = selectionViewController
        self.selectionCollectionView.delegate = selectionViewController
        
        // flow layout
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 180.0, height: 150.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        selectionCollectionView.collectionViewLayout = flowLayout

        // view layout
        selectionCollectionView.wantsLayer = true
        selectionCollectionView.backgroundColors = [NSColor.darkGray]
        selectionCollectionView.layer?.backgroundColor = NSColor.darkGray.cgColor
        selectionCollectionView.layer?.borderColor = NSColor.darkGray.cgColor
        
        // data model
        selectionViewController.collectionView = self.selectionCollectionView
        selectionViewController.imagesLoader.singleSectionMode = true
        selectionViewController.imagesLoader.clean()
        
        selectionCollectionView.reloadData()
        
    }
    
    func configureEditors(){
        editorDatePicker.dateValue = Date()
        comboEventList.isEditable = false
        comboPlaceList.isEditable = false
    }
    
    // MARK: Preview Zone
    
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
    
    private func previewImage(image:ImageFile) {
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
            stackedImageViewController.imageDisplayer.image = image.image
            
        } else {
            
            // switch to video view
            stackedVideoViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedVideoViewController.view)
            
            // show video
            stackedVideoViewController.videoDisplayer.player = AVPlayer(url: image.url)
            stackedVideoViewController.videoDisplayer.player?.play()
            
        }
    }
    
    private func loadImage(_ url:URL){
        
        // init meta data
        //self.metaInfo = [MetaInfo]()
        self.img = ImageFile(url: url, sharedDB:ModelStore.sharedDBPool() )
        
        guard img.isPhoto || img.isVideo else {return}
        self.previewImage(image: img)
        
        //img.loadMetaInfoFromExif()
        img.loadMetaInfoFromDatabase()
        img.loadMetaInfoFromExif()
        img.metaInfoHolder.sort(by: MetaCategorySequence)
        self.metaInfoTableView.reloadData()
        img.loadLocation()
        self.loadBaiduMap()
    }
    
    private func loadImage(imageFile:ImageFile){
        self.img = imageFile
        self.previewImage(image: img)
        //self.img.transformDomainToMetaInfo()
        img.metaInfoHolder.sort(by: MetaCategorySequence)
        self.metaInfoTableView.reloadData()
        self.loadBaiduMap()
    }
    
    private func loadBaiduMap() {
        webLocation.load(URLRequest(url: URL(string: "about:blank")!))
        if img.location.coordinateBD != nil && img.location.coordinateBD!.isNotZero {
            BaiduLocation.queryForMap(coordinateBD: img.location.coordinateBD!, view: webLocation, zoom: zoomSize)
        }else{
            print("img has no coord")
        }
    }
    
    // MARK: Tree Node Controls
    
    fileprivate func startScanRepositories(){
        DispatchQueue.global().async {
            ExportManager.disable()
            self.creatingRepository = true
            DispatchQueue.main.async {
                self.btnScanState.image = NSImage(named: NSImage.Name.statusAvailable)
            }
            self.treeLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true,
                                                    lblMessage: self.indicatorMessage,
                                                    presetAddingMessage: "Importing images ...",
                                                    onCompleted: {data in
                                                        print("COMPLETE SCAN REPO")
                                                        ExportManager.enable()
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
                ImageFolderTreeScanner.scanRepositories(indicator: self.treeLoadingIndicator)
            })
            
        }
    }
    
    func updateLibraryTree() {
        self.creatingRepository = true
        print("\(Date()) UPDATING CONTAINERS")
        DispatchQueue.global().async {
            ImageFolderTreeScanner.updateContainers(onCompleted: {
                
                print("\(Date()) UPDATING CONTAINERS: DONE")
                
                DispatchQueue.main.async {
                    print("\(Date()) UPDATING LIBRARY TREE")
                    self.saveTreeItemsExpandState()
                    self.refreshLibraryTree()
                    self.restoreTreeItemsExpandState()
                    self.restoreTreeSelection()
                    print("\(Date()) UPDATING LIBRARY TREE: DONE")
                    
                    self.creatingRepository = false
                }
                
            })
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
                //self.creatingRepository = true
                //DispatchQueue.main.async {
                    //self.loadPathToTree(path)
                ImageFolderTreeScanner.createRepository(path: path)
                self.updateLibraryTree()
                    //self.sourceList.reloadData()
                //}
            }
        }
    }
    
    @IBAction func onDelButtonClicked(_ sender: Any) {
        print("clicked delete button")
        if self.selectedImageFolder != nil {
            if(self.selectedImageFolder?.containerFolder?.parentFolder == ""){
                if self.dialogOKCancel(question: "Remove all photos relate to this folder ?", text: selectedImageFolder!.url.path) {
                    let rootPath:String = (selectedImageFolder?.containerFolder?.path)!
                    ModelStore.default.deleteContainer(path: rootPath)
                    //self.initSourceListDataModel()
                    let selectedItem:PXSourceListItem = self.sourceList.item(atRow: self.sourceList.selectedRow) as! PXSourceListItem
                    let parentItem:PXSourceListItem = self.libraryItem()
                    
                    // TODO: change to SET<String> for performance
                    self.sourceList.removeItems(at: NSIndexSet(index: parentItem.children.index(where: {$0 as! PXSourceListItem === selectedItem})! ) as IndexSet,
                                                inParent: parentItem,
                                                withAnimation: NSTableView.AnimationOptions.slideUp)
                    //self.loadPathToTreeFromDatabase()
                    //self.sourceList.reloadData()
                    self.sourceListItems?.remove(selectedItem.representedObject)
                    parentItem.removeChildItem(selectedItem)
                    
                    imagesLoader.clean()
                    collectionView.reloadData()
                    
                    self.saveTreeItemsExpandState()
                    self.refreshMomentTree()
                    self.refreshLocationTree()
                    self.restoreTreeItemsExpandState()
                    self.restoreTreeSelection()
                }
            }
        }
    }
    
    func refreshTree(fast:Bool = true) {
        self.saveTreeItemsExpandState()
        
        self.refreshLibraryTree(fast: fast)
        self.refreshMomentTree()
        self.refreshLocationTree()
        self.refreshEventTree()
        
        self.restoreTreeItemsExpandState()
        self.restoreTreeSelection()
    }
    
    @IBAction func onRefreshButtonClicked(_ sender: Any) {
        print("clicked refresh button")
        
        ModelStore.default.reloadDuplicatePhotos()
        self.refreshTree(fast: false)
    }
    
    var filterImageSource:[String] = []
    var filterCameraModel:[String] = []
    
    @IBAction func onFilterButtonClicked(_ sender: NSButton) {
        self.createFilterPopover()
        
        let cellRect = sender.bounds
        self.filterPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    func createFilterPopover(){
        var myPopover = self.filterPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 300))
            self.filterViewController = FilterViewController(onApply: { (imageSources, cameraModels) in
                self.filterImageSource = imageSources
                self.filterCameraModel = cameraModels
                self.refreshTree()
            })
            self.filterViewController.view.frame = frame
            //self.filterViewController.refreshDelegate = self
            
            myPopover!.contentViewController = self.filterViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.filterPopover = myPopover
    }
    
    @IBAction func onCheckScanClicked(_ sender: NSButton) {
        if self.chbScan.state == NSButton.StateValue.on {
            print("enabled scan")
            self.suppressedScan = false
            ImageFolderTreeScanner.suppressedScan = false
            
            self.btnScanState.isHidden = false
            self.btnScanState.image = NSImage(named: NSImage.Name.statusPartiallyAvailable)
            
            // start scaning immediatetly
            self.startScanRepositories()
        }else {
            print("disabled scan")
            self.suppressedScan = true
            ImageFolderTreeScanner.suppressedScan = true
            
            self.btnScanState.image = NSImage(named: NSImage.Name.statusNone)
            self.btnScanState.isHidden = true
        }
    }
    
    fileprivate func startScanRepositoriesToLoadExif(){
        if !ExportManager.working && !self.scaningRepositories && !self.creatingRepository {
            DispatchQueue.global().async {
                
                ExportManager.suppressed = true
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
                                                            
                                                            ExportManager.suppressed = false
                                                            self.scaningRepositories = false
                                                            DispatchQueue.main.async {
                                                                self.btnScanState.image = NSImage(named: NSImage.Name.statusPartiallyAvailable)
                                                                self.indicatorMessage.stringValue = ""
                                                            }
                }
                )
                ImageFolderTreeScanner.scanPhotosToLoadExif(indicator: self.treeLoadingIndicator)
            }
        }
    }
    
    // MARK: Collection View Controls
    
    func selectImageFile(_ imageFile:ImageFile){
        self.selectedImageFile = imageFile.fileName
        //print("selected image file: \(filename)")
        //let url:URL = (self.selectedImageFolder?.url.appendingPathComponent(imageFile.fileName, isDirectory: false))!
        DispatchQueue.main.async {
            self.loadImage(imageFile: imageFile)
        }
    }
    
    func refreshCollection(){
        DispatchQueue.global().async {
            if self.imagesLoader.isLoading() {
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.reload()
                    self.refreshCollectionView()
                })
            }else {
                self.imagesLoader.reload()
                self.refreshCollectionView()
            }
            
        }
    }
    
    @IBAction func onRefreshCollectionButtonClicked(_ sender: Any) {
        self.refreshCollection()
    }
    
    
    @IBAction func onCheckSelectAllClicked(_ sender: NSButton) {
        if self.chbSelectAll.state == .on {
            self.imagesLoader.checkAll()
        }else{
            self.imagesLoader.uncheckAll()
        }
    }
    
    
    @IBAction func onCheckShowHiddenClicked(_ sender: NSButton) {
        if self.chbShowHidden.state == NSButton.StateValue.on {
            self.imagesLoader.showHidden = true
        }else{
            self.imagesLoader.showHidden = false
        }
        
        self.scaningRepositories = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        DispatchQueue.global().async {
            if self.imagesLoader.isLoading(){
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.reload()
                    self.refreshCollectionView()
                })
            }else{
                self.imagesLoader.reload()
                self.refreshCollectionView()
            }
            
        }
    }
    
    
    @IBAction func onCheckExportClicked(_ sender: NSButton) {
        if self.chbExport.state == NSButton.StateValue.on {
            print("enabled export")
            self.suppressedExport = false
            ExportManager.suppressed = false
            
            // start exporting immediatetly
            if !ExportManager.working {
                DispatchQueue.global().async {
                    ExportManager.export(after: self.lastExportPhotos!)
                    self.lastExportPhotos = Date()
                }
            }
            //ExportManager.enable()
        }else {
            print("disabled export")
            self.suppressedExport = true
            ExportManager.suppressed = true
            //ExportManager.disable()
        }
    }
    
    // MARK: Selection View Controls
    
    @IBAction func onShareClicked(_ sender: Any) {
    }
    
    
    @IBAction func onCopyToDeviceClicked(_ sender: Any) {
    }
    
    
    @IBAction func onSelectionRemoveAllClicked(_ sender: Any) {
        // remove from selection
        var images:Set<String> = []
        for image in self.selectionViewController.imagesLoader.getItems() {
            images.insert(image.url.path)
        }
        self.selectionViewController.imagesLoader.clean()
        self.selectionCollectionView.reloadData()
        
        
        // uncheck in browser if exists there (if user changed to another folder, it won't be there)
        for item in self.collectionView.visibleItems() {
            let item = item as! CollectionViewItem
            if images.contains((item.imageFile?.url.path)!) {
                item.uncheck()
            }
        }
        self.selectionCheckAllBox.state = NSButton.StateValue.off
        self.chbSelectAll.state = NSButton.StateValue.off
    }
    
    
    @IBAction func onSelectionRemoveButtonClicked(_ sender: Any) {
        // collect which to be removed from selection
        var images:[ImageFile] = [ImageFile]()
        for item in self.selectionCollectionView.visibleItems() {
            let item = item as! CollectionViewItem
            if item.isChecked() {
                images.append(item.imageFile!)
            }
        }
        // remove from selection
        for image in images {
            self.selectionViewController.imagesLoader.removeItem(image)
        }
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        
        // uncheck in browser if exists there (if user changed to another folder, it won't be there)
        for item in self.collectionView.visibleItems() {
            let item = item as! CollectionViewItem
            // TODO: change to SET<String> for performance
            let i = images.index(where: { $0.url == item.imageFile?.url })
            if i != nil {
                item.uncheck()
            }
        }
        self.selectionCheckAllBox.state = NSButton.StateValue.off
    }
    

    @IBAction func onSelectionCheckAllClicked(_ sender: NSButton) {
        
        if self.selectionViewController.imagesLoader.getItems().count == 0 {
            self.selectionCheckAllBox.state = NSButton.StateValue.off
            return
        }
        if self.selectionCheckAllBox.state == NSButton.StateValue.on {
            for i in 0...self.selectionViewController.imagesLoader.getItems().count-1 {
                let itemView = self.selectionCollectionView.item(at: i) as? CollectionViewItem
                if itemView != nil {
                    itemView!.check()
                }
            }
        }else {
            for i in 0...self.selectionViewController.imagesLoader.getItems().count-1 {
                let itemView = self.selectionCollectionView.item(at: i) as? CollectionViewItem
                if itemView != nil {
                    itemView!.uncheck()
                }
            }
        }
    }
    
    // MARK: Selection View - Batch Editor - Location Actions
    
    @IBAction func onAddressSearcherAction(_ sender: Any) {
        let address:String = addressSearcher.stringValue
        if address == "" {return}
        if self.coordinateAPI == .baidu {
            BaiduLocation.queryForCoordinate(address: address, coordinateConsumer: self)
        }else if self.coordinateAPI == .google {
            GoogleLocation.queryForCoordinate(address: address, coordinateConsumer: self)
        }
    }
    
    private func readImageLocationMeta(title:String) -> String{
        return self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Assign", title: title) ?? self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: title) ?? self.img.metaInfoHolder.getMeta(category: "Location", subCategory: "Google", title: title) ?? ""
    }
    
    // from selected image
    @IBAction func onCopyLocationFromMapClicked(_ sender: Any) {
        guard self.img != nil && self.img.location.coordinateBD != nil && self.img.location.coordinateBD!.isNotZero else {return}
        if self.possibleLocation == nil {
            self.possibleLocation = Location()
        }
        if img.location.coordinate != nil && img.location.coordinateBD != nil {
            self.possibleLocation?.setCoordinateWithoutConvert(coord: img.location.coordinate!, coordBD: img.location.coordinateBD!)
        }
        
        self.possibleLocation?.country = self.readImageLocationMeta(title: "Country")
        self.possibleLocation?.province = self.readImageLocationMeta(title: "Province")
        self.possibleLocation?.city = self.readImageLocationMeta(title: "City")
        self.possibleLocation?.district = self.readImageLocationMeta(title: "District")
        self.possibleLocation?.businessCircle = self.readImageLocationMeta(title: "BusinessCircle")
        self.possibleLocation?.street = self.readImageLocationMeta(title: "Street")
        self.possibleLocation?.address = self.readImageLocationMeta(title: "Address")
        self.possibleLocation?.addressDescription = self.readImageLocationMeta(title: "Description")
        
        //print("possible location address: \(possibleLocation?.address ?? "")")
        //print("possible location place: \(possibleLocation?.place ?? "")")
        
        
        self.addressSearcher.stringValue = ""
        
        BaiduLocation.queryForAddress(coordinateBD: img.location.coordinateBD!, locationConsumer: self, textConsumer: self.locationTextDelegate!)
        BaiduLocation.queryForMap(coordinateBD: img.location.coordinateBD!, view: webPossibleLocation, zoom: zoomSizeForPossibleAddress)
        
    }
    
    @IBAction func onReplaceLocationClicked(_ sender: Any) {
        guard self.possibleLocation != nil && self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        let location:Location = self.possibleLocation!
        for item in self.selectionViewController.imagesLoader.getItems() {
            let url:URL = item.url as URL
            let imageType = url.imageType()
            if imageType == .photo || imageType == .video {
                ExifTool.helper.patchGPSCoordinateForImage(latitude: location.latitude!, longitude: location.longitude!, url: url)
                item.assignLocation(location: location)
                
                
                let imageInSelection:ImageFile? = self.imagesLoader.getItem(path: url.path)
                if imageInSelection != nil {
                    imageInSelection!.assignLocation(location: location)
                }
                
                //print("place after assign location: \(item.place)")
                item.save()
            }
            let _ = accumulator.add()
        }
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        self.imagesLoader.reorganizeItems(considerPlaces: true)
        self.collectionView.reloadData()
        
    }
    
    // add to favourites
    @IBAction func onMarkLocationButtonClicked(_ sender: NSButton) {
        self.createPlacePopover()
        if self.possibleLocation != nil {
            self.placeViewController.setPossibleLocation(place: self.possibleLocation!)
        }
        
        let cellRect = sender.bounds
        self.placePopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    func createPlacePopover(){
        var myPopover = self.placePopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 902, height: 440))
            self.placeViewController = PlaceListViewController()
            self.placeViewController.view.frame = frame
            self.placeViewController.refreshDelegate = self
            
            myPopover!.contentViewController = self.placeViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.placePopover = myPopover
    }
    
    @IBAction func onButtonChoiceMapServiceClicked(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.coordinateAPI = .google
            locationTextDelegate?.coordinateAPI = .google
            self.btnChoiceMapService.setImage(tick, forSegment: 0)
            self.btnChoiceMapService.setImage(nil, forSegment: 1)
        }else{
            self.coordinateAPI = .baidu
            locationTextDelegate?.coordinateAPI = .baidu
            self.btnChoiceMapService.setImage(nil, forSegment: 0)
            self.btnChoiceMapService.setImage(tick, forSegment: 1)
        }
    }
    
    
    // MARK: Selection View - Batch Editor - DateTime Actions
    
    @IBAction func onReplaceDateClicked(_ sender: Any) {
        guard self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        for item:ImageFile in self.selectionViewController.imagesLoader.getItems() {
            let url:URL = item.url as URL
            
            let imageType = url.imageType()
            if imageType == .photo {
                ExifTool.helper.patchDateForPhoto(date: self.editorDatePicker.dateValue, url: url)
            }else if imageType == .video {
                ExifTool.helper.patchDateForVideo(date: self.editorDatePicker.dateValue, url: url)
            }
            item.assignDate(date: self.editorDatePicker.dateValue)
            item.save()
            
            let _ = accumulator.add()
        }
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
    }
    
    // MARK: Selection View - Batch Editor - Event Actions
    
    // add to favourites
    @IBAction func onAddEventButtonClicked(_ sender: NSButton) {
        self.createEventPopover()
        
        let cellRect = sender.bounds
        self.eventPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    @IBAction func onAssignEventButtonClicked(_ sender: Any) {
        print("CLICKED ASSIGN EVENT BUTTON")
        print(self.selectionViewController.imagesLoader.getItems().count)
        print(self.comboEventList.stringValue)
        guard self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        guard self.comboEventList.stringValue != "" else {return}
        
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil, onCompleted:{ data in
            //self.refreshCollection()
            
            self.imagesLoader.reorganizeItems(considerPlaces: true)
            self.collectionView.reloadData()
            
            self.refreshTree()
        })
        accumulator.reset()
        
        var event:ImageEvent? = nil
        for ev in self.eventListController.events {
            if ev.name == self.comboEventList.stringValue {
                event = ev
                break
            }
        }
        if let event = event {
            //print("PREPARE TO ASSIGN EVENT \(event.name)")
            for item:ImageFile in self.selectionViewController.imagesLoader.getItems() {
                let url:URL = item.url as URL
                let imageType = url.imageType()
                if imageType == .photo || imageType == .video {
                    //print("assigning event: \(event.name)")
                    item.assignEvent(event: event)
                    //ExifTool.helper.assignKeyValueForImage(key: "Event", value: "some event", url: url)
                    item.save()
                }
                let _ = accumulator.add()
            }
        }
    }
    
    func createEventPopover(){
        var myPopover = self.eventPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 600, height: 400))
            self.eventViewController = EventListViewController()
            self.eventViewController.view.frame = frame
            self.eventViewController.refreshDelegate = self
            
            myPopover!.contentViewController = self.eventViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.eventPopover = myPopover
    }
    
    // MARK: Selection View - Batch Editor - Show/Hide Controls
    
    @IBAction func onButtonHideClicked(_ sender: Any) {
        guard self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        for item:ImageFile in self.selectionViewController.imagesLoader.getItems() {
            item.hide()
            let _ = accumulator.add()
        }
        //ModelStore.save()
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        self.imagesLoader.reorganizeItems()
        self.collectionView.reloadData()
    }
    
    @IBAction func onButtonShowClicked(_ sender: Any) {
        guard self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        for item:ImageFile in self.selectionViewController.imagesLoader.getItems() {
            item.show()
            let _ = accumulator.add()
        }
        //ModelStore.save()
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        self.imagesLoader.reorganizeItems()
        self.collectionView.reloadData()
    }
    
    // MARK: Common Dialog
    
    private func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
}

extension ViewController : EventListRefreshDelegate{
    
    func setupEventList() {
        if self.eventListController == nil {
            self.eventListController = EventListComboController()
            self.comboEventList.dataSource = self.eventListController
            self.comboEventList.delegate = self.eventListController
        }
        self.refreshEventList()
    }
    
    func refreshEventList() {
        self.eventListController.loadEvents()
        self.comboEventList.reloadData()
    }
    
    func selectEvent(name: String) {
        self.comboEventList.stringValue = name
    }
}

class EventListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var events:[ImageEvent] = []
    
    func loadEvents() {
        self.events = ModelStore.default.getEvents()
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        
        //print("SubString = \(string)")
        
        for event in events {
            let state = event.name
            // substring must have less characters then stings to search
            if string.count < state.count{
                // only use first part of the strings in the list with length of the search string
                let statePartialStr = state.lowercased()[state.lowercased().startIndex..<state.lowercased().index(state.lowercased().startIndex, offsetBy: string.count)]
                if statePartialStr.range(of: string.lowercased()) != nil {
                    //print("SubString Match = \(state)")
                    return state
                }
            }
        }
        return ""
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return(events.count)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return(events[index].name as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        for event in events {
            let str = event.name
            if str == string{
                return i
            }
            i += 1
        }
        return -1
    }
}

extension ViewController : PlaceListRefreshDelegate{
    
    func setupPlaceList() {
        if self.placeListController == nil {
            self.placeListController = PlaceListComboController()
            self.placeListController.combobox = self.comboPlaceList
            self.placeListController.refreshDelegate = self
            self.comboPlaceList.dataSource = self.placeListController
            self.comboPlaceList.delegate = self.placeListController
        }
        self.refreshPlaceList()
    }
    
    func refreshPlaceList() {
        self.placeListController.loadPlaces()
        self.comboPlaceList.reloadData()
    }
    
    func selectPlace(name: String, location:Location) {
        self.placeListController.working = true
        self.comboPlaceList.stringValue = name
        self.possibleLocation = location
        self.possibleLocation?.place = name
        self.possibleLocationText.stringValue = name
        BaiduLocation.queryForMap(coordinateBD: location.coordinateBD!, view: webPossibleLocation, zoom: zoomSizeForPossibleAddress)
        self.placeListController.working = false
        
    }
}

class PlaceListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var places:[ImagePlace] = []
    var refreshDelegate:PlaceListRefreshDelegate?
    var combobox:NSComboBox?
    var working:Bool = false
    
    func loadPlaces() {
        self.places = ModelStore.default.getPlaces()
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        
        //print("SubString = \(string)")
        
        for place in places {
            let state = place.name
            // substring must have less characters then stings to search
            if string.count < state.count{
                // only use first part of the strings in the list with length of the search string
                let statePartialStr = state.lowercased()[state.lowercased().startIndex..<state.lowercased().index(state.lowercased().startIndex, offsetBy: string.count)]
                if statePartialStr.range(of: string.lowercased()) != nil {
                    //print("SubString Match = \(state)")
                    return state
                }
            }
        }
        return ""
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if combobox == nil || working {return}
        let name = places[combobox!.indexOfSelectedItem].name
        let place:ImagePlace? = ModelStore.default.getPlace(name: name)
        if place != nil {
            let location = Location()
            location.country = place?.country ?? ""
            location.province = place?.province ?? ""
            location.city = place?.city ?? ""
            location.district = place?.district ?? ""
            location.street = place?.street ?? ""
            location.businessCircle = place?.businessCircle ?? ""
            location.address = place?.address ?? ""
            location.addressDescription = place?.addressDescription ?? ""
            location.place = place?.name ?? ""
            location.coordinate = Coord(latitude: Double(place?.latitude ?? "0")!, longitude: Double(place?.longitude ?? "0")!)
            location.coordinateBD = Coord(latitude: Double(place?.latitudeBD ?? "0")!, longitude: Double(place?.longitudeBD ?? "0")!)
            
            if refreshDelegate != nil {
                refreshDelegate?.selectPlace(name: name, location: location)
            }
        }
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return(places.count)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return(places[index].name as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        for place in places {
            let str = place.name
            if str == string{
                return i
            }
            i += 1
        }
        return -1
    }
    
    
}

// MARK: WINDOW CONTROLLER
extension ViewController : NSWindowDelegate {
    
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }
}






