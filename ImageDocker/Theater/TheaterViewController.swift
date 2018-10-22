//
//  TheaterViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/10/15.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import Quartz

class TheaterViewController: NSViewController {
    
    // MARK: CONTROLS
    
    @IBOutlet weak var lblBrief: NSTextField!
    @IBOutlet weak var lblDate: NSTextField!
    @IBOutlet weak var lblDescription: NSTextField!
    
    
    @IBOutlet weak var bgBrief: NSView!
    @IBOutlet weak var bgDate: NSView!
    @IBOutlet weak var preview: NSView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    @IBOutlet weak var lstMonth: NSTableView!
    @IBOutlet weak var lstDay: NSTableView!
    
    var collectionViewController:TheaterCollectionViewController!
    var photoTakenDate:Date?
    
    // MARK: INIT
    
    fileprivate var windowInitial:Bool = false
    fileprivate var smallScreen:Bool = false
    
    let monthController = MonthListController()
    let dayController = DayListController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDarkMode()
        self.configureCollectionView()
        
        self.lstMonth.rowSizeStyle = .custom
        self.lstMonth.rowHeight = CGFloat(35.0)
        self.lstMonth.dataSource = monthController
        self.lstMonth.delegate = monthController
        self.lstDay.rowSizeStyle = .custom
        self.lstDay.rowHeight = CGFloat(35.0)
        self.lstDay.dataSource = dayController
        self.lstDay.delegate = dayController
        
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
        self.resize()
    }
    
    fileprivate func resize() {
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
        
        windowInitial = true
    }
    
    fileprivate func configureDarkMode() {
        view.wantsLayer = true
        view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        view.layer?.backgroundColor = NSColor(calibratedWhite: 0.1, alpha: 1).cgColor
        
        self.preview.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.lblDate.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.lblBrief.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.lblDescription.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.collectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.lstMonth.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.lstDay.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.bgDate.wantsLayer = true
        bgDate.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        bgDate.layer?.backgroundColor = NSColor.black.cgColor
        
        self.bgBrief.wantsLayer = true
        bgBrief.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        bgBrief.layer?.backgroundColor = NSColor.black.cgColor
        
    }
    
    func viewInit(image:ImageFile){
        self.previewImage(image: image)
        
        if let date = image.photoTakenDate() {
            self.photoTakenDate = image.photoTakenDate()
            self.displayDate()
            let year = Calendar.current.component(.year, from: date)
            let month = Calendar.current.component(.month, from: date)
            let day = Calendar.current.component(.day, from: date)
            let datesOfYear = ModelStore.default.getDatesByYear(year: year)
            self.monthController.months = datesOfYear.keys.sorted()
            self.dayController.days = datesOfYear["\(month)"] ?? []
            self.lstMonth.reloadData()
            self.lstDay.reloadData()
        }else{
            // FIXME: clean fields
        }
        self.configureCollectionView()
        self.reloadCollectionView()
        
        
    }
    
    override func dismiss(_ sender: Any?) {
        if let wc = self.view.window?.windowController {
            wc.dismissController (sender)
        }
    }
    
    private func displayDate() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy"
        
        if let date = self.photoTakenDate {
            self.lblDate.stringValue = dateFormat.string(from: date)
        }else{
            self.lblDate.stringValue = ""
        }
    }
    
    private func previewImage(image:ImageFile){
        self.preview.subviews.removeAll()
        let previewView = QLPreviewView(frame: NSRect(x: 0, y: 0, width:
            self.preview.visibleRect.width, height:
            self.preview.visibleRect.height), style: .normal)
        
        let quickLookItem = TheaterQuickLookItem()
        quickLookItem.previewItemURL = image.url
        previewView?.previewItem = quickLookItem
        previewView?.autostarts = true
        previewView?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        
        self.preview.addSubview(previewView!)
        
        if let data = image.imageData {
            self.lblBrief.stringValue = ExportManager.default.getImageBrief(photo: data)
            self.lblDescription.stringValue = data.longDescription ?? ""
        }
        
    }
}


// MARK: COLLECTION VIEW

extension TheaterViewController {
    
    
    private func configureCollectionView() {
        
        collectionViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "theaterCollectionView")) as! TheaterCollectionViewController
        self.addChildViewController(collectionViewController)
        
        // outlet
        collectionViewController.collectionView = self.collectionView
        self.collectionView.dataSource = collectionViewController
        self.collectionView.delegate = collectionViewController
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 150, height: 150.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        flowLayout.minimumInteritemSpacing = 2.5
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
        collectionView.backgroundColors = [NSColor.black] //[NSColor(calibratedWhite: 0.1, alpha: 1)]
        collectionView.layer?.backgroundColor = NSColor.black.cgColor //NSColor(calibratedWhite: 0.1, alpha: 1).cgColor
        collectionView.layer?.borderColor = NSColor.black.cgColor
        
        lstMonth.backgroundColor = NSColor.black
        lstMonth.layer?.backgroundColor = NSColor.black.cgColor
        lstMonth.layer?.borderColor = NSColor.black.cgColor
        lstDay.backgroundColor = NSColor.black
        lstDay.layer?.backgroundColor = NSColor.black.cgColor
        lstDay.layer?.borderColor = NSColor.black.cgColor
        lblDate.backgroundColor = NSColor.black
        lblDate.layer?.backgroundColor = NSColor.black.cgColor
        lblDate.layer?.borderColor = NSColor.black.cgColor
        
        collectionViewController.imagesLoader.singleSectionMode = true
        collectionViewController.imagesLoader.showHidden = false
        collectionViewController.imagesLoader.clean()
        collectionViewController.collectionView.reloadData()
    }
    
    private func reloadCollectionView() {
        self.collectionViewController.imagesLoader.clean()
        if let date = self.photoTakenDate {
            let images = ModelStore.default.getImagesByDate(photoTakenDate: date)
            self.collectionViewController.imagesLoader.setupItems(photoFiles: images)
            self.collectionViewController.imagesLoader.reorganizeItems(considerPlaces: false)
        }else{
            self.collectionViewController.imagesLoader.setupItems(photoFiles: nil)
        }
        self.collectionViewController.collectionView.reloadData()
    }
}

// MARK: WINDOW CONTROLLER
extension TheaterViewController : NSWindowDelegate {
    
    
    func windowWillClose(_ notification: Notification) {
        //NSApplication.shared.terminate(self)
    }
}

