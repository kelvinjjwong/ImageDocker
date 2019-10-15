//
//  MemoryCollectionViewItem.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/13.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class MemoryCollectionViewItem: NSCollectionViewItem {
    
    var imageFile: ImageFile? {
        didSet {
            guard isViewLoaded else { return }
            if let imageFile = imageFile {
                self.renderControls(imageFile)
            } else {
                imageView?.image = nil
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
    
    fileprivate func renderControls(_ imageFile:ImageFile) {
        DispatchQueue.main.async {
            self.imageView?.image = imageFile.thumbnail
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
