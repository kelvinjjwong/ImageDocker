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
    
    var childWindows:[String:NSWindow] = [:]
    
    // MARK: Icon
    let tick:NSImage = NSImage.init(named: NSImage.menuOnStateTemplateName)!
    
    // MARK: TOP BAR
    @IBOutlet weak var btnAlertMessage: NSButton!
    
    @IBOutlet weak var btnExport: NSPopUpButton!
    @IBOutlet weak var btnFaces: NSPopUpButton!
    @IBOutlet weak var btnTasks: NSButton!
    @IBOutlet weak var btnMemories: NSButton!
    
    @IBOutlet weak var txtSearch: NSSearchField!
    
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
    
    var notificationPopover:NSPopover?
    var notificationViewController:NotificationViewController!
    
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
    @IBOutlet weak var metaInfoTableView: NSTableView!
    
    @IBOutlet weak var lblImageDescription: NSTextField!
    
    
    // MARK: - Image Map
    var zoomSize:Int = 16
    var previousTick:Int = 3
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var mapZoomSlider: NSSlider!
    
    // MARK: - Editor - Map
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
    
    
    @IBOutlet weak var btnCollectionFilter: NSButton!
    @IBOutlet weak var chbShowHidden: NSButton!
    
    let imagesLoader = CollectionViewItemsLoader()
    var collectionLoadingIndicator:Accumulator?
    
    // MARK: - SELECTION VIEW
    //var selectionEditing = false
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
        self.resize()
        
        print("AFTER SIZE \(self.view.frame.size.width) x \(self.view.frame.size.height)")
    }
    
    // MARK: - SPLASH SCREEN ON STARTUP
    
    var startingUp = false
    var splashController:SplashViewController!
    
    // MARK: - FACE MENU
    
    // MARK: - INIT VIEW
    
    internal func initView() {
        self.hideNotification()
        print("\(Date()) Loading view - preview zone")
        self.configurePreview()
        print("\(Date()) Loading view - selection view")
        self.configureSelectionView()
        
        PreferencesController.healthCheck()
        
        self.setupFacesMenu()
        self.setupScanMenu()
        self.setupExportMenu()
        self.setupPreviewMenu()
        
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
        self.splashController.message("Loading libraries ...", progress: 4)
        updateLibraryTree()
        print("\(Date()) Loading view - update library tree: DONE")
        
//        self.deviceCopyWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DeviceCopyWindowController")) as? NSWindowController
        
//        self.theaterWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "TheaterWindowController")) as? NSWindowController
        
//        self.repositoryWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EditRepositoryWindowController")) as? NSWindowController
        
//        self.containerWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ContainerViewerWindowController")) as? NSWindowController
        
//        self.peopleWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PeopleWindowController")) as? NSWindowController
        
        
        self.btnChoiceMapService.selectSegment(withTag: 1)
        self.coordinateAPI = .baidu
        
        self.btnChoiceMapService.setImage(nil, forSegment: 0)
        self.btnChoiceMapService.setImage(tick, forSegment: 1)
        
        self.suppressedScan = true
//        self.btnScanState.image = NSImage(named: NSImage.Name.statusNone)
//        self.btnScanState.isHidden = true
        
        ExportManager.default.suppressed = true
        self.suppressedExport = true
        self.lastExportPhotos = Date()
        
        self.startSchedules()
        
        print("\(Date()) Loading view: DONE")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnShare.sendAction(on: .leftMouseDown)
        self.btnCombineDuplicates.toolTip = "Combine duplicated images to the 1st image"
        
        self.splashController = SplashViewController(onStartup: {
            self.splashController.view.frame = self.view.bounds
            self.doStartWork()
        }, onCompleted: {
            self.didStartWork()
        })
        //splashController.view.frame = self.view.frame
        self.view.addSubview(splashController.view)
        self.addChild(splashController)
        splashController.view.frame = self.view.bounds
        
        self.btnImageOptions.isEnabled = false
        
        print("\(Date()) Loading view")
        
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
        
        
    }
    
    func configureDarkMode() {
        view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        view.layer?.backgroundColor = Colors.DarkGray.cgColor
        self.btnAssignEvent.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnCopyLocation.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnManageEvents.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnManagePlaces.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnReplaceLocation.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnRefreshCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnCombineDuplicates.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.comboEventList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboEventList.backgroundColor = Colors.DarkGray
        self.comboPlaceList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboPlaceList.backgroundColor = Colors.DarkGray
        self.addressSearcher.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.addressSearcher.backgroundColor = Colors.DarkGray
        self.addressSearcher.drawsBackground = true
        self.btnChoiceMapService.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.btnBatchEditorToolbarSwitcher.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.selectionCheckAllBox.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.chbShowHidden.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.btnShow.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnHide.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.metaInfoTableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.collectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.selectionCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.playerContainer.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        
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
    
    
    // MARK: - Preview Zone
    
    @IBAction func onMapSliderClick(_ sender: NSSliderCell) {
        let tick:Int = sender.integerValue
        self.resizeMap(tick: tick)
    }
    
    // MARK: - Tree Node Controls
    
    var filterImageSource:[String] = []
    var filterCameraModel:[String] = []
    
    // MARK: - Collection View Controls
    
    var isCollectionPaginated:Bool = false
    
    @IBAction func onRefreshCollectionButtonClicked(_ sender: NSButton) {
        self.refreshCollection(sender)
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
    
    @IBAction func onCollectionFilterClicked(_ sender: NSButton) {
        self.showCollectionFilter(sender)
    }
    
    
    // MARK: - SELECTION BATCH EDITOR TOOLBAR - SWITCHER
    
    @IBAction func onBatchEditorToolbarSwitcherClicked(_ sender: NSButton) {
        self.switchSelectionToolbar()
    }
    
    
    // MARK: SELECTION TOOLBAR
    
    @IBAction func onShareClicked(_ sender: NSButton) {
        self.share(sender)
    }
    
    // MARK: - COPY IMAGES TO ELSEWHERE (COMPUTER OR DEVICE)
    
    @IBAction func onCopyToDeviceClicked(_ sender: NSButton) {
        self.openExportToDeviceDialog(sender)
    }
    
    internal var copyToDevicePopover:NSPopover? = nil
    internal var deviceFolderViewController:DeviceFolderViewController!
    
    // MARK: - SELECTION AREA
    
    @IBAction func onSelectionRemoveAllClicked(_ sender: Any) {
        self.cleanUpSelectionArea()
    }
    
    
    @IBAction func onSelectionRemoveButtonClicked(_ sender: Any) {
        self.cleanSomeFromSelectionArea()
    }
    

    @IBAction func onSelectionCheckAllClicked(_ sender: NSButton) {
        self.checkAllInSelectionArea()
    }
    
    // MARK: - Selection View - Batch Editor - Location Actions
    
    @IBAction func onAddressSearcherAction(_ sender: Any) {
        let address:String = addressSearcher.stringValue
        self.searchAddress(address)
    }
    
    // from selected image
    @IBAction func onCopyLocationFromMapClicked(_ sender: Any) {
        self.copyLocationFromMap()
        
    }
    
    @IBAction func onReplaceLocationClicked(_ sender: Any) {
        self.replaceLocation()
    }
    
    // add to favourites
    @IBAction func onMarkLocationButtonClicked(_ sender: NSButton) {
        self.openLocationSelector(sender)
    }
    
    @IBAction func onButtonChoiceMapServiceClicked(_ sender: NSSegmentedControl) {
        self.chooseMapProvider(sender.selectedSegment)
    }
    
    @IBAction func onButtonDuplicatesClicked(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        self.selectCombineMenuInSelectionArea(i)
    }
    
    // MARK: Selection View - Batch Editor - Notes
    
    
    @IBAction func onButtonNotesClicked(_ sender: NSButton) {
        self.openNoteWriter(sender)
    }
    
    
    var notesPopover:NSPopover? = nil
    var notesViewController:NotesViewController!
    
    // MARK: Selection View - Batch Editor - Date
    
    @IBAction func onButtonDatePickerClicked(_ sender: NSButton) {
        self.openDatePicker(sender)
    }
    
    
    var calendarPopover:NSPopover? = nil
    var calendarViewController:DateTimeViewController!
    
    
    // MARK: Selection View - Batch Editor - Event Actions
    
    // add to favourites
    @IBAction func onAddEventButtonClicked(_ sender: NSButton) {
        self.createEventPopover()
        
        let cellRect = sender.bounds
        self.eventPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    @IBAction func onAssignEventButtonClicked(_ sender: Any) {
        self.assignEvent()
    }
    
    // MARK: Selection View - Batch Editor - Show/Hide Controls
    
    @IBAction func onButtonHideClicked(_ sender: Any) {
        self.hideSelectedImages()
    }
    
    @IBAction func onButtonShowClicked(_ sender: Any) {
        self.visibleSelectedImages()
    }
    
    // MARK: - FACE
    
    var runningFaceTask = false
    
    var stopFacesTask = false
    
    @IBAction func onStopClicked(_ sender: NSButton) {
        self.stopFacesTask = true
    }
    
    // MARK: - SEARCH
    
    var runningSearch = false
    
    @IBAction func onSearchAction(_ sender: NSSearchField) {
        print("search: \(sender.stringValue)")
        self.search(sender.stringValue)
    }
    
    @IBAction func onMemoriesClicked(_ sender: NSButton) {
        self.showMemories()
    }
    
    // MARK: - TASK
    
    @IBAction func onTasksClicked(_ sender: NSButton) {
        self.popTasks(sender)
    }
    
    @IBAction func onToggleLeftPanel(_ sender: NSButton) {
        let leftPanel = self.leftVerticalSplitView.arrangedSubviews[0]
        if self.leftVerticalSplitView.isSubviewCollapsed(leftPanel) {
            leftPanel.isHidden = false
            self.btnToggleLeftPanel.image = Icons.collapseLeftPanel
        }else{
            leftPanel.isHidden = true
            self.btnToggleLeftPanel.image = Icons.expandLeftPanel
        }
    }
    
    @IBAction func onToggleBottomPanel(_ sender: NSButton) {
        let bottomPanel = self.centralHorizontalSplitView.arrangedSubviews[1]
        if self.centralHorizontalSplitView.isSubviewCollapsed(bottomPanel) {
            bottomPanel.isHidden = false
            self.btnToggleBottomPanel.image = Icons.collapseBottomPanel
        }else{
            bottomPanel.isHidden = true
            self.btnToggleBottomPanel.image = Icons.expandBottomPanel
        }
    }
    
    @IBAction func onToggleRightPanel(_ sender: NSButton) {
        let rightPanel = self.verticalSplitView.arrangedSubviews[1]
        if self.verticalSplitView.isSubviewCollapsed(rightPanel) {
            rightPanel.isHidden = false
            self.btnToggleRightPanel.image = Icons.collapseRightPanel
        }else{
            rightPanel.isHidden = true
            self.btnToggleRightPanel.image = Icons.expandRightPanel
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
