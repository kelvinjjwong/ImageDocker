//
//  FaceCollectionViewItem.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/2.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class FaceCollectionViewItem: NSCollectionViewItem {
    
    
    var backgroundColor:NSColor?
    var enableNameLabel = true
    
    var face: PeopleFace? {
        didSet {
            guard isViewLoaded else { return }
            if let face = face {
                self.renderControls(face)
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = (backgroundColor ?? NSColor.darkGray).cgColor
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor // Aqua
    }
    
    fileprivate func renderControls(_ face:PeopleFace) {
        DispatchQueue.main.async {
            self.imageView?.image = face.thumbnail
            if self.enableNameLabel {
                self.textField?.stringValue = face.personName
            }else{
                self.textField?.stringValue = ""
            }
        }
        
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
    }
    
}
