//
//  FaceDetection.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/16.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Foundation
import AppKit
import Vision
import LoggerFactory

struct FaceClip {
    var filename:String
    var x:CGFloat
    var y:CGFloat
    var width:CGFloat
    var height:CGFloat
    var frameX:CGFloat
    var frameY:CGFloat
    var frameWidth:CGFloat
    var frameHeight:CGFloat
    
    static func new(_ filename:String, _ x:CGFloat, _ y:CGFloat, _ width:CGFloat, _ height:CGFloat, _ frameX:CGFloat, _ frameY:CGFloat, _ frameWidth:CGFloat, _ frameHeight:CGFloat) -> FaceClip{
        return FaceClip(filename: filename, x: x, y: y, width: width, height: height, frameX: frameX, frameY: frameY, frameWidth: frameWidth, frameHeight: frameHeight)
    }
}

@available(OSX 10.13, *)
class FaceDetection {
    
    let logger = LoggerFactory.get(category: "FaceDetection")
    
    fileprivate let CropSize:Int = 200
    
    static let `default` = FaceDetection()
    
    // smaller value, smaller size of face-image
    fileprivate var BorderPercentage:CGFloat = 0.3
    
    func withBorderPercentage(_ percentage:CGFloat) -> FaceDetection {
        self.BorderPercentage = percentage
        return self
    }
    
    enum NamingRule {
        case number, uuid
    }
    
    func findFace(from imageFile:String, into cropsStorage:String, nameBy:NamingRule = .number, onCompleted: (([FaceClip]) -> Void)? = nil) {
        let imageURL = URL(fileURLWithPath: imageFile)
        let cropsURL = URL(fileURLWithPath: cropsStorage)
        self.findFace(from: imageURL, into: cropsURL, nameBy: nameBy, onCompleted: onCompleted)
    }
    
    func findFace(from imageFile:URL, into cropsStorage:URL, nameBy:NamingRule = .number, onCompleted: (([FaceClip]) -> Void)? = nil) {
        guard let cgImage = CGImage.getCGImage(from: imageFile) else {
            self.logger.log(.trace, "ERROR: Cannot convert to CGImage: \(imageFile.path)")
            return
        }
        // Start face detection via Vision
        autoreleasepool { () -> Void in
            let facesRequest = VNDetectFaceRectanglesRequest { request, error in
                guard error == nil else {
                    self.logger.log(.trace, "ERROR: \(error!.localizedDescription)")
                    return
                }
                self.handleFaces(request, cgImage: cgImage, cropsPath: cropsStorage, nameBy: nameBy, onCompleted: onCompleted)
            }
            try? VNImageRequestHandler(cgImage: cgImage).perform([facesRequest])
        }
        
    }
    
    fileprivate func handleFaces(_ request: VNRequest, cgImage: CGImage, cropsPath:URL, nameBy:NamingRule = .number, onCompleted: (([FaceClip]) -> Void)? = nil) {
        guard let observations = request.results as? [VNFaceObservation] else {
            return
        }
        
        
        self.logger.log(.trace, "Trying to create directory: \(cropsPath.path)")
        var isDir:ObjCBool = false
        do {
            try FileManager.default.createDirectory(atPath: cropsPath.path, withIntermediateDirectories: true, attributes: nil)
        }catch{
            self.logger.log(.error, error)
            self.logger.log(.trace, "ERROR: Cannot create directory for storing crops at path: \(cropsPath.path)")
            return
        }
        if !FileManager.default.fileExists(atPath: cropsPath.path, isDirectory: &isDir) {
            self.logger.log(.trace, "ERROR: Cannot create directory: \(cropsPath.path)")
            return
        }
        if !isDir.boolValue {
            self.logger.log(.trace, "ERROR: Cannot create directory: \(cropsPath.path), it's occupied by a file.")
            return
        }
        
        var i = 0
        var filenames:[FaceClip] = []
        
        observations.forEach { observation in
            let (cgImage, x, y, width, height, frameX, frameY, frameWidth, frameHeight) = cgImage.cropImageToFace(observation, borderPercentage: self.BorderPercentage)
            guard let image = cgImage else {
                self.logger.log(.trace, "Image file cannot be cropped.")
                return
            }
            i += 1
            self.logger.log(.trace, "got \(i)")
            // Create image file from detected faces
            autoreleasepool(invoking: { () -> Void in
                let data = NSBitmapImageRep.init(cgImage: image).representation(using: .jpeg, properties: [:])
                if data == nil {
                    self.logger.log(.trace, "data object is nil")
                    
                }else{
                    
                    var filename = ""
                    var filenameTemporary = ""
                    if nameBy == .number {
                        filename = "\(i).jpg"
                        filenameTemporary = "\(i)-temp.jpg"
                    }else{
                        filename = "\(observation.uuid).jpg"
                        filenameTemporary = "\(observation.uuid)-temp.jpg"
                    }
                    let faceURL = cropsPath.appendingPathComponent(filename)
                    self.logger.log(.trace, "Creating crop file: \(filename)")
                    if Int(frameWidth) > CropSize || Int(frameHeight) > CropSize {
                        let tempURL = cropsPath.appendingPathComponent(filenameTemporary)
                        
                        do {
                            try data?.write(to: tempURL)
                        }catch{
                            self.logger.log(.error, "Unable to save big size crop to temporary file: \(tempURL.path)")
                            self.logger.log(.error, error)
                        }
                        
                        if let image = self.createThumbnail(from: tempURL, size: CropSize) {
                            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                                let cgData = NSBitmapImageRep.init(cgImage: cgImage).representation(using: .jpeg, properties: [:])
                                if cgData != nil {
                                    do {
                                        try cgData?.write(to: faceURL)
                                    }catch{
                                        self.logger.log(.error, "Unable to save resized crop to file: \(faceURL.path)")
                                        self.logger.log(.error, error)
                                    }
                                }
                            }
                        }
                        do {
                            try FileManager.default.removeItem(at: tempURL)
                        }catch{
                            self.logger.log(.error, "Unable to delete temporary file: \(tempURL.path)")
                            self.logger.log(.error, error)
                        }
                        
                        
                    }else{
                        do {
                            try data?.write(to: faceURL)
                        }catch{
                            self.logger.log(.error, error)
                        }
                    }
                    
                    filenames.append(FaceClip.new(filename, x, y, width, height, frameX, frameY, frameWidth, frameHeight))
                }
            })
            
        }
        
        if onCompleted != nil {
            onCompleted!(filenames)
        }
    }
    
    fileprivate func createThumbnail(from url:URL, size:Int) -> NSImage? {
        let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return nil }
            
            let thumbnailOptions = [
                String(createThumbnailWithTransform): true,
                String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
                String(kCGImageSourceThumbnailMaxPixelSize): size
                ] as [String : Any]
            guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
            return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
        }
        return nil
    }
}

extension CGImage {
    
    static func getCGImage(from file: URL) -> CGImage? {
        // Extract NSImage from image file
        guard let nsImage = NSImage(contentsOfFile: file.path) else {
            print("\(Date()) [CGImage] File cannot be converted to NSImage: \(file.path)")
            return nil
        }
        // Convert NSImage to CGImage
        var imageRect: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: nsImage.size)
        return nsImage.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
    }
    
    @available(OSX 10.13, *)
    func cropImageToFace(_ face: VNFaceObservation, borderPercentage:CGFloat? = nil) -> (CGImage?, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat) {
        let percentage: CGFloat = borderPercentage ?? 0.3
        let newWidth = face.boundingBox.width * CGFloat(width)
        let newHeight = face.boundingBox.height * CGFloat(height)
        let x = face.boundingBox.origin.x * CGFloat(width)
        let y = (1 - face.boundingBox.origin.y) * CGFloat(height) - newHeight
        let croppingRect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        let increasedRect = croppingRect.insetBy(dx: newWidth * -percentage, dy: newHeight * -percentage)
        print("\(Date()) [CGImage] x:\(x), y:\(y), width:\(newWidth), height:\(newHeight)")
        print("\(Date()) [CGImage] increased x:\(increasedRect.origin.x), y:\(increasedRect.origin.y), width:\(increasedRect.size.width), height:\(increasedRect.size.height)")
        let cgImage = self.cropping(to: increasedRect)
        return (cgImage, x, y, newWidth, newHeight, increasedRect.origin.x, increasedRect.origin.y, increasedRect.size.width, increasedRect.size.height)
    }
}
