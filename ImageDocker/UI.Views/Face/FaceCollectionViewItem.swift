//
//  FaceCollectionViewItem.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/2.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa


class FaceCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var bottom: NSLayoutConstraint!
    
    
    var backgroundColor:NSColor?
    var enableNameLabel = true
    
    var face: PeopleFace? {
        didSet {
            guard isViewLoaded else { return }
            if let face = face {
                self.renderControls(face)
            } else {
                imageView?.image = Icons.unknownFace
                textField?.stringValue = "Unknown"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        //view.layer?.backgroundColor = (backgroundColor ?? NSColor.darkGray).cgColor
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = NSColor(calibratedRed: 0.2, green: 0.2, blue: 0.2, alpha: 0.2).cgColor // Aqua
    }
    
    fileprivate func renderControls(_ face:PeopleFace) {
        DispatchQueue.main.async {
            self.imageView?.image = face.thumbnail ?? Icons.unknownFace
            if self.enableNameLabel {
                self.textField?.stringValue = face.personName
                self.textField?.isHidden = false
            }else{
                self.textField?.stringValue = ""
                self.textField?.isHidden = true
                self.bottom.constant = self.imageView!.lastBaselineOffsetFromBottom
            }
        }
        
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 3.0 : 1.0
        if selected {
            view.layer?.borderColor = NSColor(calibratedRed: 0.1, green: 0.2, blue: 0.8, alpha: 0.8).cgColor
        }else{
            view.layer?.borderColor = NSColor(calibratedRed: 0.2, green: 0.2, blue: 0.2, alpha: 0.2).cgColor
        }
    }
    
}
