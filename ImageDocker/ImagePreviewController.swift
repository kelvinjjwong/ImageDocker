//
//  ImagePreviewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/26.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class ImagePreviewController : NSViewController {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "Preview")
    
    @IBOutlet weak var playerContainer: NSView!
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var btnWriteNotes: NSButton!
    @IBOutlet weak var btnZoomOut: NSButton!
    @IBOutlet weak var btnCounterClockwise: NSButton!
    @IBOutlet weak var btnClockwise: NSButton!
    
    var imageFile:ImageFile?
    var getImageFromPreview: ( () -> NSImage? )?
    var previewImage: ( (ImageFile) -> Void )?
    var zoomOutImage: ( (ImageFile) -> Void )?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onWriteNotesClicked(_ sender: NSButton) {
        self.logger.log(.trace, "preview menu - to do function")
    }
    
    @IBAction func onZoomOutClicked(_ sender: NSButton) {
        if let img = self.imageFile {
            self.zoomOutImage?(img)
        }
    }
    
    func rotateImage(rotateDegree:Int) {
        if let imageId = self.imageFile?.imageData?.id,
            let imageData = ImageRecordDao.default.getImage(id: imageId) {
            
            let originDegree = imageData.rotation ?? 0
            var degree = originDegree + rotateDegree
            if degree <= -360 || degree >= 360 {
                degree = 0
            }
            
            let dbState = ImageRecordDao.default.updateImageRotation(path: imageData.path, rotation: degree)
            if dbState != .OK {
                MessageEventCenter.default.showMessage(type: "IMAGE", name:"ROTATE", message: "Failed to update image with rotation \(degree)")
            }else{
                if let imageFile = self.imageFile {
                    
                    self.imageFile?.imageData?.rotation = degree // update rotation value in Image object in RAM
                    imageData.rotation = degree
                    
                    self.previewImage?(imageFile)
                    
                    if let collectionViewItem = imageFile.collectionViewItem {
                        
                        self.logger.log(.trace, "re-render collection view item after rotate \(rotateDegree) degree - imageId:\(imageFile.imageData?.id ?? ""), repositoryId:\(imageFile.imageData?.repositoryId ?? -999999)")
                        
                        collectionViewItem.imageFile?.imageData?.rotation = degree
                        collectionViewItem.reRenderItem()
                    }
                }
            }
            
        }else{
            self.logger.log(.trace, "rotate clockwise:")
            self.logger.log(.trace, self.getImageFromPreview == nil)
            self.logger.log(.trace, self.getImageFromPreview?() == nil)
            self.logger.log(.trace, self.imageFile == nil)
            self.logger.log(.trace, self.imageFile?.imageData == nil)
            self.logger.log(.trace, self.imageFile?.imageData?.id == nil)
        }
    }
    
    @IBAction func onRotateClockwiseClicked(_ sender: NSButton) {
        self.rotateImage(rotateDegree: -90)
    }
    
    @IBAction func onRotateCounterClockwiseClicked(_ sender: NSButton) {
        self.rotateImage(rotateDegree: +90)
    }
}
