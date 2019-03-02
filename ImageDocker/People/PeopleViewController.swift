//
//  PeopleViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/22.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class PeopleViewController: NSViewController {
    
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
    @IBOutlet weak var txtAge: NSTextField!
    @IBOutlet weak var btnSaveAge: NSButton!
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
    
    var iconCollectionViewController : FaceIconCollectionViewController!
    var faceCollectionViewController : FaceCollectionViewController!
    
    
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
        self.loadIcons()
    }
    
    fileprivate func configureControllers() {
        self.iconCollectionViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "faceIconCollectionView")) as! FaceIconCollectionViewController
        self.iconCollectionViewController.withoutName()
        
        self.faceCollectionViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "faceCollectionView")) as! FaceCollectionViewController
    }
    
    fileprivate func loadIcons() {
        // TODO: TODO FUNCTION
        self.iconCollectionViewController.imagesLoader.loadIcons()
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
        // TODO: TODO FUNCTION
    }
    
    @IBAction func onSourceLargerViewClicked(_ sender: NSButton) {
        // TODO: TODO FUNCTION
    }
    
    
}
