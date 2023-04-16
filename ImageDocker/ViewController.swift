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
    
    let logger = ConsoleLogger(category: "MAIN", subCategory: "VIEW", includeTypes: [])
    
    var childWindows:[String:NSWindow] = [:]
    
    // MARK: Main Menu
    
    
    // MARK: Icon
    let tick:NSImage = NSImage.init(named: NSImage.menuOnStateTemplateName)!
    
    // MARK: TOP BAR
    @IBOutlet weak var btnAlertMessage: NSButton!
    
    @IBOutlet weak var btnExport: NSPopUpButton!
    @IBOutlet weak var btnFaces: NSPopUpButton!
    @IBOutlet weak var btnTasks: NSButton!
    @IBOutlet weak var btnMemories: NSButton!
    
    @IBOutlet weak var btnNotification: NSButton!
    @IBOutlet weak var txtSearch: NSTokenField!
    
    
    @IBOutlet weak var btnToggleLeftPanel: NSButton!
    @IBOutlet weak var btnToggleBottomPanel: NSButton!
    @IBOutlet weak var btnToggleRightPanel: NSButton!
    @IBOutlet weak var btnTogglePreviewPanel: NSButton!
    
    
    @IBOutlet weak var btnImageOptions: NSPopUpButton!
    
    // MARK: Layout
    
    // right splitter
    @IBOutlet weak var verticalSplitView: NSSplitView!
    @IBOutlet weak var centralHorizontalSplitView: DarkSplitView!
    @IBOutlet weak var leftVerticalSplitView: NSSplitView!
    @IBOutlet weak var splitviewPreview: DarkSplitView!
    
    @IBOutlet weak var bottomView: NSView!
    
    
    // MARK: - Timer
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
    
    var testTimer:Timer!
    
    @IBOutlet weak var scrollviewMetaInfoTable: NSScrollView!
    
    // MARK: - NOTIFICATION MESSAGES
    
    var notificationPopover:NSPopover?
    var notificationViewController:NotificationViewController!
    
    var notificationMessagesPopover:NSPopover?
    var notificationMessageViewController:NotificationMessageViewController!
    
    // MARK: - TASK
    
    var taskProgressPopover:NSPopover?
    var taskProgressViewController:TaskProgressViewController!
    
    // MARK: - Image preview
    var img:ImageFile!
    @IBOutlet weak var playerContainer: NSView!
    var stackedImageViewController : StackedImageViewController!
    var stackedVideoViewController : StackedVideoViewController!
    
    // MARK: - MetaInfo table view
    //var metaInfo:[MetaInfo] = [MetaInfo]()
    var lastSelectedMetaInfoRow: Int?
    
    var imageMetaViewController : ImageMetaViewController!
    var imagePreviewController : ImagePreviewController!
    var imageLocationViewController : ImageLocationViewController!
    var imageLocationEditViewController : ImageLocationEditViewController!
    
    @IBOutlet weak var metaInfoTableView: NSTableView!
    
    @IBOutlet weak var lblImageDescription: NSTextField!
    
    
    // MARK: - Image Map
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var mapZoomSlider: NSSlider!
    
    // MARK: - Editor - Map
    @IBOutlet weak var addressSearcher: NSSearchField!

    @IBOutlet weak var webPossibleLocation: WKWebView!
    
    @IBOutlet weak var possibleLocationText: NSTextField!
    var locationTextDelegate:LocationTextDelegate?
    
    @IBOutlet weak var btnCopyLocation: NSButton!
    @IBOutlet weak var btnReplaceLocation: NSButton!
    @IBOutlet weak var btnManagePlaces: NSButton!
    
    @IBOutlet weak var btnChoiceMapService: NSSegmentedControl!
    
    
    // MARK: - Tree
    
    @IBOutlet weak var stackedTreeCanvasView: NSView!
    
    
    var treeLastSelectedIdentifier : String = ""
    var treeRefreshing:Bool = false
    
    var deviceIdToDevice : [String : PhoneDevice] = [String : PhoneDevice] ()
    
    
    var selectedMoment:Moment?
    var selectedImageFolder:ImageFolder?
    var selectedImageContainer:ImageContainer?
    var selectedImageFile:String = ""
    
    var treeLoadingIndicator:Accumulator?
    
    
    @IBOutlet weak var chbSelectAll: NSButton!
    
    
    // MARK: - Collection View for browsing
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var collectionProgressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var indicatorMessage: NSTextField!
    @IBOutlet weak var btnRefreshCollectionView: NSButton!
    @IBOutlet weak var btnCombineDuplicates: NSPopUpButton!
    @IBOutlet weak var btnPreviousPageCollection: NSButton!
    @IBOutlet weak var btnNextPageCollection: NSButton!
    @IBOutlet weak var lblPagesCollection: NSTextField!
    @IBOutlet weak var btnCollapseLeft: NSButton!
    @IBOutlet weak var btnCollapseRight: NSButton!
    @IBOutlet weak var btnCollapseBottom: NSButton!
    
    
    @IBOutlet weak var chbShowHidden: NSButton!
    
    var imagesLoader:CollectionViewItemsLoader!
    var collectionLoadingIndicator:Accumulator?
    
    // MARK: - SELECTION VIEW
    //var selectionEditing = false
    var selectionViewController : SelectionViewController!
    
    @IBOutlet weak var selectionCollectionView: NSCollectionView!
        
    // MARK: SELECTION BATCH EDITOR - EVENT & PLACE
    
    var eventPopover:NSPopover?
    var eventViewController:EventListViewController!
    
    var placePopover:NSPopover?
    var placeViewController:PlaceListViewController!
    
    var filterPopover:NSPopover?
    var filterViewController:FilterViewController!
    
    @IBOutlet weak var comboPlaceList: NSComboBox!
    
    // MARK: - Device Copy Dialog
    
    var deviceCopyWindowController:NSWindowController!
    
    // MARK: Theater Dialog
    var theaterWindowController:NSWindowController!
    
    // MARK: Repository Dialog
    var repositoryWindowController:NSWindowController!
    
    var peopleWindowController:NSWindowController!
    
    // MARK: Container Dialog
    var containerWindowController:NSWindowController!
    
    
    var librariesViewPopover:NSPopover?
    var librariesViewController:LibrariesViewController!
    
    var momentsTreeCategory = "MOMENTS"
    
    var momentsTreeHeaderMoreViewPopover:NSPopover?
    var momentsTreeHeaderMoreViewController:MomentsTreeHeaderMoreViewController!
    
    var containerDetailPopover:NSPopover?
    var containerDetailViewController:ContainerDetailViewController!
    
    var repositoryDetailPopover:NSPopover?
    var repositoryDetailViewController:RepositoryDetailViewController!
    
    
    var collectionPaginationPopover:NSPopover?
    var collectionPaginationViewController:CollectionPaginationViewController!
    
    var stackedTreeView:StackedTreeViewController!
    
    let deviceTreeDataSource = DeviceTreeDataSource()
    let repositoryTreeDataSource = RepositoryTreeDataSource()
    let momentsTreeDataSource = MomentsTreeDataSource()
    let placesTreeDataSource = PlacesTreeDataSource()
    let eventsTreeDataSource = EventsTreeDataSource()
    
    // MARK: Concurrency Indicators
    
    //var scaningRepositories:Bool = false
    //var creatingRepository:Bool = false
    var suppressedExport:Bool = false
    var suppressedScan:Bool = false
    
    // MARK: - WINDOW SIZE CONTROL
    
    var windowInitial:Bool = false
    var smallScreen:Bool = false
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
        
        if !(self.view.window?.isZoomed ?? true) {
            self.view.window?.performZoom(self)
        }
        
//        whereIsDock()
        
    }
    
    // MARK: - SPLASH SCREEN ON STARTUP
    
    var startingUp = false
    var splashController:SplashViewController!
    
    // MARK: - FACE MENU
    
    // MARK: - INIT VIEW
    
    func checkRepositoryVolumesMounted() -> ([String], [String], [String]) {
        let volumes_lasttime = PreferencesController.getSavedRepositoryVolumes()
        let (volumes_connected, volumes_missing) = self.collectRepositoryVolumesConnected()
        return (volumes_lasttime, volumes_connected, volumes_missing)
        
    }
    
    func collectRepositoryVolumesConnected() -> ([String],[String]) {
        var _connectedVolumes:Set<String> = []
        var _missingVolumes:Set<String> = []
        let repos = RepositoryDao.default.getRepositoriesV2(orderBy: "name", condition: nil)
        for repo in repos {
            let (connectedVolumes, missingVolumes) = LocalDirectory.bridge.getRepositoryVolume(repository: repo)
            for volume in connectedVolumes {
                if !_connectedVolumes.contains(volume) {
                    _connectedVolumes.insert(volume)
                }
            }
            for volume in missingVolumes {
                if !_missingVolumes.contains(volume) {
                    _missingVolumes.insert(volume)
                }
            }
        }
        let connected:[String] = Array(_connectedVolumes)
        let missing:[String] = Array(_missingVolumes)
        return (connected, missing)
    }
    
    var screenDockHeight = -1
    var screenDockPosition = "N/A"
    
    func onScreenDockHeightDetected(position:String, height:Int, screenWidth:CGFloat, screenHeight:CGFloat) {
        let changed = (position != self.screenDockPosition || height != self.screenDockHeight)
        self.screenDockHeight = height
        self.screenDockPosition = position
        // do on changed
        if(changed && position != "N/A") {
            self.logger.log("[MAIN-VIEW] RESIZE WINDOW to \(screenWidth) x \(screenHeight)")
            self.resize(width: screenWidth, height: screenHeight)
            
            
            self.logger.log("[MAIN] AFTER SIZE \(self.view.frame.size.width) x \(self.view.frame.size.height)")
        }
    }
    
    func whereIsDock() {
        
        if let screen = self.view.window?.screen {
            let visibleFrame = screen.visibleFrame
            let screenFrame = screen.frame
            
            if (visibleFrame.origin.x > screenFrame.origin.x) {
                self.onScreenDockHeightDetected(position: "LEFT", height: Int(visibleFrame.origin.x - screenFrame.origin.x), screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
                self.logger.log("[MAIN-VIEW] Dock is positioned on the LEFT")
                self.logger.log("[MAIN-VIEW] Dock width: \(visibleFrame.origin.x - screenFrame.origin.x)")
            } else if (visibleFrame.origin.y > screenFrame.origin.y) {
                self.onScreenDockHeightDetected(position: "BOTTOM", height: Int(visibleFrame.origin.y - screenFrame.origin.y), screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
                self.logger.log("[MAIN-VIEW] Dock is positioned on the BOTTOM")
                self.logger.log("[MAIN-VIEW] Dock height: \(visibleFrame.origin.y - screenFrame.origin.y)")
            } else if (visibleFrame.size.width < screenFrame.size.width) {
                self.onScreenDockHeightDetected(position: "RIGHT", height: Int(screenFrame.size.width - visibleFrame.size.width), screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
            } else {
                self.onScreenDockHeightDetected(position: "HIDDEN", height: 0, screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
                self.logger.log("[MAIN-VIEW] Dock is HIDDEN");
            }
        }else {
            self.onScreenDockHeightDetected(position: "N/A", height: -1, screenWidth: 0, screenHeight: 0)
            self.logger.log ("[MAIN-VIEW] CANNOT DETECT DOCK")
        }
    }
    
    internal func initView() {
//        whereIsDock()
        
//        if let faUrl = URL.fontURL(for: "Font Awesome 5 Free-Solid-900") {
//            self.logger.log(.debug, "fa url: \(faUrl)")
//        }else{
//            self.logger.log(.error, "Unable to load fontawesome")
//        }
        
        let (volumes_lasttime, volumes_connected, volumes_missing) = self.checkRepositoryVolumesMounted()
        self.logger.log("[STARTUP] volumes_lasttime: \(volumes_lasttime)")
        self.logger.log("[STARTUP] volumes_connected: \(volumes_connected)")
        if volumes_missing.count > 0 {
            self.logger.log(.error, "[STARTUP] volumes_missing: \(volumes_missing)")
            self.logger.log(.warning, "[STARTUP] decide NOT to Quit")
            self.splashController.message(Words.splash_loadingLibraries_failed_missing_volumes.fill(arguments: "\(volumes_missing)"), progress: 4)
            self.splashController.decideQuit = false
            self.logger.log(.todo, "TODO show an alert in UI say volumes missing")
//            return
        }else {
            PreferencesController.saveRepositoryVolumes(volumes_connected)
            self.logger.log("[STARTUP] saved volumes_connected: \(volumes_connected)")
        }
        
        MessageEventCenter.default.messagePresenter = { message in
            self.popNotification(message: message)
        }
        
        self.hideNotification()
//        self.logger.log("Loading view - preview zone")
        self.configurePreview()
//        self.logger.log("Loading view - selection view")
        self.configureSelectionView()
        
        self.setupUIDisplays()
        
        PreferencesController.healthCheck()
        
//        self.setupFacesMenu()
        self.setupScanMenu()
        self.setupExportMenu()
        self.setupPreviewMenu()
        
//        self.logger.log("Loading view - configure tree")
        configureTree()
//        self.logger.log("Loading view - configure collection view")
        configureCollectionView()
//        self.logger.log("Loading view - configure editors")
        
        self.configureDarkMode()
//        whereIsDock()
        self.resize()
        
//        self.logger.log("Loading view - update library tree")
        self.splashController.message(Words.splash_loadingLibraries.word(), progress: 4)
        
//        updateLibraryTree()
//        self.logger.log("Loading view - update library tree: DONE")
        
//        self.deviceCopyWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DeviceCopyWindowController")) as? NSWindowController
        
//        self.theaterWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "TheaterWindowController")) as? NSWindowController
        
//        self.repositoryWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EditRepositoryWindowController")) as? NSWindowController
        
//        self.containerWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ContainerViewerWindowController")) as? NSWindowController
        
//        self.peopleWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PeopleWindowController")) as? NSWindowController
        
        
        
        
        self.suppressedScan = true
//        self.btnScanState.image = NSImage(named: NSImage.Name.statusNone)
//        self.btnScanState.isHidden = true
        
        ExportManager.default.suppressed = true
        self.suppressedExport = true
        self.lastExportPhotos = Date()
        
        self.startSchedules()
//        self.logger.log(.debug, "")
//        self.logger.log("Loading view: DONE")
        
        
        
        NotificationMessageManager.default.createNotificationMessage(type: "HealthCheck", name: "Volumes_Connected", message: "Volumes connected: \(volumes_connected)")
        if volumes_missing.count > 0 {
            NotificationMessageManager.default.createNotificationMessage(type: "HealthCheck", name: "Volumes_Missing", message: "Volumes missing: \(volumes_missing)")
        }else{
            NotificationMessageManager.default.createNotificationMessage(type: "HealthCheck", name: "Volumes_Missing", message: "Volumes missing: none")
        }
        
        NotificationMessageManager.default.printAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        whereIsDock()
        
        self.logger.log("before splash - frame \(self.view.bounds)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTasksCount(notification:)), name: NSNotification.Name(rawValue: TaskletManager.NOTIFICATION_KEY_TASKCOUNT), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeNotificationMessagesCount(notification:)), name: NSNotification.Name(rawValue: NotificationMessageManager.NOTIFICATION_KEY_MESSAGECOUNT), object: nil)
        
        self.imagesLoader = CollectionViewItemsLoader()
        
        self.btnCombineDuplicates.toolTip = Words.main_combineTooltip.word()
        
        self.splashController = SplashViewController(onStartup: {
            self.logger.log("startup frame \(self.view.bounds)")
            self.splashController.view.frame = self.view.bounds
            self.doStartWork()
        }, onCompleted: {
            self.didStartWork()
        })
        //splashController.view.frame = self.view.frame
        self.view.addSubview(splashController.view)
        self.addChild(splashController)
        splashController.view.frame = self.view.bounds
        
        
//        whereIsDock()
        
        self.btnImageOptions.isEnabled = false
        
//        self.logger.log("Loading view")
        
        //self.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        //progressIndicator.isDisplayedWhenStopped = false
        collectionProgressIndicator.isDisplayedWhenStopped = false
        
//        self.logger.log("Loading view - configure dark mode")
        
        self.imagesLoader.hiddenCountHandler = { hiddenCount in
            DispatchQueue.main.async {
                self.chbShowHidden.title = "\(Words.hidden.word()) (\(hiddenCount))"
//                self.logger.log("hidden: \(hiddenCount)")
            }
        }
        
        self.chbShowHidden.state = NSButton.StateValue.off
        
        NotificationCenter.default.addObserver(self, selector: #selector(processDatabaseError(notification:)), name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: nil)
    }
    
    @objc func changeTasksCount(notification:Notification) {
        if let status = notification.object as? TasksStatus {
            DispatchQueue.main.async {
                self.btnTasks.title = Words.tasks.fill(arguments: status.runningCount, status.totalCount)
            }
        }
    }
    
    @objc func changeNotificationMessagesCount(notification:Notification) {
        if let status = notification.object as? NotificationMessagesStatus {
            DispatchQueue.main.async {
                self.btnNotification.title = Words.notifications.fill(arguments: status.totalCount)
            }
        }
    }
    
    @objc func processDatabaseError(notification:Notification) {
        if let error = notification.object as? Error {
            MessageEventCenter.default.showMessage(type: "ERROR", name:"DATABASE", message: "\(Words.dbError.word()): \(error)")
        }
    }
    
    func configureDarkMode() {
        view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        view.layer?.backgroundColor = Colors.DarkGray.cgColor
        self.btnCopyLocation.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnManagePlaces.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnReplaceLocation.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRefreshCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnCombineDuplicates.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.comboPlaceList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboPlaceList.backgroundColor = Colors.DarkGray
        self.addressSearcher.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.addressSearcher.backgroundColor = Colors.DarkGray
        self.addressSearcher.drawsBackground = true
        self.btnChoiceMapService.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.chbShowHidden.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        
        self.collectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.playerContainer.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
    }
    
    internal func setupUIDisplays() {
        self.btnTasks.title = Words.tasks.fill(arguments: 0, 0)
        self.btnNotification.title = Words.notifications.fill(arguments: "0")
        self.btnMemories.title = Words.memories.word()
        self.btnCombineDuplicates.title = Words.combineDuplicates.word()
        self.btnRefreshCollectionView.title = Words.reload.word()
        self.chbShowHidden.title = Words.hidden.word()
        self.chbSelectAll.title = Words.selectAll.word()
    }
    
    internal var startupAggregateFlag: Int = 0 {
        didSet {
            if startupAggregateFlag == 5 {
                self.prepareToolbarsOnStartup()
            }
        }
    }
    
    @IBAction func onAlertMessageClicked(_ sender: NSButton) {
        self.hideNotification()
    }
    
    
    // MARK: - Tree Node Controls
    
    var filterImageSource:[String] = []
    var filterCameraModel:[String] = []
    
    // MARK: - Collection View Controls
    
    var isCollectionPaginated:Bool = false
    
    @IBAction func onRefreshCollectionButtonClicked(_ sender: NSButton) {
        self.refreshCollection(sender)
    }
    
    @IBAction func onPreviousPageCollectionClicked(_ sender: NSButton) {
        self.previousPageCollection()
    }
    
    @IBAction func onNextPageCollectionClicked(_ sender: NSButton) {
        self.nextPageCollection()
    }
    
    var currentPageOfCollection = 0
    var totalPagesOfCollection = 0
    
    internal func changePaginationState(currentPage:Int, pageSize:Int, totalRecords:Int) {
        var pages = totalRecords / pageSize
        if totalRecords > (pages * pageSize) {
            pages += 1
        }
//        self.logger.log("totalrecords: \(totalRecords), pageSize:\(pageSize), pages:\(pages)")
        self.changePaginationState(currentPage: currentPage, totalPages: pages)
    }
    
    internal func changePaginationState(currentPage:Int, totalPages:Int){
//        self.logger.log("page: \(currentPage), total: \(totalPages)")
        self.currentPageOfCollection = currentPage
        self.totalPagesOfCollection = totalPages
        self.lblPagesCollection.stringValue = "\(currentPage) / \(totalPages)"
        self.btnPreviousPageCollection.isHidden = !(currentPage > 1)
        self.btnNextPageCollection.isHidden = !(currentPage < totalPages)
        if totalPages > 1 {
            self.btnRefreshCollectionView.title = Words.pages.word()
        }else{
            self.btnRefreshCollectionView.title = Words.reload.word()
        }
    }
    
    
    @IBAction func onCombineDuplicatesButtonClicked(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        self.selectCombineMenuInCollectionArea(i)
    }
    
    
    @IBAction func onCheckSelectAllClicked(_ sender: NSButton) {
        if self.chbSelectAll.state == .on {
            self.imagesLoader.checkAll()
        }else{
            self.imagesLoader.uncheckAll()
        }
    }
    
    
    @IBAction func onCheckShowHiddenClicked(_ sender: NSButton) {
        self.switchShowHideState()
    }
    
    // MARK: - FACE
    
    var runningFaceTask = false
    
    var stopFacesTask = false
    
    @IBAction func onStopClicked(_ sender: NSButton) {
        self.stopFacesTask = true
    }
    
    // MARK: - SEARCH
    
    var runningSearch = false
    
    @IBAction func onSearchAction(_ sender: NSTokenField) {
        self.logger.log("action on search: \(self.txtSearch.stringValue)")
    }
    
    
    @IBAction func onMemoriesClicked(_ sender: NSButton) {
        self.showMemories()
    }
    
    // MARK: - TASK
    
    @IBAction func onTasksClicked(_ sender: NSButton) {
        self.popTasks(sender)
    }
    
    @IBAction func onNotificationMessagesClicked(_ sender: NSButton) {
        
        NotificationMessageManager.default.printAll()
        self.popNotifications(sender)
    }
    
    
    @IBAction func onToggleLeftPanel(_ sender: NSButton) {
        let leftPanel = self.leftVerticalSplitView.arrangedSubviews[0]
        if self.leftVerticalSplitView.isSubviewCollapsed(leftPanel) {
            leftPanel.isHidden = false
            self.btnCollapseLeft.image = Icons.collapseLeftPanel
        }else{
            leftPanel.isHidden = true
            self.btnCollapseLeft.image = Icons.expandLeftPanel
        }
    }
    
    @IBAction func onToggleBottomPanel(_ sender: NSButton) {
        let bottomPanel = self.centralHorizontalSplitView.arrangedSubviews[1]
        if self.centralHorizontalSplitView.isSubviewCollapsed(bottomPanel) {
            bottomPanel.isHidden = false
            self.btnCollapseBottom.image = Icons.collapseBottomPanel
        }else{
            bottomPanel.isHidden = true
            self.btnCollapseBottom.image = Icons.expandBottomPanel
        }
    }
    
    @IBAction func onToggleRightPanel(_ sender: NSButton) {
        let rightPanel = self.verticalSplitView.arrangedSubviews[1]
        if self.verticalSplitView.isSubviewCollapsed(rightPanel) {
            rightPanel.isHidden = false
            self.btnCollapseRight.image = Icons.collapseRightPanel
        }else{
            rightPanel.isHidden = true
            self.btnCollapseRight.image = Icons.expandRightPanel
        }
    }
    
    @IBAction func onTogglePreviewInnerPanel(_ sender: NSButton) {
        let metaTablePanel = self.splitviewPreview.arrangedSubviews[0]
        if self.splitviewPreview.isSubviewCollapsed(metaTablePanel) {
            metaTablePanel.isHidden = false
            self.resizePreviewHoriztontalDivider()
            self.btnTogglePreviewPanel.image = Icons.collapsePreviewPanel
        }else{
            metaTablePanel.isHidden = true
            self.btnTogglePreviewPanel.image = Icons.expandPreviewPanel
        }
    }
    
    
}

