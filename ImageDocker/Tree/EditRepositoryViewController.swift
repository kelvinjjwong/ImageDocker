//
//  EditRepositoryViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class EditRepositoryViewController: NSViewController {
    
    // MARK: FIELDS
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtHomePath: NSTextField!
    @IBOutlet weak var txtStoragePath: NSTextField!
    @IBOutlet weak var txtRepository: NSTextField!
    @IBOutlet weak var txtSmallSize: NSTextField!
    @IBOutlet weak var txtCropPath: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnBrowseHomePath: NSButton!
    @IBOutlet weak var btnBrowseStoragePath: NSButton!
    @IBOutlet weak var btnBrowseRepositoryPath: NSButton!
    @IBOutlet weak var btnBrowseFacePath: NSButton!
    @IBOutlet weak var btnBrowseCropPath: NSButton!
    @IBOutlet weak var btnFindHomePath: NSButton!
    @IBOutlet weak var btnFindStoragePath: NSButton!
    @IBOutlet weak var btnFindRepositoryPath: NSButton!
    @IBOutlet weak var btnFindFacePath: NSButton!
    @IBOutlet weak var btnFindCropPath: NSButton!
    
    
    // MARK: INIT
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "EditRepositoryViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ACTIONS
    
    fileprivate var onCompleted: (() -> Void)?
    
    func edit(url: URL, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.txtName.stringValue = url.path
        self.txtRepository.stringValue = url.path
        self.txtSmallSize.stringValue = url.path
    }
    
    @IBAction func onOKClicked(_ sender: Any) {
        guard self.txtName.stringValue != "" && self.txtRepository.stringValue != "" && self.txtSmallSize.stringValue != "" else {return}
        
        var isDir:ObjCBool = false
        var pass = true
        let smallSizePath = self.txtSmallSize.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if FileManager.default.fileExists(atPath: smallSizePath, isDirectory: &isDir) {
            if isDir.boolValue == false {
                pass = false
                self.lblMessage.stringValue = "Path for small size pictures at \(smallSizePath) is occupied by a file."
            }
        }else{
            do {
                try FileManager.default.createDirectory(atPath: smallSizePath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                pass = false
                self.lblMessage.stringValue = "Unable to create directory for small size pictures at \(smallSizePath)"
                //print("Unable to create directory for small size pictures at \(smallSizePath)")
                print(error)
            }
        }
        
        guard pass else {return}
        ImageFolderTreeScanner.createRepository(name: self.txtName.stringValue, path: self.txtRepository.stringValue, smallSizePath: self.txtSmallSize.stringValue)
        if self.onCompleted != nil {
            self.onCompleted!()
        }
    }
    @IBAction func onBrowseHomePath(_ sender: NSButton) {
    }
    
    @IBAction func onBrowseStoragePathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onBrowseRepositoryPathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onBrowseFacePathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onBrowseCropPath(_ sender: NSButton) {
    }
    
    @IBAction func onFindHomePath(_ sender: NSButton) {
    }
    
    @IBAction func onFindStoragePathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onFindRepositoryPathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onFindFaceRepositoryPathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onFindCropPath(_ sender: NSButton) {
    }
    
}
