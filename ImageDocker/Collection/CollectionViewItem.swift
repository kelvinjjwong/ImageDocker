//
//  CollectionViewItem.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//


import Cocoa

class CollectionViewItem: NSCollectionViewItem {
  
    @IBOutlet weak var checkBox: NSButton!
    @IBOutlet weak var lblPlace: NSTextField!
    @IBOutlet weak var btnLook: NSButton!
    @IBOutlet weak var btnCaution: NSButton!
    @IBOutlet weak var btnMenu: NSPopUpButton!
    
    
    private var checkBoxDelegate:CollectionViewItemCheckDelegate?
    private var showDuplicatesDelegate:CollectionViewItemShowDuplicatesDelegate?
    private var quickLookDelegate:CollectionViewItemQuickLookDelegate?
    
    var sectionIndex:Int?
    
    func setCheckBoxDelegate(_ delegate:CollectionViewItemCheckDelegate){
        self.checkBoxDelegate = delegate
    }
    
    func setShowDuplicatesDelegate(_ delegate:CollectionViewItemShowDuplicatesDelegate) {
        self.showDuplicatesDelegate = delegate
    }
    
    func setQuickLookDelegate(_ delegate:CollectionViewItemQuickLookDelegate) {
        self.quickLookDelegate = delegate
    }
    
    var displayDateFormat:String = "HH:mm:ss"
    
    var imageFile: ImageFile? {
        didSet {
            guard isViewLoaded else { return }
            if let imageFile = imageFile {
                self.renderControls(imageFile)
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
                lblPlace.stringValue = ""
                checkBox.state = NSButton.StateValue.off
                btnCaution.isHidden = true
            }
        }
    }
    
    var backgroundColor:NSColor?
    
    private var isControlsHidden = false
    
    func hideControls() {
        self.btnLook.isHidden = true
        self.btnCaution.isHidden = true
        self.checkBox.isHidden = true
        self.btnMenu.isHidden = true
        self.isControlsHidden = true
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = (backgroundColor ?? NSColor.darkGray).cgColor
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor // Aqua

        self.btnLook.image = NSImage(named: NSImage.Name.quickLookTemplate)
        self.btnCaution.isHidden = true
    }
    
    func reloadFromDatabase(){
        if let oldImage = self.imageFile?.imageData  {
            if let image = ModelStore.default.getImage(path: oldImage.path) {
                self.imageFile = ImageFile(photoFile: image)
            }
        }
    }
    
    fileprivate func renderControls(_ imageFile:ImageFile) {
        DispatchQueue.main.async {
            self.imageView?.image = imageFile.thumbnail
        }
        if imageFile.photoTakenDate() != nil {
            textField?.stringValue = imageFile.dateString(imageFile.photoTakenDate(), format: displayDateFormat)
        }else {
            textField?.stringValue = imageFile.fileName
        }
        if let image = imageFile.imageData {
            if image.shortDescription != nil && image.shortDescription != "" {
                lblPlace.stringValue = image.shortDescription ?? imageFile.place
            }else{
                lblPlace.stringValue = imageFile.place
            }
        }else{
            lblPlace.stringValue = imageFile.place
        }
        
        checkBox.state = NSButton.StateValue.off
        
        if imageFile.isHidden {
            self.btnLook.image = NSImage(named: NSImage.Name.stopProgressTemplate)
            self.btnLook.toolTip = "Hidden"
        }else {
            self.btnLook.image = NSImage(named: NSImage.Name.quickLookTemplate)
            self.btnLook.toolTip = "Visible"
        }
        
        if !self.isControlsHidden {
            btnCaution.isHidden = !imageFile.hasDuplicates
        }
        btnCaution.toolTip = imageFile.hasDuplicates ? "duplicates" : ""
        
    }
  
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
    }
    
    func check(checkBySection:Bool = false){
        checkBox.state = NSButton.StateValue.on
        if checkBoxDelegate != nil {
            checkBoxDelegate?.onCollectionViewItemCheck(self, checkBySection: checkBySection)
        }
    }
    
    func uncheck(checkBySection:Bool = false){
        checkBox.state = NSButton.StateValue.off
        if checkBoxDelegate != nil {
            checkBoxDelegate?.onCollectionViewItemUncheck(self, checkBySection: checkBySection)
        }
    }
    
    func isChecked() -> Bool {
        if checkBox.state == NSButton.StateValue.on {
            return true
        }else {
            return false
        }
    }
    
    @IBAction func onCheckBoxClicked(_ sender: NSButton) {
        if isChecked() {
            if checkBoxDelegate != nil {
                checkBoxDelegate?.onCollectionViewItemCheck(self, checkBySection: false)
            }
        }else{
            if checkBoxDelegate != nil {
                checkBoxDelegate?.onCollectionViewItemUncheck(self, checkBySection: false)
            }
        }
    }
    
    @IBAction func onPopUpButtonClicked(_ sender: NSPopUpButton) {
        let i = sender.indexOfSelectedItem
        if i == 1 {
            self.revealInFinder()
        }else if i == 2 {
            self.quicklook()
        }else if i == 3 {
            self.findFaces()
        }else if i == 4 {
            self.recognizeFaces()
        }
    }
    
    @IBAction func onButtonLookClicked(_ sender: Any) {
        if let image = self.imageFile {
            if image.isHidden {
                image.show()
                self.btnLook.image = NSImage(named: NSImage.Name.quickLookTemplate)
                self.btnLook.toolTip = "Visible"
            }else {
                image.hide()
                self.btnLook.image = NSImage(named: NSImage.Name.stopProgressTemplate)
                self.btnLook.toolTip = "Hidden"
            }
            //ModelStore.save()
        }
    }
    
    @IBAction func onDuplicatesClicked(_ sender: NSButton) {
        if let imageFile = self.imageFile {
            if self.showDuplicatesDelegate != nil {
                self.showDuplicatesDelegate?.onCollectionViewItemShowDuplicate(imageFile.duplicatesKey)
            }
        }
    }
    
    
    fileprivate func revealInFinder(){
        if let url = self.imageFile?.url {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
    
    fileprivate func quicklook(){
        if let imageFile = self.imageFile, let url = self.imageFile?.url, FileManager.default.fileExists(atPath: url.path) {
            if self.quickLookDelegate != nil {
                self.quickLookDelegate?.onCollectionViewItemQuickLook(imageFile)
            }
        }
    }
    
    fileprivate func findFaces() {
        if let _ = self.imageFile, let url = self.imageFile?.url, FileManager.default.fileExists(atPath: url.path) {
            DispatchQueue.global().async {
                if let image = ModelStore.default.getImage(path: url.path) {
                    if image.repositoryPath != "", let repository = ModelStore.default.getRepository(repositoryPath: image.repositoryPath) {
                        if repository.cropPath != "" {
                            // ensure base crop path exists
                            var isDir:ObjCBool = false
                            if FileManager.default.fileExists(atPath: repository.cropPath, isDirectory: &isDir) {
                                if !isDir.boolValue {
                                    print("ERROR: Crop path of repository is not a directory: \(repository.cropPath)")
                                    return
                                }
                            }
                            
                            // ensure image-filename-aware crop path exists
                            let cropPath = URL(fileURLWithPath: repository.cropPath).appendingPathComponent(image.subPath)
                            print("Trying to create directory: \(cropPath.path)")
                            //if FileManager.default.fileExists(atPath: repository.cropPath, isDirectory: &isDir), isDir.boolValue {
                                do {
                                    try FileManager.default.createDirectory(atPath: cropPath.path, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    print(error)
                                    print("ERROR: Cannot create directory for storing crops at path: \(cropPath.path)")
                                    return
                                }
                            //}
                            if !FileManager.default.fileExists(atPath: cropPath.path, isDirectory: &isDir) {
                                print("ERROR: Cannot create directory: \(cropPath.path)")
                                return
                            }
                            
                            var img = image
                            if img.id == nil {
                                img.id = UUID().uuidString
                                ModelStore.default.saveImage(image: img)
                            }
                            let imageId = img.id!
                            
                            FaceDetection.default.findFace(from: url, into: cropPath, onCompleted: {faces in
                                for face in faces {
                                    print("Found face: \(face.filename) at (\(face.x), \(face.y), \(face.width), \(face.height))")
                                    let exist = ModelStore.default.findFaceCrop(imageId: imageId,
                                                                                x: face.x.databaseValue.description,
                                                                                y: face.y.databaseValue.description,
                                                                                width: face.width.databaseValue.description,
                                                                                height: face.height.databaseValue.description)
                                    if exist == nil {
                                        let imageFace = ImageFace.new(imageId: imageId,
                                                                      repositoryPath: repository.repositoryPath.withStash(),
                                                                      cropPath: repository.cropPath,
                                                                      subPath: image.subPath,
                                                                      filename: face.filename,
                                                                      faceX: face.x.databaseValue.description,
                                                                      faceY: face.y.databaseValue.description,
                                                                      faceWidth: face.width.databaseValue.description,
                                                                      faceHeight: face.height.databaseValue.description,
                                                                      frameX: face.frameX.databaseValue.description,
                                                                      frameY: face.frameY.databaseValue.description,
                                                                      frameWidth: face.frameWidth.databaseValue.description,
                                                                      frameHeight: face.frameHeight.databaseValue.description,
                                                                      imageDate: image.photoTakenDate,
                                                                      tagOnly: false,
                                                                      remark: "",
                                                                      year: image.photoTakenYear ?? 0,
                                                                      month: image.photoTakenMonth ?? 0,
                                                                      day: image.photoTakenDay ?? 0)
                                        ModelStore.default.saveFaceCrop(imageFace)
                                        print("Face crop \(imageFace.id) saved.")
                                    }else{
                                        print("Face already in DB")
                                    }
                                }
                                    
                                print("Face detection done in \(cropPath.path)")
                            })
                            
                        }else{
                            print("ERROR: Crop path is empty, please assign it first: \(repository.path)")
                            return
                        }
                    }else{
                        print("ERROR: Cannot find image's repository by repository path: \(image.repositoryPath)")
                        return
                    }
                }else{
                    print("ERROR: Cannot find image record: \(url.path)")
                    return
                }
            }
            
        }else{
            print("ERROR: Image object is null or file doesn't exist.")
            return
        }
    }
    
    func recognizeFaces() {
        if let _ = self.imageFile, let url = self.imageFile?.url, FileManager.default.fileExists(atPath: url.path) {
            DispatchQueue.global().async {
                if let image = ModelStore.default.getImage(path: url.path) {
                    if let imageId = image.id {
                        let crops = ModelStore.default.getFaceCrops(imageId: imageId)
                        if crops.count > 0 {
                            for crop in crops {
                                let path = URL(fileURLWithPath: crop.cropPath).appendingPathComponent(crop.subPath).appendingPathComponent(crop.filename)
                                let recognition = FaceRecognition.default.recognize(imagePath: path.path)
                                if recognition.count > 0 {
                                    let name = recognition[0]
                                    print("Face crop \(crop.id) is recognized as \(name)")
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
                                    print("Face crop \(crop.id) updated into DB.")
                                }else{
                                    print("No face recognized for image [\(imageId)].")
                                }
                            }
                        }else{
                            print("No crops for this image.")
                            return
                        }
                        
                        
                    }else{
                        print("ERROR: Image ID is not set.")
                        return
                    }
                }else{
                    print("ERROR: Cannot find image record: \(url.path)")
                    return
                }
            }
            
        }else{
            print("ERROR: Image object is null or file doesn't exist.")
            return
        }
    }
    
    
}
