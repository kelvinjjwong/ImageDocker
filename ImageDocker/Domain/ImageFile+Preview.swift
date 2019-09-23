//
//  ImageFile+Preview.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/23.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
import CoreLocation
import SwiftyJSON
import AVFoundation
import GRDB

extension ImageFile {
    
    // MARK: THUMBNAIL
    
    internal func setThumbnail(_ url:URL) -> NSImage? {
        do {
            let properties = try url.resourceValues(forKeys: [.typeIdentifierKey])
            guard let fileType = properties.typeIdentifier else { return nil }
            if UTTypeConformsTo(fileType as CFString, kUTTypeImage) {
                //DispatchQueue.global().async {
                return self.getThumbnailImageFromPhoto(url)
                //}
            }else if UTTypeConformsTo(fileType as CFString, kUTTypeMovie) {
                //DispatchQueue.global().async {
                return self.getThumbnailImageFromVideo(url)
                //}
            }
        }
        catch {
            print("Unexpected error occured: \(error).")
        }
        return nil
    }
    
    private func getThumbnailImageFromVideo(_ url:URL) -> NSImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return NSImage(cgImage: imageRef, size: NSZeroSize)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    private func getThumbnailImageFromPhoto(_ url:URL) -> NSImage? {
        let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return nil }
            
            let thumbnailOptions = [
                String(createThumbnailWithTransform): true,
                String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
                String(kCGImageSourceThumbnailMaxPixelSize): 180
                ] as [String : Any]
            guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
            return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
        }
        return nil
    }
    
    func loadNSImage() -> NSImage? {
        if FileManager.default.fileExists(atPath: url.path) {
            return NSImage(byReferencingFile: url.path)
        }else{
            return nil
        }
    }
    
    /// Load an image thumbnail
    /// - Returns: NSImage of the thumbnail
    ///
    /// If image propertied can not be accessed or if needed properties
    /// do not exist the file is assumed to be a non-image file and a zero
    /// sized empty image is returned.
    internal func loadPreview() -> NSImage {
        if self.isVideo == true { return NSImage(size: NSMakeRect(0, 0, 0, 0).size) }
        
        return url.loadImage(maxDimension: 512)
    }
}


// MARK: HELPER

enum ImageType : Int {
    case photo
    case video
    case other
}

extension URL {
    
    func imageType() -> ImageType {
        var type:ImageType = .other
        
        if lastPathComponent.split(separator: Character(".")).count > 1 {
            let fileExt:String = (lastPathComponent.split(separator: Character(".")).last?.lowercased())!
            if fileExt == "jpg" || fileExt == "jpeg" || fileExt == "png" {
                type = .photo
            }else if fileExt == "mov" || fileExt == "mp4" || fileExt == "mpeg" {
                type = .video
            }
        }
        
        if type == .other {
            do {
                let properties = try self.resourceValues(forKeys: [.typeIdentifierKey])
                guard let fileType = properties.typeIdentifier else { return type }
                if UTTypeConformsTo(fileType as CFString, kUTTypeImage) {
                    type = .photo
                }else if UTTypeConformsTo(fileType as CFString, kUTTypeMovie) {
                    type = .video
                }
            }
            catch {
                print("Unexpected error occured when recognizing image type: \(error).")
            }
        }
        
        return type
    }
}
