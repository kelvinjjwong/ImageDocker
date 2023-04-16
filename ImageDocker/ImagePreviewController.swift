//
//  ImagePreviewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/26.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa

class ImagePreviewController : NSViewController {
    
    let logger = ConsoleLogger(category: "ImagePreviewController")
    
    @IBOutlet weak var playerContainer: NSView!
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var btnWriteNotes: NSButton!
    @IBOutlet weak var btnZoomOut: NSButton!
    @IBOutlet weak var btnCounterClockwise: NSButton!
    @IBOutlet weak var btnClockwise: NSButton!
    
    var imageFile:ImageFile?
    var getImageFromPreview: ( () -> NSImage? )?
    var previewImage: ( (NSImage) -> Void )?
    var zoomOutImage: ( (ImageFile) -> Void )?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onWriteNotesClicked(_ sender: NSButton) {
        self.logger.log("preview menu - to do function")
    }
    
    @IBAction func onZoomOutClicked(_ sender: NSButton) {
        if let img = self.imageFile {
            self.zoomOutImage?(img)
        }
    }
    
    @IBAction func onRotateClockwiseClicked(_ sender: NSButton) {
        if let imageId = self.imageFile?.imageData?.id,
            let imageData = ImageRecordDao.default.getImage(id: imageId) {
            let imageUrl = URL(fileURLWithPath: imageData.path)
            let imageType = imageUrl.imageType()
            let originDegree = imageData.rotation ?? 0
            var degree = originDegree - 90
            if degree <= -360 || degree >= 360 {
                degree = 0
            }
            self.logger.log("rotate from \(originDegree) to \(degree)")
            let dbState = ImageRecordDao.default.updateImageRotation(path: imageData.path, rotation: degree)
            if dbState != .OK {
                MessageEventCenter.default.showMessage(type: "IMAGE", name:"ROTATE", message: "Failed to update image with rotation \(degree)")
            }else{
                imageData.rotation = degree
                MessageEventCenter.default.showMessage(type: "IMAGE", name:"ROTATE", message: "Rotated, you may need to refresh collection.")
                if imageType == .photo {
                    if let nsImage = self.getImageFromPreview?() {
                        self.previewImage?(nsImage.rotate(degrees: CGFloat(degree)))
                    }
                }else {
                    self.imageFile = ImageFile(image: imageData)
                    if let previewImage = self.previewImage, let nsimage = self.imageFile?.image {
                        previewImage(nsimage)
                    }else{
                        print("cannot preview video")
                    }
                    //FIXME: preview rotated video
                }
            }
            
        }else{
            print("rotate clockwise:")
            print(self.getImageFromPreview == nil)
            print(self.getImageFromPreview?() == nil)
            print(self.imageFile == nil)
            print(self.imageFile?.imageData == nil)
            print(self.imageFile?.imageData?.id == nil)
        }
    }
    
    @IBAction func onRotateCounterClockwiseClicked(_ sender: NSButton) {
        if let imageData = self.imageFile?.imageData {
            let imageUrl = URL(fileURLWithPath: imageData.path)
            let imageType = imageUrl.imageType()
            let originDegree = imageData.rotation ?? 0
            var degree = originDegree + 90
            if degree <= -360 || degree >= 360 {
                degree = 0
            }
            let dbState = ImageRecordDao.default.updateImageRotation(path: imageData.path, rotation: degree)
            if dbState != .OK {
                MessageEventCenter.default.showMessage(type: "IMAGE", name:"ROTATE", message: "Failed to update image with rotation \(degree)")
            }else{
                imageData.rotation = degree
                MessageEventCenter.default.showMessage(type: "IMAGE", name:"ROTATE", message: "Rotated, you may need to refresh collection.")
                if imageType == .photo {
                    if let nsImage = self.getImageFromPreview?() {
                        self.previewImage?(nsImage.rotate(degrees: CGFloat(degree)))
                    }
                }else {
                    self.imageFile = ImageFile(image: imageData)
                    if let previewImage = self.previewImage, let nsimage = self.imageFile?.image {
                        previewImage(nsimage)
                    }else{
                        print("cannot preview video")
                    }
                    //FIXME: preview rotated video
                }
            }
        }else{
            print("rotate counterclockwise:")
            print(self.imageFile == nil)
            print(self.imageFile?.imageData == nil)
            print(self.imageFile?.imageData?.id == nil)
        }
    }
}
