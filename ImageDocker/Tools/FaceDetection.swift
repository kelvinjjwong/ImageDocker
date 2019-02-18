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
            print("ERROR: Cannot convert to CGImage: \(imageFile.path)")
            return
        }
        // Start face detection via Vision
        let facesRequest = VNDetectFaceRectanglesRequest { request, error in
            guard error == nil else {
                print("ERROR: \(error!.localizedDescription)")
                return
            }
            self.handleFaces(request, cgImage: cgImage, cropsPath: cropsStorage, nameBy: nameBy, onCompleted: onCompleted)
        }
        try? VNImageRequestHandler(cgImage: cgImage).perform([facesRequest])
    }
    
    fileprivate func handleFaces(_ request: VNRequest, cgImage: CGImage, cropsPath:URL, nameBy:NamingRule = .number, onCompleted: (([FaceClip]) -> Void)? = nil) {
        guard let observations = request.results as? [VNFaceObservation] else {
            return
        }
        var i = 0
        var filenames:[FaceClip] = []
        observations.forEach { observation in
            let (cgImage, x, y, width, height, frameX, frameY, frameWidth, frameHeight) = cgImage.cropImageToFace(observation, borderPercentage: self.BorderPercentage)
            guard let image = cgImage else {
                print("Image file cannot be cropped.")
                return
            }
            i += 1
            print("got \(i)")
            // Create image file from detected faces
            let data = NSBitmapImageRep.init(cgImage: image).representation(using: .jpeg, properties: [:])
            
            var filename = ""
            if nameBy == .number {
                filename = "\(i).jpg"
            }else{
                filename = "\(observation.uuid).jpg"
            }
            print("Creating crop file: \(filename)")
            filenames.append(FaceClip.new(filename, x, y, width, height, frameX, frameY, frameWidth, frameHeight))
            let faceURL = cropsPath.appendingPathComponent(filename)
            if data == nil {
                print("data object is nil")
            }
            do {
                try data?.write(to: faceURL)
            }catch{
                print(error)
            }
        }
        if onCompleted != nil {
            onCompleted!(filenames)
        }
    }
}

extension CGImage {
    
    static func getCGImage(from file: URL) -> CGImage? {
        // Extract NSImage from image file
        guard let nsImage = NSImage(contentsOfFile: file.path) else {
            print("File cannot be converted to NSImage: \(file.path)")
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
        print("x:\(x), y:\(y), width:\(newWidth), height:\(newHeight)")
        print("increased x:\(increasedRect.origin.x), y:\(increasedRect.origin.y), width:\(increasedRect.size.width), height:\(increasedRect.size.height)")
        let cgImage = self.cropping(to: increasedRect)
        return (cgImage, x, y, newWidth, newHeight, increasedRect.origin.x, increasedRect.origin.y, increasedRect.size.width, increasedRect.size.height)
    }
}
