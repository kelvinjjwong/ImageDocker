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
    
    var notificationPopover:NSPopover?
    var notificationViewController:NotificationViewController!
    
    // MARK: Image preview
    var img:ImageFile!
    @IBOutlet weak var playerContainer: NSView!
    var stackedImageViewController : StackedImageViewController!
    var stackedVideoViewController : StackedVideoViewController!
    
    // MARK: MetaInfo table view
    //var metaInfo:[MetaInfo] = [MetaInfo]()
    var lastSelectedMetaInfoRow: Int?
    @IBOutlet weak var metaInfoTableView: NSTableView!
    
    @IBOutlet weak var lblImageDescription: NSTextField!
    
    
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
    
    @IBOutlet weak var treeIndicator: NSLevelIndicator!
    

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
    
    
    @IBOutlet weak var chbExport: NSButton!
    @IBOutlet weak var chbScan: NSButton!
    @IBOutlet weak var chbSelectAll: NSButton!
    
    
    // MARK: Collection View for browsing
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var collectionProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var indicatorMessage: NSTextField!
    @IBOutlet weak var btnRefreshCollectionView: NSButton!
    @IBOutlet weak var btnCombineDuplicates: NSPopUpButton!
    
    
    @IBOutlet weak var chbShowHidden: NSButton!
    
    let imagesLoader = CollectionViewItemsLoader()
    var collectionLoadingIndicator:Accumulator?
    
    // MARK: SELECTION VIEW
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
    
    // MARK: SELECTION BATCH EDITOR TOOLBAR - SWITCHER
    
    @IBOutlet weak var btnBatchEditorToolbarSwitcher: NSButton!
    
    
    // MARK: SELECTION BATCH EDITOR - DateTime
    
    @IBOutlet weak var batchEditIndicator: NSProgressIndicator!
    @IBOutlet weak var btnDatePicker: NSButton!
    
    @IBOutlet weak var btnNotes: NSButton!
    @IBOutlet weak var btnDuplicates: NSPopUpButton!
    
    // MARK: SELECTION BATCH EDITOR - EVENT & PLACE
    
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
    
    // MARK: Theater Dialog
    var theaterWindowController:NSWindowController!
    
    // MARK: Concurrency Indicators
    
    var scaningRepositories:Bool = false
    var creatingRepository:Bool = false
    var suppressedExport:Bool = false
    var suppressedScan:Bool = false
    
    // MARK: init
    
    var windowInitial:Bool = false
    var smallScreen:Bool = false
    
    func resize() {
        guard !windowInitial else {return}
        let size = UIHelper.windowSize()
        
        let windowSize = NSMakeSize(size.width, size.height)
        let windowMinSize = NSMakeSize(CGFloat(600), CGFloat(500))
        let windowMaxSize = NSMakeSize(size.widthMax, size.heightMax - CGFloat(5))
        
        var windowFrame = self.view.window?.frame
        windowFrame?.size = windowSize
        windowFrame?.origin = size.originPoint
        self.view.window?.maxSize = windowMaxSize
        self.view.window?.minSize = windowMinSize
        self.view.window?.setFrame(windowFrame!, display: true)
        
        smallScreen = size.isSmallScreen
        
        if size.isSmallScreen {
            self.hideSelectionBatchEditors()
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: .goRightTemplate)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Show event/datetime selectors"
            
            let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 258)
            self.playerContainer.addConstraint(constraintPlayerHeight)
            self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(258)))
            self.playerContainer.display()
            
            self.splitviewPreview.setPosition(size.height - CGFloat(520), ofDividerAt: 0)
        }else {
            print("BIG SCREEN")
            let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 408)
            self.playerContainer.addConstraint(constraintPlayerHeight)
            self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(408)))
            self.playerContainer.display()
            
            self.splitviewPreview.setPosition(size.height - CGFloat(670), ofDividerAt: 0)
        }
        
        windowInitial = true
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
        self.resize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnShare.sendAction(on: .leftMouseDown)
        self.btnCombineDuplicates.toolTip = "Combine duplicated images to the 1st image"
        
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
        
        self.theaterWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "TheaterWindowController")) as! NSWindowController
        
        
        self.btnChoiceMapService.selectSegment(withTag: 1)
        self.coordinateAPI = .baidu
        
        self.btnChoiceMapService.setImage(nil, forSegment: 0)
        self.btnChoiceMapService.setImage(tick, forSegment: 1)
        
        self.chbScan.state = NSButton.StateValue.off
        self.suppressedScan = true
        self.btnScanState.image = NSImage(named: NSImage.Name.statusNone)
        self.btnScanState.isHidden = true
        
        self.chbExport.state = NSButton.StateValue.off
        ExportManager.default.messageBox = self.indicatorMessage
        ExportManager.default.suppressed = true
        self.suppressedExport = true
        self.lastExportPhotos = Date()
        
        self.scanLocationChangeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
            guard !ExportManager.default.working && !self.scaningRepositories && !self.creatingRepository && !self.treeRefreshing else {return}
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
            guard !ExportManager.default.working && !self.scaningRepositories && !self.creatingRepository && !self.treeRefreshing else {return}
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
            guard !ExportManager.default.working && !self.scaningRepositories && !self.creatingRepository && !self.treeRefreshing else {return}
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
            print("\(Date()) TRYING TO EXPORT \(self.suppressedExport) \(ExportManager.default.suppressed) \(ExportManager.default.working)")
            guard !self.suppressedExport && !ExportManager.default.suppressed && !ExportManager.default.working else {return}
            print("\(Date()) EXPORTING")
            DispatchQueue.global().async {
                ExportManager.default.export(after: self.lastExportPhotos!)
                self.lastExportPhotos = Date()
            }
        })
        
        self.scanRepositoriesTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true, block:{_ in
            print("\(Date()) TRY TO SCAN REPOS")
            guard !self.suppressedScan && !ExportManager.default.working && !self.scaningRepositories && !self.creatingRepository else {return}
            print("\(Date()) SCANING REPOS")
            self.startScanRepositories()
        })
        
        self.scanPhotosToLoadExifTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block:{_ in
            print("\(Date()) TRY TO SCAN PHOTO TO LOAD EXIF")
            guard !self.suppressedScan && !ExportManager.default.working && !self.scaningRepositories && !self.creatingRepository else {return}
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
        self.btnReplaceLocation.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRemoveRepository.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRefreshRepository.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnFilterRepository.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRefreshCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnCombineDuplicates.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.comboEventList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboEventList.backgroundColor = NSColor.darkGray
        self.comboPlaceList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboPlaceList.backgroundColor = NSColor.darkGray
        self.addressSearcher.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.addressSearcher.backgroundColor = NSColor.darkGray
        self.addressSearcher.drawsBackground = true
        self.btnChoiceMapService.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.btnBatchEditorToolbarSwitcher.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.selectionCheckAllBox.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.chbExport.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.chbScan.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.chbShowHidden.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.btnShow.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnHide.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.sourceList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.metaInfoTableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.collectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.selectionCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.playerContainer.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        
    }
    
    // init trees
    func configureTree(){
        self.sourceList.backgroundColor = NSColor.darkGray
        
        self.hideToolbarOfTree()
        self.hideToolbarOfCollectionView()
        self.treeIndicator.isEnabled = true
        self.treeIndicator.isHidden = false
        DispatchQueue.global().async {
            
            self.initTreeDataModel()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 1.0
            }
            print("\(Date()) Loading view - configure tree - loading path to tree from db")
            self.loadPathToTreeFromDatabase()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 2.0
            }
            print("\(Date()) Loading view - configure tree - loading moments to tree from db")
            self.loadMomentsToTreeFromDatabase()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 3.0
            }
            print("\(Date()) Loading view - configure tree - loading places to tree from db")
            self.loadPlacesToTreeFromDatabase()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 4.0
            }
            print("\(Date()) Loading view - configure tree - loading events to tree from db")
            self.loadEventsToTreeFromDatabase()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 5.0
            }
            
            print("\(Date()) Loading view - configure tree - reloading tree view")
            DispatchQueue.main.async {
                self.sourceList.reloadData()
                self.treeIndicator.isEnabled = false
                self.treeIndicator.isHidden = true
                
                self.showToolbarOfTree()
                self.showToolbarOfCollectionView()
            }
        }
    }
    
    fileprivate func hideToolbarOfTree() {
        self.chbScan.isHidden = true
        self.btnAddRepository.isHidden = true
        self.btnRemoveRepository.isHidden = true
        self.btnRefreshRepository.isHidden = true
        self.btnFilterRepository.isHidden = true
    }
    
    fileprivate func hideToolbarOfCollectionView() {
        self.chbExport.isHidden = true
        self.btnRefreshCollectionView.isHidden = true
        self.btnCombineDuplicates.isHidden = true
        self.chbSelectAll.isHidden = true
        self.chbShowHidden.isHidden = true
    }
    
    fileprivate func showToolbarOfTree() {
        self.chbScan.isHidden = false
        self.btnAddRepository.isHidden = false
        self.btnRemoveRepository.isHidden = false
        self.btnRefreshRepository.isHidden = false
        self.btnFilterRepository.isHidden = false
    }
    
    fileprivate func showToolbarOfCollectionView() {
        self.chbExport.isHidden = false
        self.btnRefreshCollectionView.isHidden = false
        self.btnCombineDuplicates.isHidden = false
        self.chbSelectAll.isHidden = false
        self.chbShowHidden.isHidden = false
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
        selectionViewController.onItemClicked = { image in
            self.selectImageFile(image)
        }
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
        
        
        if let image = self.img.imageData {
            self.lblImageDescription.stringValue = """
\(image.shortDescription ?? "")
\(image.longDescription ?? "")
"""
        }
    }
    
    private func loadImage(imageFile:ImageFile){
        self.img = imageFile
        self.previewImage(image: img)
        //self.img.transformDomainToMetaInfo()
        img.metaInfoHolder.sort(by: MetaCategorySequence)
        self.metaInfoTableView.reloadData()
        self.loadBaiduMap()
        
        if let image = self.img.imageData {
            self.lblImageDescription.stringValue = """
\(image.shortDescription ?? "")
\(image.longDescription ?? "")
"""
        }
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
    
    var editRepositoryPopover:NSPopover? = nil
    var editRepositoryViewController:EditRepositoryViewController!
    
    func createEditRepositoryPopover(){
        var myPopover = self.editRepositoryPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 480, height: 280))
            self.editRepositoryViewController = EditRepositoryViewController()
            self.editRepositoryViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.editRepositoryViewController
            myPopover!.appearance = NSAppearance(named: .aqua)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.editRepositoryPopover = myPopover
    }
    
    @IBAction func onAddButtonClicked(_ sender: NSButton) {
        let window = NSApplication.shared.windows.first
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        
        openPanel.beginSheetModal(for: window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let url = openPanel.url {
                
                self.createEditRepositoryPopover()
                
                let cellRect = sender.bounds
                self.editRepositoryPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
                self.editRepositoryViewController.edit(url: url, onOK: {
                    
                    ////self.creatingRepository = true
                    ////DispatchQueue.main.async {
                    ////self.loadPathToTree(path)
                    
                    //ImageFolderTreeScanner.createRepository(path: url.path)
                    self.updateLibraryTree()
                    
                    ////self.sourceList.reloadData()
                    ////}
                })
            }
        }
    }
    
    @IBAction func onDelButtonClicked(_ sender: Any) {
        print("clicked delete button")
        if self.selectedImageFolder != nil {
            if(self.selectedImageFolder?.containerFolder?.parentFolder == ""){
                if Alert.dialogOKCancel(question: "Remove all photos relate to this folder ?", text: selectedImageFolder!.url.path) {
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
                    
                    
                    self.hideToolbarOfTree()
                    self.hideToolbarOfCollectionView()
                    self.treeIndicator.doubleValue = 0.0
                    self.treeIndicator.isHidden = false
                    self.treeIndicator.isEnabled = true
                    
                    DispatchQueue.global().async {
                        self.saveTreeItemsExpandState()
                        DispatchQueue.main.async {
                            self.treeIndicator.doubleValue = 1.0
                        }
                        self.refreshMomentTree()
                        DispatchQueue.main.async {
                            self.treeIndicator.doubleValue = 2.0
                        }
                        self.refreshLocationTree()
                        DispatchQueue.main.async {
                            self.treeIndicator.doubleValue = 3.0
                        }
                        
                        DispatchQueue.main.async {
                            self.restoreTreeItemsExpandState()
                            self.treeIndicator.doubleValue = 4.0
                            self.restoreTreeSelection()
                            self.treeIndicator.doubleValue = 5.0
                            
                            self.treeIndicator.isHidden = true
                            self.treeIndicator.isEnabled = false
                            
                            self.showToolbarOfTree()
                            self.showToolbarOfCollectionView()
                        }
                    }
                }
            }
        }
    }
    
    func refreshTree(fast:Bool = true) {
        
        DispatchQueue.main.async {
            self.hideToolbarOfTree()
            self.hideToolbarOfCollectionView()
            
            self.treeIndicator.doubleValue = 0.0
            self.treeIndicator.isHidden = false
            self.treeIndicator.isEnabled = true
        }
        DispatchQueue.global().async {
            
            self.saveTreeItemsExpandState()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 1.0
            }
            
            self.refreshLibraryTree(fast: fast)
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 2.0
            }
            self.refreshMomentTree()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 3.0
            }
            self.refreshLocationTree()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 4.0
            }
            self.refreshEventTree()
            DispatchQueue.main.async {
                self.treeIndicator.doubleValue = 5.0
            }
            
            DispatchQueue.main.async {
                self.restoreTreeItemsExpandState()
                self.restoreTreeSelection()
                
                self.treeIndicator.isHidden = true
                self.treeIndicator.isEnabled = false
                
                self.showToolbarOfTree()
                self.showToolbarOfCollectionView()
            }
        }
    }
    
    @IBAction func onRefreshButtonClicked(_ sender: Any) {
        print("clicked refresh button")
        
        self.hideToolbarOfTree()
        self.hideToolbarOfCollectionView()
        
        self.treeIndicator.doubleValue = 0.0
        self.treeIndicator.isHidden = false
        self.treeIndicator.isEnabled = true
        DispatchQueue.global().async {
            ModelStore.default.reloadDuplicatePhotos()
            self.refreshTree(fast: false)
        }
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
                ImageFolderTreeScanner.scanPhotosToLoadExif(indicator: self.treeLoadingIndicator)
            }
        }
    }
    
    // MARK: Collection View Controls
    
    func disableCollectionViewControls() {
        self.chbExport.isEnabled = false
        self.btnRefreshCollectionView.isEnabled = false
        self.chbSelectAll.isEnabled = false
        self.chbShowHidden.isEnabled = false
        self.btnCombineDuplicates.isEnabled = false
    }
    
    
    func enableCollectionViewControls() {
        self.chbExport.isEnabled = true
        self.btnRefreshCollectionView.isEnabled = true
        self.chbSelectAll.isEnabled = true
        self.chbShowHidden.isEnabled = true
        self.btnCombineDuplicates.isEnabled = true
    }
    
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
    
    fileprivate func combineDuplicatesInCollectionView() {
        guard self.imagesLoader.getItems().count > 0 else {
            Alert.noImageSelected()
            return
        }
        
        self.disableCollectionViewControls()
        
        let accumulator:Accumulator = Accumulator(target: self.imagesLoader.getItems().count, indicator: self.collectionProgressIndicator, suspended: false, lblMessage: nil)
        
        DispatchQueue.global().async {
            
            for image in self.imagesLoader.getItems() {
                if image.hasDuplicates {
                    if let list = ModelStore.default.getDuplicatePhotos().keyToPath[image.duplicatesKey] {
                        if image.url.path == list[0] {
                            //print("\(image.duplicatesKey) MAJOR \(image.url.path)")
                            ModelStore.default.markImageDuplicated(path: image.url.path, duplicatesKey: image.duplicatesKey, hide: false)
                        }else{
                            //print("\(image.duplicatesKey) SLAVE \(image.url.path)")
                            ModelStore.default.markImageDuplicated(path: image.url.path, duplicatesKey: image.duplicatesKey, hide: true)
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    let _ = accumulator.add()
                }
            }
            
            self.imagesLoader.reload()
            self.imagesLoader.reorganizeItems()
            
            DispatchQueue.main.async {
                self.enableCollectionViewControls()
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func combineDuplicatesInAllLibraries() {
        self.disableCollectionViewControls()
        
        let accumulator:Accumulator = Accumulator(target: ModelStore.default.getDuplicatePhotos().keyToPath.keys.count, indicator: self.collectionProgressIndicator, suspended: false, lblMessage: self.indicatorMessage)
        
        DispatchQueue.global().async {
            
            for key in ModelStore.default.getDuplicatePhotos().keyToPath.keys {
                if let list = ModelStore.default.getDuplicatePhotos().keyToPath[key] {
                    
                    for i in 0..<list.count {
                        let path = list[i]
                        if i == 0 {
                            ModelStore.default.markImageDuplicated(path: path, duplicatesKey: key, hide: false)
                        }else{
                            ModelStore.default.markImageDuplicated(path: path, duplicatesKey: key, hide: true)
                        }
                    }
                }
                DispatchQueue.main.async {
                    let _ = accumulator.add("Combining duplicated images ...")
                }
            }
            
            if self.imagesLoader.getItems().count > 0 {
                self.imagesLoader.reload()
                self.imagesLoader.reorganizeItems()
                
                DispatchQueue.main.async {
                    self.enableCollectionViewControls()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func onCombineDuplicatesButtonClicked(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        if i == 1 {
            self.combineDuplicatesInCollectionView()
        }else if i == 2 {
            self.combineDuplicatesInAllLibraries()
        }
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
    
    // MARK: COLLECTION VIEW - EXPORT
    
    @IBAction func onCheckExportClicked(_ sender: NSButton) {
        if PreferencesController.exportDirectory() == "" {
            self.chbExport.state = .off
            Alert.invalidExportPath()
            return
        }
        if self.chbExport.state == NSButton.StateValue.on {
            print("enabled export")
            self.suppressedExport = false
            ExportManager.default.suppressed = false
            
            // start exporting immediatetly
            if !ExportManager.default.working {
                DispatchQueue.global().async {
                    ExportManager.default.export(after: self.lastExportPhotos!)
                    self.lastExportPhotos = Date()
                }
            }
            //ExportManager.enable()
        }else {
            print("disabled export")
            self.suppressedExport = true
            ExportManager.default.suppressed = true
            //ExportManager.disable()
        }
    }
    
    fileprivate func hideSelectionToolbar() {
        self.btnShare.isHidden = true
        self.btnCopyToDevice.isHidden = true
        self.btnShow.isHidden = true
        self.btnHide.isHidden = true
        self.selectionCheckAllBox.isHidden = true
        self.btnRemoveSelection.isHidden = true
        self.btnRemoveAllSelection.isHidden = true
    }
    
    fileprivate func showSelectionToolbar() {
        self.btnShare.isHidden = false
        self.btnCopyToDevice.isHidden = false
        self.btnShow.isHidden = false
        self.btnHide.isHidden = false
        self.selectionCheckAllBox.isHidden = false
        self.btnRemoveSelection.isHidden = false
        self.btnRemoveAllSelection.isHidden = false
        
    }
    
    fileprivate func hideSelectionBatchEditors() {
        self.comboEventList.isHidden = true
        self.btnAssignEvent.isHidden = true
        self.btnManageEvents.isHidden = true
        self.btnDatePicker.isHidden = true
        self.btnNotes.isHidden = true
        self.btnDuplicates.isHidden = true
    }
    
    fileprivate func showSelectionBatchEditors() {
        self.comboEventList.isHidden = false
        self.btnAssignEvent.isHidden = false
        self.btnManageEvents.isHidden = false
        self.btnDatePicker.isHidden = false
        self.btnNotes.isHidden = false
        self.btnDuplicates.isHidden = false
    }
    
    // MARK: SELECTION BATCH EDITOR TOOLBAR - SWITCHER
    
    @IBAction func onBatchEditorToolbarSwitcherClicked(_ sender: NSButton) {
        if self.btnBatchEditorToolbarSwitcher.image == NSImage(named: NSImage.Name.goLeftTemplate) {
            self.hideSelectionBatchEditors()
            if smallScreen {
                self.showSelectionToolbar()
            }
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.Name.goRightTemplate)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Show event/datetime selectors"
        } else {
            self.showSelectionBatchEditors()
            if smallScreen {
                self.hideSelectionToolbar()
            }
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.Name.goLeftTemplate)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Hide event/datetime selectors"
        }
    }
    
    
    // MARK: SELECTION TOOLBAR
    
    @IBAction func onShareClicked(_ sender: NSButton) {
        let images = self.selectionViewController.imagesLoader.getItems()
        if images.count == 0 {
            Alert.noImageSelected()
            return
        }
        var nsImages:[NSImage] = []
        for image in images {
            if let nsImage = image.loadNSImage() {
                nsImages.append(nsImage)
            }
        }
        if nsImages.count == 0 {
            Alert.noImageSelected()
            return
        }
        let sharingPicker = NSSharingServicePicker.init(items: nsImages)
        sharingPicker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        
    }
    
    
    @IBAction func onCopyToDeviceClicked(_ sender: NSButton) {
        let images = self.selectionViewController.imagesLoader.getItems()
        let devices = Android.bridge.devices()
        if images.count == 0 {
            Alert.noImageSelected()
            return
        }
        if devices.count == 0 {
            Alert.noAndroidDeviceFound()
            return
        }
        self.createCopyToDevicePopover(images: images)
        let cellRect = sender.bounds
        self.copyToDevicePopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    fileprivate var copyToDevicePopover:NSPopover? = nil
    fileprivate var deviceFolderViewController:DeviceFolderViewController!
    
    fileprivate func createCopyToDevicePopover(images:[ImageFile]){
        var myPopover = self.copyToDevicePopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 800, height: 550))
            self.deviceFolderViewController = DeviceFolderViewController(images: images)
            self.deviceFolderViewController.view.frame = frame
            
            myPopover!.contentViewController = self.deviceFolderViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.aqua)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }else{
            self.deviceFolderViewController.reinit(images)
        }
        self.copyToDevicePopover = myPopover
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
        self.comboPlaceList.stringValue = ""
        self.comboPlaceList.deselectItem(at: self.comboPlaceList.indexOfSelectedItem)
        
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
    
    
    // MARK: Selection View - Batch Editor - Duplicates
    
    fileprivate func markCheckedImageAsDuplicatedChief() {
        let items = self.selectionViewController.imagesLoader.getItems()
        if items.count == 0 {
            Alert.noImageSelected()
            return
        }
        let checked = self.selectionViewController.imagesLoader.getCheckedItems()
        if checked.count != 1 {
            Alert.checkOneImage()
            return
        }
        let imageFile = checked[0]
        if let image = ModelStore.default.getImage(path: imageFile.url.path), let duplicatesKey = image.duplicatesKey {
            if let paths = ModelStore.default.getDuplicatePhotos().keyToPath[duplicatesKey] {
                for path in paths {
                    if path == imageFile.url.path {
                        print("to be changed: show - \(path)")
                        ModelStore.default.markImageDuplicated(path: path, duplicatesKey: duplicatesKey, hide: false)
                    }else{
                        print("to be changed: hide - \(path)")
                        ModelStore.default.markImageDuplicated(path: path, duplicatesKey: duplicatesKey, hide: true)
                    }
                }
                self.selectionViewController.imagesLoader.reload()
                self.selectionViewController.imagesLoader.reorganizeItems()
                self.selectionCollectionView.reloadData()
                
                self.imagesLoader.reload()
                self.imagesLoader.reorganizeItems()
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func decoupleCheckedImages() {
        let items = self.selectionViewController.imagesLoader.getItems()
        if items.count == 0 {
            Alert.noImageSelected()
            return
        }
        let checked = self.selectionViewController.imagesLoader.getCheckedItems()
        if checked.count == 0 {
            Alert.checkImages()
            return
        }
        for imageFile in checked {
            ModelStore.default.markImageDuplicated(path: imageFile.url.path, duplicatesKey: nil, hide: false)
        }
        self.selectionViewController.imagesLoader.reload()
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        
        self.imagesLoader.reload()
        self.imagesLoader.reorganizeItems()
        self.collectionView.reloadData()
    }
    
    fileprivate func combineCheckedImages() {
        let items = self.selectionViewController.imagesLoader.getItems()
        if items.count == 0 {
            Alert.noImageSelected()
            return
        }
        let checked = self.selectionViewController.imagesLoader.getCheckedItems()
        if checked.count == 0 {
            Alert.checkImages()
            return
        }
        let first = checked[0]
        
        if let image = ModelStore.default.getImage(path: first.url.path), let date = image.photoTakenDate {
            let oldKey = image.duplicatesKey ?? ""
            
            // generate new key
            let place = image.place ?? image.assignPlace ?? image.suggestPlace ?? ""
            let year = Calendar.current.component(.year, from: date)
            let month = Calendar.current.component(.month, from: date)
            let day = Calendar.current.component(.day, from: date)
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            let second = Calendar.current.component(.second, from: date)
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyyMMddHHmmss"
            let now = dateFormat.string(from: Date())
            
            let key = "\(place)_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)_\(now)"
            
            // update images
            for imageFile in checked {
                if imageFile.url.path == first.url.path {
                    ModelStore.default.markImageDuplicated(path: imageFile.url.path, duplicatesKey: key, hide: false)
                }else{
                    ModelStore.default.markImageDuplicated(path: imageFile.url.path, duplicatesKey: key, hide: true)
                }
                ModelStore.default.getDuplicatePhotos().updateMapping(key: key, path: imageFile.url.path)
            }
            
            // health check for the original duplicated set (if exists)
            if oldKey != "" {
                let chiefOfOldKey = ModelStore.default.getChiefImageOfDuplicatedSet(duplicatesKey: oldKey)
                if chiefOfOldKey == nil {
                    if let firstOfOldKey = ModelStore.default.getFirstImageOfDuplicatedSet(duplicatesKey: oldKey) {
                        ModelStore.default.markImageDuplicated(path: firstOfOldKey.path, duplicatesKey: oldKey, hide: false)
                    }
                }
            }
            
            // refresh UI
            self.selectionViewController.imagesLoader.reload()
            self.selectionViewController.imagesLoader.reorganizeItems()
            self.selectionCollectionView.reloadData()
            
            self.imagesLoader.reload()
            self.imagesLoader.reorganizeItems()
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func combineSelectedImages(checkedAsChief:Bool) {
        let items = self.selectionViewController.imagesLoader.getItems()
        if items.count == 0 {
            Alert.noImageSelected()
            return
        }
        var major = items[0]
        if checkedAsChief {
            let checked = self.selectionViewController.imagesLoader.getCheckedItems()
            if checked.count == 0 {
                Alert.checkOneImage()
                return
            }
            major = checked[0]
        }
        if let image = major.imageData, let date = image.photoTakenDate {
            let place = image.place ?? image.assignPlace ?? image.suggestPlace ?? ""
            let year = Calendar.current.component(.year, from: date)
            let month = Calendar.current.component(.month, from: date)
            let day = Calendar.current.component(.day, from: date)
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            let second = Calendar.current.component(.second, from: date)
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyyMMddHHmmss"
            let now = dateFormat.string(from: Date())
            
            let key = "\(place)_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)_\(now)"
            for imageFile in items {
                if imageFile.url.path == major.url.path {
                    ModelStore.default.markImageDuplicated(path: imageFile.url.path, duplicatesKey: key, hide: false)
                }else{
                    ModelStore.default.markImageDuplicated(path: imageFile.url.path, duplicatesKey: key, hide: true)
                }
                ModelStore.default.getDuplicatePhotos().updateMapping(key: key, path: imageFile.url.path)
            }
            self.selectionViewController.imagesLoader.reload()
            self.selectionViewController.imagesLoader.reorganizeItems()
            self.selectionCollectionView.reloadData()
            
            self.imagesLoader.reload()
            self.imagesLoader.reorganizeItems()
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func onButtonDuplicatesClicked(_ sender: NSPopUpButton) {
        self.btnDuplicates.isEnabled = false
        let i = sender.indexOfSelectedItem
        
        if i == 1 {
            self.markCheckedImageAsDuplicatedChief()
        }else if i == 2 {
            self.decoupleCheckedImages()
        }else if i == 3 {
            self.combineCheckedImages()
        }else if i == 4 {
            self.combineSelectedImages(checkedAsChief: false)
        }else if i == 5 {
            self.combineSelectedImages(checkedAsChief: true)
        }
        self.btnDuplicates.isEnabled = true
    }
    
    // MARK: Selection View - Batch Editor - Notes
    
    
    @IBAction func onButtonNotesClicked(_ sender: NSButton) {
        if self.selectionViewController.imagesLoader.getItems().count == 0 {
            Alert.noImageSelected()
            return
        }
        self.createNotesPopover()
        
        let cellRect = sender.bounds
        self.notesPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
        self.notesViewController.loadFrom(images: self.selectionViewController.imagesLoader.getItems(),
                                             onApplyChanges: {
                                                self.selectionViewController.imagesLoader.reload()
                                                self.selectionViewController.imagesLoader.reorganizeItems()
                                                self.selectionCollectionView.reloadData()
                                                
                                                self.imagesLoader.reload()
                                                self.imagesLoader.reorganizeItems()
                                                self.collectionView.reloadData()
        })
    }
    
    
    var notesPopover:NSPopover? = nil
    var notesViewController:NotesViewController!
    
    func createNotesPopover(){
        var myPopover = self.notesPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 480, height: 280))
            self.notesViewController = NotesViewController()
            self.notesViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.notesViewController
            myPopover!.appearance = NSAppearance(named: .aqua)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.notesPopover = myPopover
    }
    
    // MARK: Selection View - Batch Editor - Date
    
    @IBAction func onButtonDatePickerClicked(_ sender: NSButton) {
        if self.selectionViewController.imagesLoader.getItems().count == 0 {
            Alert.noImageSelected()
            return
        }
        self.createCalenderPopover()
        
        let cellRect = sender.bounds
        self.calendarPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
        self.calendarViewController.loadFrom(images: self.selectionViewController.imagesLoader.getItems(),
                                             onApplyChanges: {
                                                    self.selectionViewController.imagesLoader.reload()
                                                    self.selectionViewController.imagesLoader.reorganizeItems()
                                                    self.selectionCollectionView.reloadData()
                                                },
                                             onClose: {
                                                self.calendarPopover?.close()
        })
    }
    
    
    var calendarPopover:NSPopover? = nil
    var calendarViewController:DateTimeViewController!
    
    func createCalenderPopover(){
        var myPopover = self.calendarPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1200, height: 650))
            self.calendarViewController = DateTimeViewController()
            self.calendarViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.calendarViewController
            myPopover!.appearance = NSAppearance(named: .aqua)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.applicationDefined
        }
        self.calendarPopover = myPopover
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
        if combobox!.indexOfSelectedItem < 0 || combobox!.indexOfSelectedItem >= places.count {return}
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

extension ViewController : LunarCalendarViewDelegate {
    @objc func didSelectDate(_ selectedDate: Date) {
        print(selectedDate)
    }
}


