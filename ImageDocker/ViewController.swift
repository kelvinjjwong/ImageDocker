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
import LoggerFactory
import WebKit
import AVFoundation
import AVKit
import SharedDeviceLib

class ViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "MAIN", subCategory: "VIEW")
    
    var childWindows:[String:NSWindow] = [:]
    
    var centralSplitViewDelegate:CentralSplitViewDelegate!
    
    // MARK: Main Menu
    
    
    // MARK: Icon
    let tick:NSImage = NSImage.init(named: NSImage.menuOnStateTemplateName)!
    
    
    @IBOutlet weak var topToolbarPanelView: NSView!
    
    // MARK: TOP BAR
    @IBOutlet weak var btnAlertMessage: NSButton!
    
    @IBOutlet weak var btnExport: NSButton!
//    @IBOutlet weak var btnFaces: NSPopUpButton!
    @IBOutlet weak var btnTasks: NSButton!
    @IBOutlet weak var btnMemories: NSButton!
    
    @IBOutlet weak var btnNotification: NSButton!
    @IBOutlet weak var txtSearch: NSTokenField!
    
    
    @IBOutlet weak var btnToggleLeftPanel: NSButton!
    @IBOutlet weak var btnToggleBottomPanel: NSButton!
    @IBOutlet weak var btnToggleRightPanel: NSButton!
    @IBOutlet weak var btnToggleRightPanel2: NSButton!
    
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
    var lastCentralNotificationTime:Date?
    var centralNotificationFadeOutTimer:Timer!
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
    
    var imageEditTabViewController : ImageEditTabViewController!
    
    var imageLocationViewController : ImageLocationViewController!
    var imageLocationEditViewController : ImageLocationEditViewController!
    var imageNoteEditViewController:ImageNoteEditViewController!
    var imageEventEditViewController:ImageEventEditViewController!
    var imageFamilyEditViewController:ImageFamilyEditViewController!
    
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
    
    
    
    @IBOutlet weak var collectionToolbarPanelView: NSView!
    
    // MARK: - Collection View
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    // MARK: - Collection Pages
    @IBOutlet weak var collectionPaginationView: NSView!
    
    @IBOutlet weak var lblShowRecords: NSTextField! // how many records are shown
    @IBOutlet weak var lblHiddenRecords: NSTextField! // how many records are hidden
    
    
    @IBOutlet weak var btnFirstPageCollection: NSButton! // first page
    @IBOutlet weak var btnPreviousPageCollection: NSButton! // previous page
    @IBOutlet weak var lblPagesCollection: NSTextField! // current page / total pages
    @IBOutlet weak var btnNextPageCollection: NSButton! // next page
    @IBOutlet weak var btnLastPageCollection: NSButton! // last page
    
    @IBOutlet weak var popPageSizeCollection: NSPopUpButton! // page size drop down list
    @IBOutlet weak var lblPageSizeCollection: NSTextField! // per page
    
    @IBOutlet weak var btnRefreshCollectionView: NSButton! // reload
    
    // MARK: - Collection Progress
    
    @IBOutlet weak var indicatorMessage: NSTextField!
    @IBOutlet weak var collectionProgressIndicator: NSProgressIndicator!
    
    // MARK: - Collection Filters
    
    static var collectionFilter:CollectionFilter = CollectionFilter()
    @IBOutlet weak var btnFilter: NSButton! // filter
    @IBOutlet weak var btnCombineDuplicates: NSPopUpButton! // duplication ops
    
    
    var collectionFilterPopover:NSPopover?
    var collectionFilterViewController:CollectionFilterViewController!
    
    // MARK: - Panel Collapse
    
    @IBOutlet weak var btnCollapseLeft: NSButton!
    @IBOutlet weak var btnCollapseRight: NSButton!
    @IBOutlet weak var btnCollapseBottom: NSButton!
    
    
    
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
    var collectionPaginationViewController:CollectionPaginationViewController! // popover panel
    
    var stackedTreeView:StackedTreeViewController!
    
    let deviceTreeDataSource = DeviceTreeDataSource()
    let repositoryTreeDataSource = RepositoryTreeDataSource()
    let momentsTreeDataSource = MomentsTreeDataSource()
    let placesTreeDataSource = PlacesTreeDataSource()
    let eventsTreeDataSource = EventsTreeDataSource()
    
    // MARK: Concurrency Indicators
    
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
        let volumes = LocalDirectory.bridge.mountpoints().appending(Setting.localEnvironment.localDiskMountPoints())
        self.logger.log(.info, "mounted volumes: \(volumes)")
        print("mounted volumes: \(volumes)")
        for repo in repos {
            let (connectedVolumes, missingVolumes) = LocalDirectory.bridge.getRepositoryVolume(repository: repo, volumes: volumes)
            self.logger.log(.info, "[connected volumes] \(connectedVolumes)")
            self.logger.log(.info, "[missing   volumes] \(missingVolumes)")
            print("[connected volumes] \(connectedVolumes)")
            print("[missing   volumes] \(missingVolumes)")
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
        var connected:[String] = []
        for v in _connectedVolumes.sorted() {
            connected.append(v)
        }
        var missing:[String] = []
        for v in _missingVolumes.sorted() {
            missing.append(v)
        }
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
            self.logger.log(.trace, "[MAIN-VIEW] RESIZE WINDOW to \(screenWidth) x \(screenHeight)")
            self.resize(width: screenWidth, height: screenHeight)
            
            
            self.logger.log(.trace, "[MAIN] AFTER SIZE \(self.view.frame.size.width) x \(self.view.frame.size.height)")
        }
    }
    
    func whereIsDock() {
        
        if let screen = self.view.window?.screen {
            let visibleFrame = screen.visibleFrame
            let screenFrame = screen.frame
            
            if (visibleFrame.origin.x > screenFrame.origin.x) {
                self.onScreenDockHeightDetected(position: "LEFT", height: Int(visibleFrame.origin.x - screenFrame.origin.x), screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
                self.logger.log(.trace, "[MAIN-VIEW] Dock is positioned on the LEFT")
                self.logger.log(.trace, "[MAIN-VIEW] Dock width: \(visibleFrame.origin.x - screenFrame.origin.x)")
            } else if (visibleFrame.origin.y > screenFrame.origin.y) {
                self.onScreenDockHeightDetected(position: "BOTTOM", height: Int(visibleFrame.origin.y - screenFrame.origin.y), screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
                self.logger.log(.trace, "[MAIN-VIEW] Dock is positioned on the BOTTOM")
                self.logger.log(.trace, "[MAIN-VIEW] Dock height: \(visibleFrame.origin.y - screenFrame.origin.y)")
            } else if (visibleFrame.size.width < screenFrame.size.width) {
                self.onScreenDockHeightDetected(position: "RIGHT", height: Int(screenFrame.size.width - visibleFrame.size.width), screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
            } else {
                self.onScreenDockHeightDetected(position: "HIDDEN", height: 0, screenWidth: visibleFrame.size.width, screenHeight: visibleFrame.size.height)
                self.logger.log(.trace, "[MAIN-VIEW] Dock is HIDDEN");
            }
        }else {
            self.onScreenDockHeightDetected(position: "N/A", height: -1, screenWidth: 0, screenHeight: 0)
            self.logger.log ("[MAIN-VIEW] CANNOT DETECT DOCK")
        }
    }
    
    func checkMissingVolumes() -> ([String], [String]) {
        let (volumes_lasttime, volumes_connected, volumes_missing) = self.checkRepositoryVolumesMounted()
        self.logger.log(.trace, "[STARTUP] volumes_lasttime: \(volumes_lasttime)")
        self.logger.log(.trace, "[STARTUP] volumes_connected: \(volumes_connected)")
        if volumes_missing.count > 0 {
            self.logger.log(.error, "[STARTUP] volumes_missing: \(volumes_missing)")
            self.logger.log(.warning, "[STARTUP] decide NOT to Quit")
            self.splashController.message(Words.splash_loadingLibraries_failed_missing_volumes.fill(arguments: "\(volumes_missing)"), progress: 4)
            self.splashController.decideQuit = false
//            return
        }else {
            PreferencesController.saveRepositoryVolumes(volumes_connected)
            self.logger.log(.trace, "[STARTUP] saved volumes_connected: \(volumes_connected)")
        }
        return (volumes_connected, volumes_missing)
    }
    
    internal func initView() {
//        whereIsDock()
        self.logger.log(.trace, self.view.window?.screen?.frame)
        self.logger.log(.trace, self.view.window?.screen?.visibleFrame)
        let dockLeft = self.view.window?.screen?.visibleFrame.origin.x ?? 0 - (self.view.window?.screen?.frame.origin.x ?? 0)
        let dockHeight = self.view.window?.screen?.visibleFrame.origin.y ?? 0 - (self.view.window?.screen?.frame.origin.y ?? 0)
        let dockRight = self.view.window?.screen?.frame.size.width ?? 0 - (self.view.window?.screen?.visibleFrame.size.width ?? 0)
        self.logger.log(.trace, dockHeight)
        self.logger.log(.trace, NSStatusBar.system.thickness)
        
        let (volumes_connected, volumes_missing) = self.checkMissingVolumes()
        
        
        MessageEventCenter.default.messagePresenter = { message in
            self.popNotification(message: message)
        }
        
        self.hideNotification()
        self.configurePreview()
        self.configureSelectionView()
        
        self.setupUIDisplays()
        
        PreferencesController.healthCheck()
        
        self.setupScanMenu()
        self.setupExportMenu()
        self.setupPreviewMenu()
        self.configureTree()
        self.configureCollectionView()
        
        self.configureDarkMode()
        self.resize()
        
        self.toggleOffBottomPanel()
        self.toggleOffRightPanel()
        
        self.splashController.message(Words.splash_loadingLibraries.word(), progress: 4)
        
        self.suppressedScan = true
        
        ExportManager.default.suppressed = true
        self.suppressedExport = true
        self.lastExportPhotos = Date()
        
        self.startSchedules()
        
        
        if volumes_connected.count > 0 {
            NotificationMessageManager.default.createNotificationMessage(
                type: Words.notification_title_healthcheck.word(),
                name: Words.notification_volume_connected.word(),
                message: Words.notification_which_volume_connected.fill(arguments: "\(volumes_connected)")
            )
        }else{
            NotificationMessageManager.default.createNotificationMessage(
                type: Words.notification_title_healthcheck.word(),
                name: Words.notification_volume_connected.word(),
                message: Words.notification_none_volume_connected.word()
            )
        }
        if volumes_missing.count > 0 {
            NotificationMessageManager.default.createNotificationMessage(
                type: Words.notification_title_healthcheck.word(),
                name: Words.notification_volume_missing.word(),
                message: Words.notification_which_volume_missing.fill(arguments: "\(volumes_missing)")
            )
            MessageEventCenter.default.showMessage(message: Words.notification_which_volume_missing.fill(arguments: "\(volumes_missing)"))
        }else{
            NotificationMessageManager.default.createNotificationMessage(
                type: Words.notification_title_healthcheck.word(),
                name: Words.notification_volume_missing.word(),
                message: Words.notification_none_volume_missing.word()
            )
        }
        
        NotificationMessageManager.default.printAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        whereIsDock()
        
        self.logger.log(.trace, "before splash - frame \(self.view.bounds)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTasksCount(notification:)), name: NSNotification.Name(rawValue: TaskletManager.NOTIFICATION_KEY_TASKCOUNT), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeNotificationMessagesCount(notification:)), name: NSNotification.Name(rawValue: NotificationMessageManager.NOTIFICATION_KEY_MESSAGECOUNT), object: nil)
        
        self.imagesLoader = CollectionViewItemsLoader()
        
        self.btnCombineDuplicates.toolTip = Words.main_combineTooltip.word()
        
        self.splashController = SplashViewController(onStartup: {
            self.logger.log(.trace, "startup frame \(self.view.bounds)")
            self.splashController.view.frame = self.view.bounds
            self.doStartWork()
        }, onCompleted: {
            self.didStartWork()
        })
        self.view.addSubview(splashController.view)
        self.addChild(splashController)
        splashController.view.frame = self.view.bounds
        
        self.btnImageOptions.isEnabled = false
        collectionProgressIndicator.isDisplayedWhenStopped = false
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
        self.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.view.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
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
        
        self.collectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.playerContainer.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
    }
    
    internal func setupUIDisplays() {
        self.topToolbarPanelView.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        self.btnTasks.title = Words.tasks.fill(arguments: 0, 0)
        self.btnExport.title = Words.export_button_on_main_window.word()
        self.btnNotification.title = Words.notifications.fill(arguments: "0")
        self.btnMemories.title = Words.memories.word()
        self.btnCombineDuplicates.title = Words.combineDuplicates.word()
        self.btnRefreshCollectionView.title = Words.reload.word()
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
    
    // MARK: - Collection Pages
    
    func initPaginationController(){
        self.collectionToolbarPanelView.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        
        if self.collectionPaginationController == nil {
            self.collectionPaginationController = CollectionPaginationController(panel: self.collectionPaginationView,
                                                                                 lblShowRecords: self.lblShowRecords,
                                                                                 lblHiddenRecords: self.lblHiddenRecords,
                                                                                 
                                                                                 lstPageSize: self.popPageSizeCollection,
                                                                                 lblCaptionPageSize: self.lblPageSizeCollection,
                                                                                 
                                                                                 btnFirstPage: self.btnFirstPageCollection,
                                                                                 btnPreviousPage: self.btnPreviousPageCollection,
                                                                                 lblPageNumber: self.lblPagesCollection,
                                                                                 btnNextPage: self.btnNextPageCollection,
                                                                                 btnLastPage: self.btnLastPageCollection,
                                                                                 
                                                                                 btnLoadPage: self.btnRefreshCollectionView
            )
        }
    }
    
    var collectionPaginationController:CollectionPaginationController?
    
    var isCollectionPaginated:Bool = false
    
    @IBAction func onFirstPageCollectionClicked(_ sender: NSButton) {
        self.collectionPaginationController?.onFirstPage()
    }
    
    @IBAction func onPreviousPageCollectionClicked(_ sender: NSButton) {
        self.logger.log(.trace, "clicked previous page")
        self.collectionPaginationController?.onPreviousPage()
    }
    
    @IBAction func onNextPageCollectionClicked(_ sender: NSButton) {
        self.logger.log(.trace, "clicked next page")
        self.collectionPaginationController?.onNextPage()
    }
    
    @IBAction func onLastPageCollectionClicked(_ sender: NSButton) {
        self.collectionPaginationController?.onLastPage()
    }
    
    @IBAction func onRefreshCollectionButtonClicked(_ sender: NSButton) {
        self.logger.log(.trace, "reload collection view button clicked")
        self.collectionPaginationController?.onReload()
    }
    
    var currentPageOfCollection = 0
    var totalPagesOfCollection = 0
    
    // MARK: - Collection Filters
    
    @IBAction func onCombineDuplicatesButtonClicked(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        self.selectCombineMenuInCollectionArea(i)
    }
    
    // MARK: - FACE
    
    var runningFaceTask = false
    
    var stopFacesTask = false
    
    // MARK: - SEARCH
    
    var runningSearch = false
    
    @IBAction func onSearchAction(_ sender: NSTokenField) {
        self.logger.log(.trace, "action on search: \(self.txtSearch.stringValue)")
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
    
    // MARK: - Panel Collapse
    
    
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
    
    func toggleOffBottomPanel() {
        let bottomPanel = self.centralHorizontalSplitView.arrangedSubviews[1]
        bottomPanel.isHidden = true
        self.btnCollapseBottom.image = Icons.expandBottomPanel
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
        DispatchQueue.main.async {
            self.selectionViewController.view.frame = self.bottomView.bounds
        }
    }
    
    func toggleOffRightPanel() {
        let rightPanel = self.verticalSplitView.arrangedSubviews[1]
        rightPanel.isHidden = true
        self.btnCollapseRight.image = Icons.expandRightPanel
        DispatchQueue.main.async {
            self.selectionViewController.view.frame = self.bottomView.bounds
        }
    }
    
    @IBAction func onToggleRightPanel2(_ sender: NSButton) {
        let rightPanel = self.verticalSplitView.arrangedSubviews[1]
        if self.verticalSplitView.isSubviewCollapsed(rightPanel) {
            rightPanel.isHidden = false
            self.btnCollapseRight.image = Icons.collapseRightPanel
            self.btnToggleRightPanel2.image = Icons.collapseRightPanel
        }else{
            rightPanel.isHidden = true
            self.btnCollapseRight.image = Icons.expandRightPanel
            self.btnToggleRightPanel2.image = Icons.expandRightPanel
        }
        DispatchQueue.main.async {
            self.selectionViewController.view.frame = self.bottomView.bounds
        }
    }
    
    
    @IBAction func onToggleRightPanel(_ sender: NSButton) {
        let rightPanel = self.verticalSplitView.arrangedSubviews[1]
        if self.verticalSplitView.isSubviewCollapsed(rightPanel) {
            rightPanel.isHidden = false
            self.btnCollapseRight.image = Icons.collapseRightPanel
            self.btnToggleRightPanel2.image = Icons.collapseRightPanel
        }else{
            rightPanel.isHidden = true
            self.btnCollapseRight.image = Icons.expandRightPanel
            self.btnToggleRightPanel2.image = Icons.expandRightPanel
        }
        DispatchQueue.main.async {
            self.selectionViewController.view.frame = self.bottomView.bounds
        }
    }
    
    @IBAction func onTogglePreviewInnerPanel(_ sender: NSButton) {
        let rightPanel = self.verticalSplitView.arrangedSubviews[1]
        if rightPanel.isHidden || self.verticalSplitView.isSubviewCollapsed(rightPanel) {
            rightPanel.isHidden = false
            self.btnCollapseRight.image = Icons.collapseRightPanel
            self.btnToggleRightPanel2.image = Icons.collapseRightPanel
        }
        
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
    
    @IBAction func onManageEventsButtonClicked(_ sender: NSButton) {
        self.createEventPopover()
        
        let cellRect = sender.bounds
        self.eventPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    @IBAction func onPeopleClicked(_ sender: NSButton) {
        let viewController = PeopleManageViewController()
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 800
        let windowHeight = 650
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = Words.peopleManage.word()
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView()
    }
    
    @IBAction func onCollectionFilterClicked(_ sender: NSButton) {
        self.popoverCollectionFilter()
    }
    
    @IBAction func onExportClicked(_ sender: NSButton) {
        self.exportMenuConfigAction()
    }
    
    
}

