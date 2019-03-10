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
    
    
    var iconCollectionViewController : FaceIconCollectionViewController!
    var faceCollectionViewController : FaceCollectionViewController!
    
    var faceCategoryController : SingleColumnTableViewController!
    var faceSubCategoryController : SingleColumnTableViewController!
    
    var peopleListController : TextListViewPopupController!
    var relationshipTableController : DictionaryTableViewController!
    
    var familyTypesListController : TextListViewPopupController!
    var familyTableController : DictionaryTableViewController!
    
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
        
    }
    
    func initView() {
        self.loadIcons()
        self.adjustButtonsForUnknownFace(preview: false)
    }
    
    fileprivate func cleanIdentity() {
        self.txtPeopleId.stringValue = ""
        self.txtPeopleName.stringValue = ""
        self.txtPeopleNickName.stringValue = ""
    }
    
    fileprivate func cleanFaceInfo() {
        self.imgFacePreview.image = nil
        self.chkIcon.state = .off
        self.chkSample.state = .off
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
        }else{
            self.btnDifferentPerson.isHidden = true
            self.btnRecognize.isHidden = true
            self.btnSourceLargerView.isHidden = true
            self.lblSourceDate.isHidden = true
            self.lblSourceDescription.isHidden = true
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
            self.btnDifferentPerson.isHidden = false
            self.btnRecognize.isHidden = false
            self.btnSourceLargerView.isHidden = false
            self.lblSourceDate.isHidden = false
            self.lblSourceDescription.isHidden = false
        }else{
            self.chkIcon.isHidden = true
            self.chkSample.isHidden = true
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
    
    fileprivate func selectFace(_ face:PeopleFace) {
        self.cleanFaceInfo()
        
        if self.selectedPeopleId == "Unknown" || self.selectedPeopleId == "" {
            self.adjustButtonsForUnknownFace(preview: true)
        }else{
            self.adjustButtonsForKnownFace(preview: true)
        }
        
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
            self.faceSubCategoryController.clean()
            self.faceCollectionViewController.imagesLoader.loadFaces(peopleId: self.selectedPeopleId, sample:true)
            self.faceCollectionView.reloadData()
        }else{
            let subCategories = ModelStore.default.getMonthsOfFaceCrops(peopleId: self.selectedPeopleId, imageYear: value)
            self.faceSubCategoryController.load(subCategories)
        }
    }
    
    fileprivate func onFaceSubCategoryClicked(_ value:String){
        self.cleanFaceInfo()
        self.cleanSourceInfo()
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
    
    // MARK: ACTION
    
    @IBAction func onSaveIdClicked(_ sender: NSButton) {
        // TODO: TODO FUNCTION
    }
    
    @IBAction func onChkIconClicked(_ sender: NSButton) {
        // TODO: TODO FUNCTION
    }
    
    @IBAction func onSaveAgeClicked(_ sender: NSButton) {
        // TODO: TODO FUNCTION
    }
    
    @IBAction func onDifferentPersonClicked(_ sender: NSButton) {
        // TODO: TODO FUNCTION
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
        // TODO: TODO FUNCTION
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
    }
    
    
}
