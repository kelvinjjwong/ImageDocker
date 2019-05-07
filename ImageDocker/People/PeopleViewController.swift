//
//  PeopleViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/22.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class PeopleViewController: NSViewController {
    
    // MARK: CONSTANTS
    
    fileprivate let FamilyTypes:[String] = ["家人", "亲戚", "家族", "同事", "朋友", "同学", "校友"]
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var iconCollectionView: NSCollectionView!
    @IBOutlet weak var txtPeopleId: NSTextField!
    @IBOutlet weak var txtPeopleName: NSTextField!
    @IBOutlet weak var txtPeopleNickName: NSTextField!
    @IBOutlet weak var btnSaveId: NSButton!
    @IBOutlet weak var tblFaceYear: NSTableView!
    @IBOutlet weak var tblFaceMonth: NSTableView!
    @IBOutlet weak var faceCollectionView: NSCollectionView!
    @IBOutlet weak var imgFacePreview: NSImageView!
    @IBOutlet weak var chkIcon: NSButton!
    @IBOutlet weak var btnDifferentPerson: NSButton!
    @IBOutlet weak var lstPeople: NSPopUpButton!
    @IBOutlet weak var txtCallAs: NSTextField!
    @IBOutlet weak var txtBeCalledAs: NSTextField!
    @IBOutlet weak var btnSaveCall: NSButton!
    @IBOutlet weak var tblRelationship: NSTableView!
    @IBOutlet weak var tblFamily: NSTableView!
    @IBOutlet weak var imgSourcePreview: NSImageView!
    @IBOutlet weak var lblSourceDate: NSTextField!
    @IBOutlet weak var lblSourceDescription: NSTextField!
    @IBOutlet weak var btnSourceLargerView: NSButton!
    @IBOutlet weak var chkSample: NSButton!
    @IBOutlet weak var txtFamilyName: NSTextField!
    @IBOutlet weak var lblFamilyName: NSTextField!
    @IBOutlet weak var btnChangeFamilyName: NSButton!
    @IBOutlet weak var btnDeleteFamily: NSButton!
    @IBOutlet weak var btnCreateFamily: NSButton!
    @IBOutlet weak var lblCall: NSTextField!
    @IBOutlet weak var lblAs: NSTextField!
    @IBOutlet weak var lblBeCalledAs: NSTextField!
    @IBOutlet weak var boxFamily: NSBox!
    @IBOutlet weak var boxRelationship: NSBox!
    @IBOutlet weak var lblRelationshipMessage: NSTextField!
    @IBOutlet weak var lstFamilyType: NSPopUpButton!
    @IBOutlet weak var lblFamilyMessage: NSTextField!
    @IBOutlet weak var lblFaceDescription: NSTextField!
    @IBOutlet weak var btnRecognize: NSButton!
    @IBOutlet weak var lblIdentityMessasge: NSTextField!
    @IBOutlet weak var btnTraining: NSButton!
    @IBOutlet weak var btnRecognizeAll: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lblProgressMessage: NSTextField!
    @IBOutlet weak var chkLock: NSButton!
    
    
    
    var iconCollectionViewController : FaceIconCollectionViewController!
    var faceCollectionViewController : FaceCollectionViewController!
    
    var faceCategoryController : SingleColumnTableViewController!
    var faceSubCategoryController : SingleColumnTableViewController!
    
    var peopleListController : TextListViewPopupController!
    var relationshipTableController : DictionaryTableViewController!
    
    var familyTypesListController : TextListViewPopupController!
    var familyTableController : DictionaryTableViewController!
    
    var menuPopover : MenuPopover!
    var menuRecognizeUnknown : MenuPopover!
    
    // MARK: INIT
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "PeopleViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureControllers()
    }
    
    fileprivate func configureControllers() {
        self.progressIndicator.isHidden = true
        self.progressIndicator.isDisplayedWhenStopped = false
        
        self.iconCollectionViewController = (storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "faceIconCollectionView")) as! FaceIconCollectionViewController)
        self.iconCollectionView.delegate = self.iconCollectionViewController
        self.iconCollectionView.dataSource = self.iconCollectionViewController
        self.iconCollectionViewController.collectionView = self.iconCollectionView
        
        self.iconCollectionViewController.onItemClicked = { face in
            self.selectIcon(face)
        }
        
        // flow layout
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 100.0, height: 95.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 0.0, left: 0, bottom: 0.0, right: 0.0)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 1.0
        self.iconCollectionView.collectionViewLayout = flowLayout
        
        // view layout
        self.iconCollectionView.wantsLayer = true
        //self.iconCollectionView.backgroundColors = [NSColor.darkGray]
        //self.iconCollectionView.layer?.backgroundColor = NSColor.darkGray.cgColor
        //self.iconCollectionView.layer?.borderColor = NSColor.darkGray.cgColor
        
        self.faceCollectionViewController = (storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "faceCollectionView")) as! FaceCollectionViewController)
        self.faceCollectionViewController.withoutName()
        self.faceCollectionView.delegate = self.faceCollectionViewController
        self.faceCollectionView.dataSource = self.faceCollectionViewController
        self.faceCollectionViewController.collectionView = self.faceCollectionView
        
        self.faceCollectionViewController.onItemClicked = { face in
            self.selectFace(face)
        }
        
        // flow layout
        let flowLayout2 = NSCollectionViewFlowLayout()
        flowLayout2.itemSize = NSSize(width: 60.0, height: 60.0)
        flowLayout2.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout2.minimumInteritemSpacing = 0
        flowLayout2.minimumLineSpacing = 1
        self.faceCollectionView.collectionViewLayout = flowLayout2
        
        // view layout
        self.faceCollectionView.wantsLayer = true
        //self.faceCollectionView.backgroundColors = [NSColor.darkGray]
        //self.faceCollectionView.layer?.backgroundColor = NSColor.darkGray.cgColor
        //self.faceCollectionView.layer?.borderColor = NSColor.darkGray.cgColor
        
        self.faceCategoryController = SingleColumnTableViewController(self.tblFaceYear)
        self.faceCategoryController.onClick = { value in
            self.onFaceCategoryClicked(value)
        }
        self.faceSubCategoryController = SingleColumnTableViewController(self.tblFaceMonth)
        self.faceSubCategoryController.onClick = { value in
            self.onFaceSubCategoryClicked(value)
        }
        
        self.peopleListController = TextListViewPopupController(self.lstPeople)
        self.relationshipTableController = DictionaryTableViewController(self.tblRelationship)
        self.relationshipTableController.onClick = { relationship in
            if let otherId = relationship["otherId"], let callAs = relationship["callAs"], let beCalledAs = relationship["beCalledAs"] {
                self.onRelationshipSelected(otherId: otherId, callAs: callAs, beCalledAs: beCalledAs)
            }
        }
        
        self.familyTypesListController = TextListViewPopupController(self.lstFamilyType)
        self.familyTypesListController.load(FamilyTypes)
        
        self.familyTableController = DictionaryTableViewController(self.tblFamily)
        self.familyTableController.onClick = { family in
            if let id = family["id"],
               let name = family["name"],
               let type = family["type"],
                let checked = family["checkbox"] {
                self.onFamilySelected(id: id, name: name, type: type, checked: checked)
            }
        }
        self.familyTableController.onCheck = { id, checked in
            self.onFamilyCheck(id: id, checked: checked)
        }
        
        self.lblFamilyMessage.stringValue = ""
        
        self.menuPopover = MenuPopover() { id, name, action in
            self.onDifferentPersonClicked(id: id, name: name)
        }
        
        self.menuRecognizeUnknown = MenuPopover(width: 230, height: 150) { id, name, action in
            self.onRecognizeUnknownClicked(id: id)
        }
    }
    
    func initView() {
        self.cleanIdentity()
        self.cleanFaceCollection()
        self.cleanFaceInfo()
        self.cleanSourceInfo()
        self.cleanRelationship()
        self.faceCategoryController.clean()
        self.faceSubCategoryController.clean()
        
        self.loadIcons()
        self.adjustButtonsForUnknownFace(preview: false)
        
        self.lblIdentityMessasge.stringValue = ""
        self.lblFamilyMessage.stringValue = ""
        self.lblRelationshipMessage.stringValue = ""
        
        self.selectedFamilyType = ""
        self.selectedFamilyName = ""
        self.selectedFamilyId = ""
        self.selectedPeopleId = ""
        self.selectedFaceId = ""
        self.selectedCategory = ""
        self.selectedSubCategory = ""
    }
    
    fileprivate func cleanIdentity() {
        self.txtPeopleId.stringValue = ""
        self.txtPeopleName.stringValue = ""
        self.txtPeopleNickName.stringValue = ""
        self.lblIdentityMessasge.stringValue = ""
    }
    
    fileprivate func cleanFaceInfo() {
        self.imgFacePreview.image = nil
        self.chkIcon.state = .off
        self.chkSample.state = .off
        self.chkLock.state = .off
        self.lblFaceDescription.stringValue = ""
        // TODO: set face table views to empty
        // TODO: set face collection to empty
    }
    
    fileprivate func cleanSourceInfo() {
        self.imgSourcePreview.image = nil
        self.lblSourceDate.stringValue = ""
        self.lblSourceDescription.stringValue = ""
    }
    
    fileprivate func cleanRelationship() {
        self.txtCallAs.stringValue = ""
        self.txtBeCalledAs.stringValue = ""
        self.lblRelationshipMessage.stringValue = ""
        // TODO: set table view to empty
        // TODO: reset family table view
    }
    
    fileprivate func cleanFaceCollection() {
        self.faceCollectionViewController.imagesLoader.clean()
        self.faceCollectionView.reloadData()
    }
    
    fileprivate func adjustButtonsForUnknownFace(preview:Bool) {
        if preview {
            self.btnDifferentPerson.isHidden = false
            self.btnRecognize.isHidden = false
            self.btnSourceLargerView.isHidden = false
            self.lblSourceDate.isHidden = false
            self.lblSourceDescription.isHidden = false
            self.chkLock.isHidden = false
        }else{
            self.btnDifferentPerson.isHidden = true
            self.btnRecognize.isHidden = true
            self.btnSourceLargerView.isHidden = true
            self.lblSourceDate.isHidden = true
            self.lblSourceDescription.isHidden = true
            self.chkLock.isHidden = true
        }
        self.chkIcon.isHidden = true
        self.chkSample.isHidden = true
        self.boxFamily.isHidden = true
        self.boxRelationship.isHidden = true
        
        self.txtPeopleId.isEnabled = true
        self.btnSaveId.title = "Create Identity"
        self.btnDifferentPerson.title = "Assign Person"
    }

    fileprivate func adjustButtonsForKnownFace(preview:Bool) {
        if preview {
            self.chkIcon.isHidden = false
            self.chkSample.isHidden = false
            self.chkLock.isHidden = false
            self.btnDifferentPerson.isHidden = false
            self.btnRecognize.isHidden = false
            self.btnSourceLargerView.isHidden = false
            self.lblSourceDate.isHidden = false
            self.lblSourceDescription.isHidden = false
        }else{
            self.chkIcon.isHidden = true
            self.chkSample.isHidden = true
            self.chkLock.isHidden = true
            self.txtPeopleId.isEnabled = true
            self.btnDifferentPerson.isHidden = true
            self.btnRecognize.isHidden = true
            self.btnSourceLargerView.isHidden = true
            self.lblSourceDate.isHidden = true
            self.lblSourceDescription.isHidden = true
        }
        self.boxFamily.isHidden = false
        self.boxRelationship.isHidden = false
        
        self.txtPeopleId.isEnabled = false
        self.btnSaveId.title = "Update Identity"
        self.btnDifferentPerson.title = "Different Person"
    }
    
    var selectedPeopleId = ""
    var peopleList:[People] = []
    var peopleDictionary:[String:People] = [:]
    
    fileprivate func selectIcon(_ face:PeopleFace) {
        self.cleanIdentity()
        
        self.cleanFaceInfo()
        self.cleanSourceInfo()
        self.cleanRelationship()
        
        if face.personName != "Unknown" {
            self.adjustButtonsForKnownFace(preview: false)
            self.txtPeopleId.stringValue = face.person?.id ?? ""
            self.txtPeopleName.stringValue = face.person?.name ?? ""
            self.txtPeopleNickName.stringValue = face.person?.shortName ?? ""
        }else{
            self.adjustButtonsForUnknownFace(preview: false)
        }
        self.selectedPeopleId = face.person?.id ?? ""
        if self.selectedPeopleId == "" {
            self.cleanFaceCollection()
        }else{
            self.faceCollectionViewController.imagesLoader.loadFaces(peopleId: self.selectedPeopleId, sample:true)
            self.faceCollectionView.reloadData()
            
            self.peopleList = ModelStore.default.getPeople(except: self.selectedPeopleId)
            var names:[String] = []
            if self.peopleList.count > 0 {
                for person in self.peopleList {
                    names.append(person.name)
                    peopleDictionary[person.id] = person
                }
            }
            self.peopleListController.load(names)
            self.loadRelationships()
            self.loadFamilies()
        }
        
        var categories:[String] = self.selectedPeopleId == "" ? [] : ["Samples"]
        categories.append(contentsOf: ModelStore.default.getYearsOfFaceCrops(peopleId: self.selectedPeopleId))
        self.faceCategoryController.load(categories)
        self.faceSubCategoryController.clean()
        
    }
    
    fileprivate func loadRelationships() {
        let relationships = ModelStore.default.getRelationships(peopleId: self.selectedPeopleId)
        var calls:[String:String] = [:]
        var becalls:[String:String] = [:]
        if relationships.count > 0 {
            for relationship in relationships {
                if relationship["primary"] == self.selectedPeopleId {
                    if let otherId = relationship["secondary"], let name = relationship["callName"] {
                        calls[otherId] = name
                    }
                }else if relationship["secondary"] == self.selectedPeopleId {
                    if let otherId = relationship["primary"], let name = relationship["callName"] {
                        becalls[otherId] = name
                    }
                }
            }
        }
        
        var myRelationships:[[String:String]] = []
        if calls.count > 0 {
            for otherId in calls.keys {
                if let callAs = calls[otherId], let beCalledAs = becalls[otherId] {
                    var myRelationship:[String:String] = [:]
                    myRelationship["otherId"] = otherId
                    myRelationship["otherName"] = peopleDictionary[otherId]?.name ?? ""
                    myRelationship["callAs"] = callAs
                    myRelationship["beCalledAs"] = beCalledAs
                    myRelationships.append(myRelationship)
                }
            }
        }
        print("my relationships: \(myRelationships.count)")
        self.relationshipTableController.load(myRelationships)
    }
    
    fileprivate func loadFamilies() {
        var myFamilies:[[String:String]] = []
        let families = ModelStore.default.getFamilies()
        let choices = ModelStore.default.getFamilies(peopleId: self.selectedPeopleId)
        if families.count > 0 {
            for family in families {
                var myFamily:[String:String] = [:]
                myFamily["id"] = family.id
                myFamily["name"] = family.name
                myFamily["type"] = family.category ?? ""
                if choices.count > 0 && choices.contains(family.id) {
                    myFamily["checkbox"] = "true"
                }else{
                    myFamily["checkbox"] = "false"
                }
                myFamilies.append(myFamily)
            }
        }
        self.familyTableController.load(myFamilies)
        
    }
    
    fileprivate var selectedFaceId:String = ""
    
    fileprivate func selectFace(_ face:PeopleFace) {
        self.cleanFaceInfo()
        self.selectedFaceId = face.data.id
        
        if self.selectedPeopleId == "Unknown" || self.selectedPeopleId == "" {
            self.adjustButtonsForUnknownFace(preview: true)
        }else{
            self.adjustButtonsForKnownFace(preview: true)
        }
        
        face.reloadData()
        
        self.lblFaceDescription.stringValue = face.personName
        
        self.imgFacePreview.image = face.preview
        if face.data.sampleChoice {
            self.chkSample.state = .on
        }else{
            self.chkSample.state = .off
        }
        if face.data.iconChoice {
            self.chkIcon.state = .on
        }else{
            self.chkIcon.state = .off
        }
        if face.data.locked {
            self.chkLock.state = .on
        }else{
            self.chkLock.state = .off
        }
        
        self.cleanSourceInfo()
        self.imgSourcePreview.image = face.sourceImage
        self.lblSourceDate.stringValue = "\(face.data.imageDate?.description ?? "")" // TODO: timezone maybe wrong
        self.lblSourceDescription.stringValue = face.sourceDescription
        
    }
    
    fileprivate func loadIcons() {
        self.iconCollectionViewController.imagesLoader.loadIcons()
        self.iconCollectionView.reloadData()
    }
    
    var selectedCategory = ""
    var selectedSubCategory = ""
    
    fileprivate func onFaceCategoryClicked(_ value:String){
        self.cleanFaceInfo()
        self.cleanSourceInfo()
        self.selectedCategory = value
        
        if value == "Samples" {
            self.adjustButtonsForUnknownFace(preview: false)
            self.faceSubCategoryController.clean()
            self.faceCollectionViewController.imagesLoader.loadFaces(peopleId: self.selectedPeopleId, sample:true)
            self.faceCollectionView.reloadData()
        }else{
            self.adjustButtonsForKnownFace(preview: false)
            let subCategories = ModelStore.default.getMonthsOfFaceCrops(peopleId: self.selectedPeopleId, imageYear: value)
            self.faceSubCategoryController.load(subCategories)
        }
    }
    
    fileprivate func onFaceSubCategoryClicked(_ value:String){
        self.cleanFaceInfo()
        self.cleanSourceInfo()
        if selectedCategory == "Samples" {
            self.adjustButtonsForUnknownFace(preview: false)
        }else{
            self.adjustButtonsForKnownFace(preview: false)
        }
        self.selectedSubCategory = value
        let year:Int = Int(selectedCategory) ?? 0
        let month:Int = Int(selectedSubCategory) ?? 0
        self.faceCollectionViewController.imagesLoader.loadFaces(peopleId: self.selectedPeopleId, year: year, month: month)
        self.faceCollectionView.reloadData()
    }
    
    fileprivate func onRelationshipSelected(otherId:String, callAs:String, beCalledAs:String) {
        if let person = self.peopleDictionary[otherId] {
            self.peopleListController.select(person.name)
            self.txtCallAs.stringValue = callAs
            self.txtBeCalledAs.stringValue = beCalledAs
        }
    }
    
    fileprivate var selectedFamilyId = ""
    fileprivate var selectedFamilyName = ""
    fileprivate var selectedFamilyType = ""
    
    fileprivate func onFamilySelected(id:String, name:String, type:String, checked:String){
        if id != "" && name != "" && type != "" {
            self.selectedFamilyId = id
            self.selectedFamilyName = name
            self.selectedFamilyType = type
            self.txtFamilyName.stringValue = name
            self.familyTypesListController.select(type)
        }
    }
    
    fileprivate func onFamilyCheck(id:String, checked:Bool){
        if checked {
            ModelStore.default.saveFamilyMember(peopleId: self.selectedPeopleId, familyId: id)
        }else{
            ModelStore.default.deleteFamilyMember(peopleId: self.selectedPeopleId, familyId: id)
        }
    }
    
    fileprivate func onDifferentPersonClicked(id:String, name:String){
        print("selected \(id) \(name)")
        self.lblFaceDescription.stringValue = ""
        if self.selectedFaceId != "" {
            if let crop = ModelStore.default.getFace(id: self.selectedFaceId) {
                var c = crop
                c.peopleId = id
                c.recognizeBy = "UserAssign"
                c.recognizeDate = Date()
                if c.recognizeVersion == nil {
                    c.recognizeVersion = "1"
                }else{
                    var version = Int(c.recognizeVersion ?? "0") ?? 0
                    version += 1
                    c.recognizeVersion = "\(version)"
                }
                ModelStore.default.saveFaceCrop(c)
                print("Face crop \(crop.id) assigned as [\(name)], updated into DB.")
                
                if let person = ModelStore.default.getPerson(id: id) {
                    DispatchQueue.main.async {
                        self.lblFaceDescription.stringValue = person.shortName ?? person.name
                    }
                }
            }
        }
    }
    
    fileprivate func onRecognizeUnknownClicked(id:String) {
        // TODO FUNCTION
        print("selected menu: \(id)")
        self.lblProgressMessage.stringValue = "Recognizing..."
        var faces:[ImageFace] = []
        if id == "all" {
            faces = ModelStore.default.getFaceCrops(peopleId: "", year: nil, month: nil, sample: false, icon: nil, tag: nil, locked: false)
        }else if id == "selected" {
            if self.tblFaceYear.numberOfSelectedRows > 0 && self.tblFaceMonth.numberOfSelectedRows > 0 && self.selectedCategory != "Unknown" {
                print("selection at \(self.selectedCategory),\(self.selectedSubCategory)")
                faces = ModelStore.default.getFaceCrops(peopleId: "", year: Int(self.selectedCategory), month: Int(selectedSubCategory), sample: false, icon: nil, tag: nil, locked: false)
            }else{
                print("no selection")
                self.lblProgressMessage.stringValue = "No category is selected."
                return
            }
        }else{
            faces = ModelStore.default.getFaceCrops(peopleId: "", year: Int(id), month: nil, sample: false, icon: nil, tag: nil, locked: false)
        }
        if faces.count == 0 {
            self.lblProgressMessage.stringValue = "No face need to be recognized."
            print("no faces need to be recognized")
            return
        }
        var peopleName:[String:String] = [:]
        let people = ModelStore.default.getPeople()
        for person in people {
            peopleName[person.id] = person.shortName ?? person.name
        }
        DispatchQueue.global().async {
            let total = faces.count
            var i = 0
            var k = 0
            for face in faces {
                i += 1
                let url = URL(fileURLWithPath: face.cropPath).appendingPathComponent(face.subPath).appendingPathComponent(face.filename)
                let names = FaceRecognition.default.recognize(imagePath: url.path)
                if names.count > 0 {
                    let name = names[0]
                    if name != "Unknown" {
                        var c = face
                        c.peopleId = name
                        c.recognizeBy = "FaceRecognitionOpenCV"
                        c.recognizeDate = Date()
                        if c.recognizeVersion == nil {
                            c.recognizeVersion = "1"
                        }else{
                            var version = Int(c.recognizeVersion ?? "0") ?? 0
                            version += 1
                            c.recognizeVersion = "\(version)"
                        }
                        ModelStore.default.saveFaceCrop(c)
                        print("Face crop \(face.id) recognized as [\(name)], updated into DB.")
                        k += 1
                        DispatchQueue.main.async {
                            let personName = peopleName[name] ?? name
                            self.lblProgressMessage.stringValue = "Recognizing \(i)/\(total): Recognized [\(personName)]"
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.lblProgressMessage.stringValue = "Recognizing \(i)/\(total): Unrecognized"
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.lblProgressMessage.stringValue = "Recognized \(k) faces. \(total-k) unrecognized."
            }
        }
    }
    
    // MARK: ACTION
    
    @IBAction func onSaveIdClicked(_ sender: NSButton) {
        self.lblIdentityMessasge.stringValue = ""
        let id = self.txtPeopleId.stringValue
        let name = self.txtPeopleName.stringValue
        let shortName = self.txtPeopleNickName.stringValue
        if id != "" && name != "" && shortName != "" {
            ModelStore.default.savePersonName(id: id, name: name, shortName: shortName)
            self.lblIdentityMessasge.stringValue = "Saved."
            FaceTask.default.reloadPeople()
            self.loadIcons()
        }else{
            self.lblIdentityMessasge.stringValue = "ERROR: Empty."
        }
    }
    
    @IBAction func onChkIconClicked(_ sender: NSButton) {
        if self.selectedFaceId != "" && self.selectedPeopleId != "" {
            if sender.state == .on {
                ModelStore.default.updateFaceIconFlag(id: self.selectedFaceId, peopleId: self.selectedPeopleId)
                self.loadIcons()
                self.iconCollectionViewController.restoreHighlightedItems()
            }else{
                ModelStore.default.removeFaceIcon(peopleId: self.selectedPeopleId)
                self.loadIcons()
                self.iconCollectionViewController.restoreHighlightedItems()
            }
        }
    }
    
    @IBAction func onDifferentPersonClicked(_ sender: NSButton) {
        let people = ModelStore.default.getPeople(except: self.selectedPeopleId)
        var menu:[(String, String)] = []
        menu.append(("", "Unknown"))
        for person in people {
            menu.append((person.id, person.shortName ?? person.name))
        }
        self.menuPopover.load(menu)
        self.menuPopover.show(sender)
    }
    
    @IBAction func onSaveCallClicked(_ sender: NSButton) {
        self.lblRelationshipMessage.stringValue = ""
        if let index = self.peopleListController.indexOfSelectedItem() {
            let person = self.peopleList[index]
            let callAs = self.txtCallAs.stringValue
            let beCalledAs = self.txtBeCalledAs.stringValue
            if callAs != "" && beCalledAs != "" {
                ModelStore.default.saveRelationship(primary: self.selectedPeopleId, secondary: person.id, callName: callAs)
                ModelStore.default.saveRelationship(primary: person.id, secondary: self.selectedPeopleId, callName: beCalledAs)
                self.lblRelationshipMessage.stringValue = "Saved."
                self.loadRelationships()
            }else{
                self.lblRelationshipMessage.stringValue = "ERROR: Empty."
            }
        }
    }
    
    @IBAction func onSourceLargerViewClicked(_ sender: NSButton) {
        // TODO: TODO FUNCTION
    }
    
    @IBAction func onChkSampleClicked(_ sender: NSButton) {
        if self.selectedFaceId != "" && self.selectedPeopleId != "" {
            ModelStore.default.updateFaceSampleFlag(id: self.selectedFaceId, flag: (sender.state == .on) )
            // copy or remove face crop to/from recognition sample directory
            if let face = ModelStore.default.getFace(id: self.selectedFaceId) {
                let targetFolder = URL(fileURLWithPath: FaceRecognition.trainingSamplePath).appendingPathComponent(self.selectedPeopleId)
                let target = targetFolder.appendingPathComponent("\(self.selectedFaceId).jpg")
                if sender.state == .on {
                    do {
                        try FileManager.default.createDirectory(at: targetFolder, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        print("Unable to create directory at \(targetFolder.path)")
                        print(error)
                    }
                    let source = URL(fileURLWithPath: face.cropPath).appendingPathComponent(face.subPath).appendingPathComponent(face.filename)
                    do {
                        try FileManager.default.copyItem(at: source, to: target)
                        print("Copied sample file from [\(source.path)] to [\(target.path)]")
                    }catch{
                        print("Unable to copy sample file from [\(source.path)] to [\(target.path)]")
                        print(error)
                    }
                }else{
                    do {
                        try FileManager.default.removeItem(at: target)
                    }catch{
                        print("Failed to delete sample file: \(target.path)")
                        print(error)
                    }
                }
            }
            
        }
    }
    
    @IBAction func onChangeFamilyNameClicked(_ sender: NSButton) {
        self.lblFamilyMessage.stringValue = ""
        let name = self.txtFamilyName.stringValue
        let type = self.lstFamilyType.titleOfSelectedItem ?? ""
        if self.selectedFamilyId != "" && name != "" && type != "" {
            var msg = "BEFORE: \(self.selectedFamilyName) [\(self.selectedFamilyType)]\n"
            msg +=    "AFTER : \(name) [\(type)]"
            if Alert.dialogOKCancel(question: "Change this organization ?", text: msg, width: 350) {
                if let _ = ModelStore.default.saveFamily(familyId: self.selectedFamilyId, name: name, type: type) {
                    self.lblFamilyMessage.stringValue = "Updated."
                    self.loadFamilies()
                }else{
                    self.lblFamilyMessage.stringValue = "ERROR: Failed to save."
                }
            }
        }else{
            self.lblFamilyMessage.stringValue = "ERROR: Empty."
        }
    }
    
    @IBAction func onDeleteFamilyClicked(_ sender: NSButton) {
        self.lblFamilyMessage.stringValue = ""
        if self.selectedFamilyId != "" {
            let msg = "\(self.selectedFamilyName) [\(self.selectedFamilyType)]"
            if Alert.dialogOKCancel(question: "DELETE this organization and all memberships ?", text: msg, width: 350) {
                ModelStore.default.deleteFamily(id: self.selectedFamilyId)
                self.lblFamilyMessage.stringValue = "Deleted."
                self.selectedFamilyId = ""
                self.loadFamilies()
            }
        }
    }
    
    @IBAction func onCreateFamilyClicked(_ sender: NSButton) {
        self.lblFamilyMessage.stringValue = ""
        let name = self.txtFamilyName.stringValue
        let type = self.lstFamilyType.titleOfSelectedItem ?? ""
        if name != "" && type != "" {
            if let _ = ModelStore.default.saveFamily(name: name, type: type) {
                self.lblFamilyMessage.stringValue = "Created."
                self.loadFamilies()
            }else{
                self.lblFamilyMessage.stringValue = "ERROR: Failed to create."
            }
        }else{
            self.lblFamilyMessage.stringValue = "ERROR: Empty."
        }
    }
    
    @IBAction func onPeopleListClicked(_ sender: NSPopUpButton) {
        // do nothing
//        self.txtCallAs.stringValue = ""
//        self.txtBeCalledAs.stringValue = ""
//        self.lblRelationshipMessage.stringValue = ""
//        self.loadRelationships()
    }
    
    @IBAction func onRecognizeClicked(_ sender: NSButton) {
        self.lblFaceDescription.stringValue = ""
        if self.selectedFaceId != "" {
            if let crop = ModelStore.default.getFace(id: self.selectedFaceId) {
                let path = URL(fileURLWithPath: crop.cropPath).appendingPathComponent(crop.subPath).appendingPathComponent(crop.filename)
                self.btnRecognize.isEnabled = false
                self.btnDifferentPerson.isEnabled = false
                self.lblFaceDescription.stringValue = "Recognizing ..."
                DispatchQueue.global().async {
                    let recognition = FaceRecognition.default.recognize(imagePath: path.path)
                    if recognition.count > 0 {
                        let name = recognition[0]
                        if name == "Unknown" {
                            DispatchQueue.main.async {
                                self.lblFaceDescription.stringValue = "Unrecognized"
                            }
                        }else{
                            var c = crop
                            c.peopleId = name
                            c.recognizeBy = "FaceRecognitionOpenCV"
                            c.recognizeDate = Date()
                            if c.recognizeVersion == nil {
                                c.recognizeVersion = "1"
                            }else{
                                var version = Int(c.recognizeVersion ?? "0") ?? 0
                                version += 1
                                c.recognizeVersion = "\(version)"
                            }
                            ModelStore.default.saveFaceCrop(c)
                            print("Face crop \(crop.id) recognized as [\(name)], updated into DB.")
                            
                            if let person = ModelStore.default.getPerson(id: name) {
                                DispatchQueue.main.async {
                                    self.lblFaceDescription.stringValue = person.shortName ?? person.name
                                }
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.lblFaceDescription.stringValue = "Unrecognized"
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.btnRecognize.isEnabled = true
                        self.btnDifferentPerson.isEnabled = true
                    }
                }
                
            }
        }
    }
    
    fileprivate var totalSamples = 0
    
    @IBAction func onTrainingClicked(_ sender: NSButton) {
        self.lblProgressMessage.stringValue = "Training model..."
        DispatchQueue.global().async {
            FaceRecognition.default.training(onOutput: { content in
                let lines = content.components(separatedBy: "\n")
                if lines.count > 0 {
                    for line in lines {
                        if line.starts(with: "STARTUP ") {
                            DispatchQueue.main.async {
                                self.lblProgressMessage.stringValue = "Preparing trainer..."
                            }
                        }else if line.starts(with: "TOTAL ") {
                            let parts = line.components(separatedBy: " ")
                            if let total = Int(parts[1]) {
                                self.totalSamples = total
                                print("total \(total) samples")
                                DispatchQueue.main.async {
                                    self.lblProgressMessage.stringValue = "Preparing trainer..."
                                }
                            }else{
                                print("unable to get total number from \(line)")
                            }
                        }else if line.starts(with: "PROCESSING IMAGE ") {
                            let parts = line.components(separatedBy: " ")
                            let numbers = parts[4]
                            let dividen = numbers.components(separatedBy: "/")
                            let number = dividen[0]
                            let name = parts[5]
                            print("processing \(number), recognized as \(name)")
                            DispatchQueue.main.async {
                                self.lblProgressMessage.stringValue = "Processing sample No.\(number)..."
                            }
                        }else if line.starts(with: "DONE ") {
                            DispatchQueue.main.async {
                                self.lblProgressMessage.stringValue = "Training completed with \(self.totalSamples) samples."
                            }
                        }
                    }
                }
                
            })
        }
    }
    
    @IBAction func onRecognizeAllClicked(_ sender: NSButton) {
        let years = ModelStore.default.getYearsOfFaceCrops(peopleId: "")
        var menu:[(String, String)] = []
        menu.append(("all", "All Unknown Faces"))
        menu.append(("selected", "Unknown faces in selected month"))
        for year in years {
            menu.append((year, "Unknown faces in \(year)"))
        }
        for a in menu {
            print("menu: \(a)")
        }
        self.menuRecognizeUnknown.load(menu)
        self.menuRecognizeUnknown.show(sender)
    }
    
    @IBAction func onChkLockClicked(_ sender: NSButton) {
        if self.selectedFaceId != "" && self.selectedPeopleId != "" {
            if sender.state == .on {
                ModelStore.default.updateFaceLockFlag(id: self.selectedFaceId, flag: true)
            }else{
                ModelStore.default.updateFaceLockFlag(id: self.selectedFaceId, flag: false)
            }
        }
    }
    
    
}
