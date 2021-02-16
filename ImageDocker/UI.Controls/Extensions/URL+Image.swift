//
//  URL+Image.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/1/3.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa


public extension URL {
    
    func isParentOf(_ url:URL) -> Bool {
        let theOtherPath = "\(url.path)/"
        let myPath = "\(self.path)/"
        return theOtherPath.starts(with: myPath)
    }
    
    
    func loadImage(maxDimension:Int = 512) -> NSImage {
        var image = NSImage(size: NSMakeRect(0, 0, 0, 0).size)
        let url = self
        
        var imgSrc:CGImageSource? = CGImageSourceCreateWithURL(url as CFURL, nil)
        if imgSrc == nil {
            if FileManager.default.fileExists(atPath: url.path) {
                if let img = NSImage(byReferencingFile: url.path) {
                    imgSrc = CGImageSourceCreateWithData(img.tiffRepresentation! as CFData , nil)
                }
            }
        }
        if imgSrc == nil {
            return image
        }
        let imgRef = imgSrc!
        
        if let imgProps = CGImageSourceCopyPropertiesAtIndex(imgRef, 0, nil) as NSDictionary?, let orientation = imgProps[kCGImagePropertyOrientation as String]  {
            print("==== photo orientation = \(orientation)")
            if let _ = orientation as? CGImagePropertyOrientation {
                //print(ori)
            }
            
        }
        
        // Create a "preview" of the image. If the image is larger than
        // 512x512 constrain the preview to that size.  512x512 is an
        // arbitrary limit.   Preview generation is used to work around a
        // performance hit when using large raw images
        var imgOpts: [String: AnyObject] = [
            createThumbnailWithTransform : kCFBooleanTrue,
            createThumbnailFromImageIfAbsent : kCFBooleanTrue,
            thumbnailMaxPixelSize : maxDimension as AnyObject
        ]
        var checkSize = true
        repeat {
            if let imgPreview = CGImageSourceCreateThumbnailAtIndex(imgRef, 0, imgOpts as NSDictionary) {
                // Create an NSImage from the preview
                let imgHeight = CGFloat(imgPreview.height)
                let imgWidth = CGFloat(imgPreview.width)
                if imgOpts[createThumbnailFromImageAlways] == nil &&
                    imgHeight < 512 && imgWidth < 512 {
                    // thumbnail too small.   Build a larger thumbnail
                    imgOpts[createThumbnailFromImageIfAbsent] = nil
                    imgOpts[createThumbnailFromImageAlways] = kCFBooleanTrue
                    continue
                }
                let imgRect = NSMakeRect(0.0, 0.0, imgWidth, imgHeight)
                image = NSImage(size: imgRect.size)
                image.lockFocus()
                if let currentContext = NSGraphicsContext.current {
                    let context = currentContext.cgContext
                    context.draw(imgPreview, in: imgRect)
                }
                
                image.unlockFocus()
            }
            checkSize = false
        } while checkSize
        return image
    }
    
    func getImageOrientation() -> String {
        if let imageSource = CGImageSourceCreateWithURL(self as CFURL, nil) {
            guard CGImageSourceGetType(imageSource) != nil else { return "" }
            if let imgProps = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as NSDictionary?, let orientation = imgProps[kCGImagePropertyOrientation as String]  {
                if let ori = orientation as? CGImagePropertyOrientation {
                    let o = "\(ori)"
                    if o == "1" {
                        return "UP"
                    }else if o == "3" {
                        return "DOWN"
                    }else if o == "8" {
                        return "LEFT"
                    }else if o == "6" {
                        return "RIGHT"
                    }else if o == "2" {
                        return "UP_MIRRORED"
                    }else if o == "4" {
                        return "DOWN_MIRRORED"
                    }else if o == "7" {
                        return "RIGHT_MIRRORED"
                    }else if o == "5" {
                        return "LEFT_MIRRORED"
                    }
                }
                
            }
        }
        return ""
    }
}

