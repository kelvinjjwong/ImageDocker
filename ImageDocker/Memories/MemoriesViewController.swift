//
//  MemoriesViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/13.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import Quartz
import Carbon.HIToolbox

class MemoriesViewController : NSViewController {
    
    @IBOutlet weak var lblToday: NSTextField!
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var preview: NSView!
    @IBOutlet weak var btnLastYear: NSButton!
    @IBOutlet weak var btnNextYear: NSButton!
    @IBOutlet weak var btnToday: NSButton!
    @IBOutlet weak var btnDayMinusTwo: NSButton!
    @IBOutlet weak var btnDayMinusOne: NSButton!
    @IBOutlet weak var btnDayAddTwo: NSButton!
    @IBOutlet weak var btnDayAddOne: NSButton!
    @IBOutlet weak var btnMenu: NSButton!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var btnHide: NSButton!
    @IBOutlet weak var btnPlay: NSButton!
    
    
    var collectionViewController:MemoriesCollectionViewController!
    var selectedImageFile:ImageFile?
    var selectedIndex = 0
    
    internal var selectYear = 0
    internal var selectMonth = 0
    internal var selectDay = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var timer:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView()
        
        self.startCollectionLoop()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.stopCollectionLoop()
    }
    
    @objc func playerDidFinishPlaying() {
        print("video ends")
    }
    
    internal var timerStarted = true
    
    internal func startCollectionLoop() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.selectNextItem(timer:)), userInfo: "timer", repeats: true)
        }
    }
    
    internal func startVideoTimer(seconds:Double) {
        if self.timerStarted {
            self.stopCollectionLoop()
        }
        self.isPlayingVideo = true
        self.timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(self.endOfVideoTimer(timer:)), userInfo: "timer", repeats: true)
    }
    
    internal func stopCollectionLoop() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    @objc func endOfVideoTimer(timer: Timer!) {
        self.isPlayingVideo = false
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        if self.timerStarted {
            self.startCollectionLoop()
        }
    }
    
    var years:[Int] = []
    var year = 0
    var dates:[String] = []
    
    private func presentDate(_ date:String) -> String{
        let parts = date.components(separatedBy: "-")
        return "\(parts[1])月\(parts[2])日"
    }
    
    private func dateFromPresent(_ date:String) -> String {
        let converted = date.replacingFirstOccurrence(of: "月", with: "-").replacingFirstOccurrence(of: "日", with: "")
        return "\(self.year)-\(converted)"
    }
    
    /// switch states of controls after user picked a specific year
    private func pickYear(year:Int) {
        // years
        self.year = year
        
        let now = Date()
        let calendar = Calendar.current
        let thisYear = calendar.component(.year, from: now)
        let gap = thisYear - year
        self.lblToday.stringValue = "\(gap)年前(\(year)年)"
        
        if let i = years.index(of: year) {
            if (i + 1) < years.count {
                let nextYear = years[i+1]
                self.btnNextYear.title = "\(nextYear)"
                self.btnNextYear.isEnabled = true
                self.btnNextYear.isHidden = false
            }else{
                // light off button of next year
                self.btnNextYear.isEnabled = false
                self.btnNextYear.isHidden = true
            }
            
            if (i - 1) < years.count && (i - 1) >= 0 {
                let lastYear = years[i-1]
                self.btnLastYear.title = "\(lastYear)"
                self.btnLastYear.isEnabled = true
                self.btnLastYear.isHidden = false
            }else{
                // light off button of last year
                self.btnLastYear.isEnabled = false
                self.btnLastYear.isHidden = true
            }
        }else{
            print("Invalid year number: \(year)")
            return
        }
        
        // dates
        
        // light off buttons
        self.btnDayAddOne.state = .off
        self.btnDayAddTwo.state = .off
        self.btnDayMinusOne.state = .off
        self.btnDayMinusTwo.state = .off
        self.btnToday.state = .off
        
        // disable buttons
        self.btnDayAddOne.isEnabled = false
        self.btnDayAddTwo.isEnabled = false
        self.btnDayMinusOne.isEnabled = false
        self.btnDayMinusTwo.isEnabled = false
        self.btnToday.isEnabled = false
        
        let pickedDates = ModelStore.default.getDatesByTodayInPrevious(year: year)
        self.dates.removeAll()
        
        // enable buttons if present
        for pickedDate in pickedDates {
            let value = self.presentDate(pickedDate)
            if value == self.btnDayMinusTwo.title {
                self.btnDayMinusTwo.isEnabled = true
            }else if value == self.btnDayMinusOne.title {
                self.btnDayMinusOne.isEnabled = true
            }else if value == self.btnDayAddTwo.title {
                self.btnDayAddTwo.isEnabled = true
            }else if value == self.btnDayAddOne.title {
                self.btnDayAddOne.isEnabled = true
            }else if value == self.btnToday.title {
                self.btnToday.isEnabled = true
            }
            print(value)
            self.dates.append(value)
        }
        
        // light on one of buttons, reload collections accordingly
        if self.btnToday.isEnabled {
            self.btnToday.state = .on
            let date = self.dateFromPresent(self.btnToday.title)
            self.reloadCollection(date: date)
        }else if self.btnDayMinusOne.isEnabled {
            self.btnDayMinusOne.state = .on
            let date = self.dateFromPresent(self.btnDayMinusOne.title)
            self.reloadCollection(date: date)
        }else if self.btnDayAddOne.isEnabled {
            self.btnDayAddOne.state = .on
            let date = self.dateFromPresent(self.btnDayAddOne.title)
            self.reloadCollection(date: date)
        }else if self.btnDayMinusTwo.isEnabled {
            self.btnDayMinusTwo.state = .on
            let date = self.dateFromPresent(self.btnDayMinusTwo.title)
            self.reloadCollection(date: date)
        }else if self.btnDayAddTwo.isEnabled {
            self.btnDayAddTwo.state = .on
            let date = self.dateFromPresent(self.btnDayAddTwo.title)
            self.reloadCollection(date: date)
        }
    }
    
    /// reload collection with images taken on specific date
    private func reloadCollection(date:String) {
        //print("reload collection on \(date)")
        let parts = date.components(separatedBy: "-")
        let year = Int(parts[0]) ?? 0
        let month = Int(parts[1]) ?? 0
        let day = Int(parts[2]) ?? 0
        self.reloadCollectionView(year: year, month: month, day: day)
    }
    
    func initView() {
        
        // load available years
        self.years = ModelStore.default.getYearsByTodayInPrevious()
        guard self.years.count > 0 else {return}
        
        // load dates present on buttons
        let aroundDates = ModelStore.default.getDatesAroundToday()
        self.btnDayMinusTwo.title = self.presentDate(aroundDates[0])
        self.btnDayMinusOne.title = self.presentDate(aroundDates[1])
        self.btnToday.title = self.presentDate(aroundDates[2])
        self.btnDayAddOne.title = self.presentDate(aroundDates[3])
        self.btnDayAddTwo.title = self.presentDate(aroundDates[4])
        
        self.pickYear(year: years[0])
    }
    
    @IBAction func onLastYearClicked(_ sender: NSButton) {
        self.pickYear(year: Int(self.btnLastYear.title) ?? 0)
    }
    
    @IBAction func onNextYearClicked(_ sender: NSButton) {
        self.pickYear(year: Int(self.btnNextYear.title) ?? 0)
    }
    
    @IBAction func onTodayClicked(_ sender: NSButton) {
        self.btnDayAddOne.state = .off
        self.btnDayAddTwo.state = .off
        self.btnDayMinusOne.state = .off
        self.btnDayMinusTwo.state = .off
        self.btnToday.state = .on
        
        let date = self.dateFromPresent(self.btnToday.title)
        self.reloadCollection(date: date)
    }
    
    @IBAction func onDayMinusTwoClicked(_ sender: NSButton) {
        self.btnDayAddOne.state = .off
        self.btnDayAddTwo.state = .off
        self.btnDayMinusOne.state = .off
        self.btnDayMinusTwo.state = .on
        self.btnToday.state = .off
        
        let date = self.dateFromPresent(self.btnDayMinusTwo.title)
        self.reloadCollection(date: date)
    }
    
    @IBAction func onDayMinusOneClicked(_ sender: NSButton) {
        self.btnDayAddOne.state = .off
        self.btnDayAddTwo.state = .off
        self.btnDayMinusOne.state = .on
        self.btnDayMinusTwo.state = .off
        self.btnToday.state = .off
        
        let date = self.dateFromPresent(self.btnDayMinusOne.title)
        self.reloadCollection(date: date)
    }
    
    @IBAction func onDayAddOneClicked(_ sender: NSButton) {
        self.btnDayAddOne.state = .on
        self.btnDayAddTwo.state = .off
        self.btnDayMinusOne.state = .off
        self.btnDayMinusTwo.state = .off
        self.btnToday.state = .off
        
        let date = self.dateFromPresent(self.btnDayAddOne.title)
        self.reloadCollection(date: date)
    }
    
    @IBAction func onDayAddTwoClicked(_ sender: NSButton) {
        self.btnDayAddOne.state = .off
        self.btnDayAddTwo.state = .on
        self.btnDayMinusOne.state = .off
        self.btnDayMinusTwo.state = .off
        self.btnToday.state = .off
        
        let date = self.dateFromPresent(self.btnDayAddTwo.title)
        self.reloadCollection(date: date)
    }
    
    @IBAction func onMenuClicked(_ sender: NSButton) {
        // TODO: menus: export to local folder, share to facebook, larger view, open in tree
    }
    
    @IBAction func onHideClicked(_ sender: NSButton) {
        if let imageFile = self.selectedImageFile {
            // remove item and reload collection
            DispatchQueue.global().async {
                imageFile.hide()
                self.selectedIndex -= 1
                
                if self.selectedIndex < 0 {
                    self.selectedIndex = 0
                }
                
                self.reloadCollectionView(year: self.selectYear, month:self.selectMonth, day:self.selectDay, focusIndex: self.selectedIndex)
            }
            
        }
    }
    
    @IBAction func onPlayClicked(_ sender: NSButton) {
        if self.btnPlay.image == playIcon {
            self.btnPlay.image = pauseIcon
            self.timerStarted = true
            self.startCollectionLoop()
        }else{
            self.btnPlay.image = playIcon
            self.timerStarted = false
            self.stopCollectionLoop()
        }
    }
    
    internal var isPlayingVideo = false
    
    internal var previewView:QLPreviewView? = nil
    
    private func previewImage(image:ImageFile){
        
        if self.previewView == nil {
            self.preview.wantsLayer = true
            self.preview.subviews.removeAll()
            previewView = QLPreviewView(frame: NSRect(x: 0, y: 0, width:
                self.preview.visibleRect.width, height:
                self.preview.visibleRect.height), style: .normal)
            previewView?.wantsLayer = true
            previewView?.autostarts = true
            previewView?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
            self.preview.addSubview(previewView!)
        }
        
        if let data = image.imageData, let duration = data.videoDuration {
            var seconds = 1.0
            if duration.hasSuffix(" s") {
                seconds = Double(duration.replacingFirstOccurrence(of: " s", with: "")) ?? 0.0
            }else{
                let parts = duration.components(separatedBy: ":")
                let hours = Double(parts[0]) ?? 0.0
                let minutes = Double(parts[1]) ?? 0.0
                let secs = Double(parts[2]) ?? 0.0
                seconds = secs + minutes * 60 + hours * 3600
            }
            let interval = 2.0 // interval of looping timer is 4 seconds, i.e. next image will be shown after (+ 4 - 2) seconds
            if (seconds - interval) > 0.0 {
                self.startVideoTimer(seconds: seconds - interval)
            }else{
                self.startVideoTimer(seconds: seconds)
            }
        }
        
        let quickLookItem = TheaterQuickLookItem()
        quickLookItem.previewItemURL = image.url
        previewView?.previewItem = quickLookItem
        
//        self.previewView?.animator().alphaValue = 0
//        NSAnimationContext.runAnimationGroup({ (context) in
//            context.duration = 4.0
//            self.previewView?.animator().alphaValue = 1
//        }) {
//            self.previewView?.animator().alphaValue = 0
//        }
        
        if let data = image.imageData {
            let content = """
\(data.event ?? "") \(data.shortDescription ?? "") \(data.assignPlace ?? data.place ?? "")
\(data.longDescription ?? "")
""".trimmingCharacters(in: .whitespacesAndNewlines)
            self.lblDescription.stringValue = content
        }
        
        self.selectedImageFile = image
        
    }
    
}

// MARK: COLLECTION VIEW

extension MemoriesViewController {
    
    
    private func configureCollectionView() {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "MemoriesViews"), bundle: nil)
        
        collectionViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "memoriesCollectionView")) as! MemoriesCollectionViewController
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
        
        collectionViewController.imagesLoader.singleSectionMode = true
        collectionViewController.imagesLoader.showHidden = false
        collectionViewController.imagesLoader.clean()
        collectionViewController.collectionView.reloadData()
        
        collectionViewController.onItemClicked = { imageFile in
            if self.timerStarted {
                self.stopCollectionLoop()
            }
            self.selectImage(imageFile: imageFile)
            self.previewImage(image: imageFile)
            
            if self.timerStarted {
                self.startCollectionLoop()
            }
        }
    }
    
    
    @objc func selectNextItem(timer: Timer!) {
        guard self.collectionViewController != nil && self.collectionViewController.imagesLoader.getItems().count  > 0 else {return}
        // TODO: return if video has not ended
        var next = self.selectedIndex + 1
        if next >= self.collectionViewController.imagesLoader.getItems().count {
            next = 0
        }
        self.selectItem(at: next, forceFocus: true)
        self.selectedIndex = next
    }
    
    private func reloadCollectionView(year:Int, month:Int, day:Int, focusIndex:Int = 0){
        self.selectYear = year
        self.selectMonth = month
        self.selectDay = day
        if self.timerStarted {
            self.stopCollectionLoop()
        }
        DispatchQueue.global().async {
            
            self.collectionViewController.imagesLoader.clean()
            let images = ModelStore.default.getImagesByDate(year: year, month:month, day:day)
            self.collectionViewController.imagesLoader.setupItems(photoFiles: images)
            self.collectionViewController.imagesLoader.reorganizeItems(considerPlaces: false)
            
            DispatchQueue.main.async {
                self.collectionViewController.collectionView.reloadData()
                self.selectItem(at: focusIndex)
                
                
                if let image = self.collectionViewController.imagesLoader.getItem(at: focusIndex) {
                    self.selectedIndex = focusIndex
                    self.previewImage(image: image)
                }
                
                if self.timerStarted {
                    self.startCollectionLoop()
                }
            }
        }
    }
    
    private func selectImage(imageFile:ImageFile){
        if let index = self.collectionViewController.imagesLoader.getItemIndex(path: imageFile.url.path) {
            self.selectItem(at: index)
        }
    }
    
    private func selectItem(at index:Int, forceFocus:Bool = false){
        //print("select index: \(index)")
        if index >= 0 && index < self.collectionViewController.imagesLoader.getItems().count {
            //print("select image \(index)")
            let indexPath:IndexPath = IndexPath(item: index, section: 0)
            let indexSet:Set<IndexPath> = [indexPath]
            
            if forceFocus {
                self.collectionViewController.cleanHighlights()
            }
            self.collectionViewController.collectionView.selectItems(at: indexSet, scrollPosition: .centeredHorizontally)
            if forceFocus {
                self.collectionViewController.highlightItems(selected: true, atIndexPaths: indexSet)
            }
            self.selectedIndex = index
        }
    }
    
    private func selectItem(offset:Int){
        print("select offset: \(offset)")
        self.selectItem(at: self.selectedIndex + offset, forceFocus: true)
    }
}
