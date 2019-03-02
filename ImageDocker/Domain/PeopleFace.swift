//
//  PeopleFace.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/23.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class PeopleFace {
    
    // MARK: SIZE
    
    static let ThumbnailSize = 60
    static let PreviewSize = 180
    static let SourceImageSize = 180
    
    // MARK: DATA
    
    var data:ImageFace
    var image:Image?
    var person:People?
    
    // MARK: UI LINKAGE
    var collectionViewItem:FaceCollectionViewItem?
    
    // MARK: URL
    
    fileprivate var faceURL:URL?
    
    // MARK: INIT
    
    init(_ imageFace:ImageFace) {
        self.data = imageFace
        
        self.generateFaceUrl()
    }
    
    init(person:People){
        self.data = ImageFace.fromPerson(peopleId: person.id,
                                        repositoryPath: person.iconRepositoryPath, cropPath: person.iconCropPath,
                                        subPath: person.iconSubPath, filename: person.iconFilename)
        self.person = person
        self.generateFaceUrl()
    }
    
    fileprivate func generateFaceUrl() {
        // get face url for thumbnail and preview
        if self.data.cropPath != "" && self.data.subPath != "" && self.data.filename != "" {
            self.faceURL = URL(fileURLWithPath: self.data.cropPath).appendingPathComponent(self.data.subPath).appendingPathComponent(self.data.filename)
        }
    }
    
    // MARK: PERSON NAME
    lazy var personName:String = self.loadPersonName()
    
    fileprivate func loadPersonName() -> String {
        if self.person == nil {
            if let peopleId = self.data.peopleId, let person = ModelStore.default.getPerson(id: peopleId) {
                return person.name
            }
        }else{
            return self.person?.name ?? "Noname"
        }
        return "Unknown"
    }
    
    // MARK: SOURCE IMAGE
    
    lazy var sourceImage:NSImage? = self.loadSourceImage()
    
    fileprivate func loadSourceImage() -> NSImage? {
        if let sourceImage = ModelStore.default.getImage(id: self.data.imageId) {
            let url = URL(fileURLWithPath: sourceImage.path)
            return self.loadImage(url, size: PeopleFace.SourceImageSize)
        }
        return nil
    }
    
    // MARK: THUMBNAIL AND PREVIEW IMAGE
    
    lazy var preview:NSImage? = self.loadFaceImage(size: PeopleFace.PreviewSize)
    
    lazy var thumbnail:NSImage? = self.loadFaceImage(size: PeopleFace.ThumbnailSize)
    
    fileprivate func loadFaceImage(size:Int) -> NSImage? {
        if let url = self.faceURL {
            return self.loadImage(url, size: size)
        }
        return nil
    }
    
    fileprivate func loadImage(_ url:URL, size:Int) -> NSImage? {
        do {
            let properties = try url.resourceValues(forKeys: [.typeIdentifierKey])
            guard let fileType = properties.typeIdentifier else { return nil }
            if UTTypeConformsTo(fileType as CFString, kUTTypeImage) {
                //DispatchQueue.global().async {
                return self.getThumbnailImageFromPhoto(url, size: size)
                //}
            }
        }
        catch {
            print("Unexpected error occured: \(error).")
        }
        return nil
    }
    
    fileprivate func getThumbnailImageFromPhoto(_ url:URL, size:Int) -> NSImage? {
        let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return nil }
            
            let thumbnailOptions = [
                String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
                String(kCGImageSourceThumbnailMaxPixelSize): size
                ] as [String : Any]
            guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
            return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
        }
        return nil
    }
    
    // MARK: FACES COLLECTION
    
    // MARK: YEARS LIST OF FACES
    
    // MARK: MONTHS LIST OF FACES
    
    // MARK: FAMILY LIST
    
    // MARK: RELATIONSHIP LIST
    
    
}
