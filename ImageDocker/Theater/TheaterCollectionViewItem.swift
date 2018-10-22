//
//  TheaterCollectionViewItem.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/10/17.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class TheaterCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var lblPlace: NSTextField!
    
    let displayDateFormat:String = "HH:mm:ss"
    
    var imageFile: ImageFile? {
        didSet {
            guard isViewLoaded else { return }
            if let imageFile = imageFile {
                self.renderControls(imageFile)
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
                lblPlace.stringValue = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor // NSColor(calibratedWhite: 0.1, alpha: 1).cgColor
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor
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
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
    }
    
}
