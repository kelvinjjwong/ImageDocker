//
//  SelectionViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/28.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class SelectionViewController : NSViewController {
    
    let logger = LoggerFactory.get(category: "SelectionViewController")
    
    var collectionViewController : SelectionCollectionViewController!
    
    @IBOutlet weak var selectionCollectionView: NSCollectionView!
    
    @IBOutlet weak var btnBatchEditorToolbarSwitcher: NSButton!
    @IBOutlet weak var comboEventList: NSComboBox!
    @IBOutlet weak var btnAssignEvent: NSButton!
    @IBOutlet weak var btnPeople: NSButton!
    @IBOutlet weak var btnDatePicker: NSButton!
    @IBOutlet weak var btnNotes: NSButton!
    @IBOutlet weak var btnDuplicates: NSPopUpButton!
    @IBOutlet weak var batchEditIndicator: NSProgressIndicator!
    
    
    @IBOutlet weak var btnShare: NSButton!
    @IBOutlet weak var btnCopyToDevice: NSButton!
    @IBOutlet weak var btnShow: NSButton!
    @IBOutlet weak var btnHide: NSButton!
    @IBOutlet weak var selectionCheckAllBox: NSButton!
    @IBOutlet weak var btnRemoveSelection: NSButton!
    @IBOutlet weak var btnRemoveAllSelection: NSButton!
    
    var isSmallScreen: ( () -> Bool )?
    var reloadMainCollectionView: ( () -> Void )?
    var selectImage: ( (ImageFile) -> Void )?
    var getMainCollectionVisibleItems: ( () -> [CollectionViewItem] )?
    var selectAllInMainCollectionView: ( (Bool) -> Void )?
    
    var eventListController:EventListComboController!
    
    var calendarPopover:NSPopover? = nil
    var calendarViewController:DateTimeViewController!
    
    var notesPopover:NSPopover? = nil
    var notesViewController:NotesViewController!
    
    var copyToDevicePopover:NSPopover? = nil
    var deviceFolderViewController:DeviceFolderViewController!
    
    var peopleSelectionPopover:NSPopover? = nil
    var peopleSelectionViewController:PeopleSelectionViewController!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initView(editors:[ImageFlowListItemEditor]) {
        self.configureCollectionView(editors:editors)
        
        batchEditIndicator.isDisplayedWhenStopped = false
        batchEditIndicator.isHidden = true
        comboEventList.isEditable = false
//        comboPlaceList.isEditable = false
        self.btnShare.sendAction(on: .leftMouseDown)
//        self.logger.log("Loading view - setup event list")
        setupEventList()
        self.btnAssignEvent.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboEventList.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.comboEventList.backgroundColor = Colors.DeepDarkGray
        self.btnBatchEditorToolbarSwitcher.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.selectionCheckAllBox.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.selectionCollectionView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnShow.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        self.btnHide.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.applyLocalization()
    }
    
    func applyLocalization() {
        self.btnAssignEvent.title = Words.assignEvent.word()
        self.btnDatePicker.title = Words.changeDate.word()
        self.btnNotes.title = Words.writeNotes.word()
        self.btnDuplicates.title = Words.duplicates.word()
        self.btnDuplicates.image = Icons.duplicates
        self.btnDuplicates.item(at: 0)?.image = Icons.duplicates
        self.selectionCheckAllBox.title = Words.selectAll.word()
        self.btnPeople.title = Words.peopleManage.word()
    }
    
    func openDatePicker(with referenceDate:String? = nil) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.openDatePicker(self.btnDatePicker, with: referenceDate)
    }
    
    
    @IBAction func onBatchEditorToolbarSwitcherClicked(_ sender: NSButton) {
        self.switchSelectionToolbar()
    }
    
    @IBAction func onAssignEventButtonClicked(_ sender: Any) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.assignEvent()
    }
    
    @IBAction func onButtonPeopleClicked(_ sender: NSButton) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.openPeopleSelection(sender)
    }
    
    @IBAction func onButtonDatePickerClicked(_ sender: NSButton) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.openDatePicker(sender)
    }
    
    @IBAction func onButtonNotesClicked(_ sender: NSButton) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.openNoteWriter(sender)
    }
    
    @IBAction func onButtonDuplicatesClicked(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.selectCombineMenuInSelectionArea(i, selectedImageIds: selectedImageIds)
    }
    
    @IBAction func onShareClicked(_ sender: NSButton) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.share(sender)
    }
    
    @IBAction func onCopyToDeviceClicked(_ sender: NSButton) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.openExportToDeviceDialog(sender)
    }
    
    @IBAction func onButtonShowClicked(_ sender: Any) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.visibleSelectedImages()
    }
    
    @IBAction func onButtonHideClicked(_ sender: Any) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.hideSelectedImages()
    }
    
    @IBAction func onSelectionCheckAllClicked(_ sender: NSButton) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.checkAllInSelectionArea()
    }
    
    @IBAction func onSelectionRemoveButtonClicked(_ sender: Any) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.cleanSomeFromSelectionArea()
    }
    
    @IBAction func onSelectionRemoveAllClicked(_ sender: Any) {
        let selectedImageIds = self.collectionViewController.imagesLoader.getItems().map { imageFile in
            if let image = imageFile.imageData, let imageId = image.id {
                return imageId
            }else{
                return ""
            }
        }
        for editor in editors {
            editor.removeAllImageFlowListItems()
        }
        self.logger.log("selected image ids: \(selectedImageIds)")
        self.cleanUpSelectionArea()
    }
    
    var editors:[ImageFlowListItemEditor] = []
    
    func configureCollectionView(editors:[ImageFlowListItemEditor]){
        
        self.editors = editors
        
        // init controller
        collectionViewController = storyboard?.instantiateController(withIdentifier: "selectionCollectionViewController") as? SelectionCollectionViewController
        collectionViewController.onItemClicked = { image in
            self.selectImage?(image)
//            self.selectImageFile(image)
        }
        self.addChild(collectionViewController)
        
        
        
        // outlet
        self.selectionCollectionView.dataSource = collectionViewController
        self.selectionCollectionView.delegate = collectionViewController
        
        // flow layout
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 180.0, height: 150.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.minimumLineSpacing = 2.0
        selectionCollectionView.collectionViewLayout = flowLayout
        
        // view layout
        selectionCollectionView.wantsLayer = true
        selectionCollectionView.backgroundColors = [Colors.DeepDarkGray]
        selectionCollectionView.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        selectionCollectionView.layer?.borderColor = Colors.DeepDarkGray.cgColor
        
        // data model
//        self.selectionCollectionView = collectionViewController.collectionView
//        self.selectionCollectionView.addSubview(collectionViewController.view)
        collectionViewController.collectionView = self.selectionCollectionView
        collectionViewController.imagesLoader.singleSectionMode = true
        collectionViewController.imagesLoader.clean()
        
        selectionCollectionView.reloadData()
        
        
        
    }
    
    func addItem(imageFile:ImageFile) {
        self.collectionViewController.imagesLoader.addItem(imageFile)
        self.collectionViewController.imagesLoader.reorganizeItems()
        //self.collectionView.reloadData()
        self.selectionCollectionView.reloadData()
        
        for editor in editors {
            editor.addImageFlowListItem(imageFile: imageFile)
        }
    }
    
    
    func hideSelectionToolbar() {
        self.btnShare.isHidden = true
        self.btnCopyToDevice.isHidden = true
        self.btnShow.isHidden = true
        self.btnHide.isHidden = true
        self.selectionCheckAllBox.isHidden = true
        self.btnRemoveSelection.isHidden = true
        self.btnRemoveAllSelection.isHidden = true
        self.btnPeople.isHidden = true
    }
    
    func showSelectionToolbar() {
        self.btnShare.isHidden = false
        self.btnCopyToDevice.isHidden = false
        self.btnShow.isHidden = false
        self.btnHide.isHidden = false
        self.selectionCheckAllBox.isHidden = false
        self.btnRemoveSelection.isHidden = false
        self.btnRemoveAllSelection.isHidden = false
        self.btnPeople.isHidden = false
        
    }
    
    func switchSelectionToolbar() {
        
        if self.btnBatchEditorToolbarSwitcher.image == NSImage(named: NSImage.goLeftTemplateName) {
            self.hideSelectionBatchEditors()
            if self.isSmallScreen?() ?? false {
                self.showSelectionToolbar()
            }
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.goRightTemplateName)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Show event/datetime selectors"
        } else {
            self.showSelectionBatchEditors()
            if self.isSmallScreen?() ?? false {
                self.hideSelectionToolbar()
            }
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.goLeftTemplateName)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Hide event/datetime selectors"
        }
    }
    
    func hideSelectionBatchEditors() {
        self.comboEventList.isHidden = true
        self.btnAssignEvent.isHidden = true
        self.btnDatePicker.isHidden = true
        self.btnNotes.isHidden = true
        self.btnDuplicates.isHidden = true
    }
    
    func showSelectionBatchEditors() {
        self.comboEventList.isHidden = false
        self.btnAssignEvent.isHidden = false
        self.btnDatePicker.isHidden = false
        self.btnNotes.isHidden = false
        self.btnDuplicates.isHidden = false
    }
    
    func cleanUpSelectionArea() {
        // remove from selection
        var images:Set<String> = []
        for image in self.collectionViewController.imagesLoader.getItems() {
            images.insert(image.url.path)
        }
        self.collectionViewController.imagesLoader.clean()
        self.selectionCollectionView.reloadData()
        
        
        // uncheck in browser if exists there (if user changed to another folder, it won't be there)
        for item in self.getMainCollectionVisibleItems?() ?? [] {
            if images.contains((item.imageFile?.url.path)!) {
                item.uncheck()
            }
        }
        self.selectionCheckAllBox.state = NSButton.StateValue.off
        
        self.selectAllInMainCollectionView?(false)
//        self.chbSelectAll.state = NSButton.StateValue.off
    }
    
    func removeOneFromSelectionArea(_ imageFile:ImageFile) {
        // remove from editors
        for editor in editors {
            editor.removeImageFlowListItem(imageFile: imageFile)
        }
        
        self.collectionViewController.imagesLoader.removeItem(imageFile)
        self.collectionViewController.imagesLoader.reorganizeItems()
        //self.selectionViewController.collectionView.reloadData()
        self.selectionCollectionView.reloadData()
    }
    
    func cleanSomeFromSelectionArea() {
        // collect which to be removed from selection
        var images:[ImageFile] = [ImageFile]()
        for item in self.selectionCollectionView.visibleItems() {
            let item = item as! CollectionViewItem
            if item.isChecked() {
                images.append(item.imageFile!)
            }
        }
        
        // remove from editors
        for imageFile in images {
            for editor in editors {
                editor.removeImageFlowListItem(imageFile: imageFile)
            }
        }
        
        // remove from selection
        for image in images {
            self.collectionViewController.imagesLoader.removeItem(image)
        }
        self.collectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        
        // uncheck in browser if exists there (if user changed to another folder, it won't be there)
        for item in self.getMainCollectionVisibleItems?() ?? [] {
            let i = images.firstIndex(where: { $0.url == item.imageFile?.url })
            if i != nil {
                item.uncheck()
            }
        }
        self.selectionCheckAllBox.state = NSButton.StateValue.off
    }
    
    func checkAllInSelectionArea() {
        if self.collectionViewController.imagesLoader.getItems().count == 0 {
            self.selectionCheckAllBox.state = NSButton.StateValue.off
            return
        }
        if self.selectionCheckAllBox.state == NSButton.StateValue.on {
            for i in 0...self.collectionViewController.imagesLoader.getItems().count-1 {
                let itemView = self.selectionCollectionView.item(at: i) as? CollectionViewItem
                if itemView != nil {
                    itemView!.check()
                }
            }
        }else {
            for i in 0...self.collectionViewController.imagesLoader.getItems().count-1 {
                let itemView = self.selectionCollectionView.item(at: i) as? CollectionViewItem
                if itemView != nil {
                    itemView!.uncheck()
                }
            }
        }
    }
    
    func hideSelectedImages() {
        guard self.collectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.collectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        for item:ImageFile in self.collectionViewController.imagesLoader.getItems() {
            item.hide()
            let _ = accumulator.add()
        }
        //ModelStore.save()
        self.collectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        self.reloadMainCollectionView?()
//        self.imagesLoader.reorganizeItems()
//        self.collectionView.reloadData()
    }
    
    func visibleSelectedImages() {
        guard self.collectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.collectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        for item:ImageFile in self.collectionViewController.imagesLoader.getItems() {
            item.show()
            let _ = accumulator.add()
        }
        //ModelStore.save()
        self.collectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        self.reloadMainCollectionView?()
//        self.imagesLoader.reorganizeItems()
//        self.collectionView.reloadData()
    }
    
}

extension SelectionViewController : NSPopoverDelegate {
    
}
