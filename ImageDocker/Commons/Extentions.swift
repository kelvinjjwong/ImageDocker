//
//  Helper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/25.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

extension Int {
    
    func paddingZero(_ digits:Int) -> String {
        let str = "\(self)"
        let length = str.count
        if length < digits {
            let gap = digits - length
            return str.paddingLeft(gap, with: "0")
        }
        return str
    }
}

extension String {
    
    func paddingLeft(_ width:Int, with:String = " ") -> String{
        let toPad:Int = width - self.count
        if toPad < 1 {return self}
        var str = self
        for _ in 1...toPad {
            str = with + str
        }
        return str
    }
    
    var numberValue: NSNumber? {
        if let value = Int(self) {
            return NSNumber(value: value)
        }
        return nil
    }
    
    
    func matches(for regex: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            var match = [String]()
            for result in results {
                for i in 0..<result.numberOfRanges {
                    match.append(nsString.substring( with: result.range(at: i) ))
                }
            }
            return match
            //return results.map { nsString.substringWithRange( $0.range )} //rangeAtIndex(0)
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
    
    func withStash() -> String {
        if !self.hasSuffix("/") {
            return "\(self)/"
        }
        return self
    }
    
    func withoutStash() -> String {
        if self.hasSuffix("/") {
            return self.substring(from: 0, to: -1)
        }
        return self
    }
    
    public func substring(from: Int, to: Int) -> String {
        let length = self.lengthOfBytes(using: String.Encoding.unicode)
        if 0 <= from && from < to && to < length && 0 < to {
            let start = self.index(self.startIndex, offsetBy: from)
            let end = self.index(self.startIndex, offsetBy: to)
            let subString = self[start..<end]
            
            return String(subString)
        } else if 0 <= from && from < length && to < 0 {
            let start = self.index(self.startIndex, offsetBy: from)
            let end = self.index(self.endIndex, offsetBy: to)
            let subString = self[start..<end]
            
            return String(subString)
        } else {
            return self
        }
    }
    
    func isParentOf(_ path:String) -> Bool {
        let theOtherPath = path.withStash()
        let myPath = self.withStash()
        return theOtherPath.starts(with: myPath) && theOtherPath != myPath
    }
    
    func getNearestParent(from sortedPaths: [String]) -> String?{
        if sortedPaths.count == 0 { return nil }
        for path in sortedPaths {
            if path.isParentOf(self) {
                return path
            }
        }
        return nil
    }
}

public extension NSImage {
    func rotate(degrees:CGFloat) -> NSImage {
        
        var imageBounds = NSZeroRect ; imageBounds.size = self.size
        let pathBounds = NSBezierPath(rect: imageBounds)
        var transform = NSAffineTransform()
        transform.rotate(byDegrees: degrees)
        pathBounds.transform(using: transform as AffineTransform)
        let rotatedBounds:NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y , self.size.width, self.size.height )
        let rotatedImage = NSImage(size: rotatedBounds.size)
        
        //Center the image within the rotated bounds
        imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2)
        imageBounds.origin.y  = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2)
        
        // Start a new transform
        transform = NSAffineTransform()
        // Move coordinate system to the center (since we want to rotate around the center)
        transform.translateX(by: +(NSWidth(rotatedBounds) / 2 ), yBy: +(NSHeight(rotatedBounds) / 2))
        transform.rotate(byDegrees: degrees)
        // Move the coordinate system bak to normal
        transform.translateX(by: -(NSWidth(rotatedBounds) / 2 ), yBy: -(NSHeight(rotatedBounds) / 2))
        // Draw the original image, rotated, into the new image
        rotatedImage.lockFocus()
        transform.concat()
        self.draw(in: imageBounds, from: NSZeroRect, operation: .copy, fraction: 1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
    
    
}

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
            if let ori = orientation as? CGImagePropertyOrientation {
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


public typealias PipeProcessTerminationHandler = ((_ out: String, _ status: OSStatus) -> Void)
typealias ProcessTerminationHandler = ((_ process: Process) -> Void)

protocol Pipeable {
    func pipe(_ process: Self, _ complete:PipeProcessTerminationHandler) -> Self
}


infix operator |

/// Shorthand For Piping one process to another, very shell
///
/// - Parameters:
///   - left: One Process
///   - right: The Other Process
/// - Returns: The Other Process (To Further chain)
func | ( left: Process, right: Process) -> Process {
    return left.pipe(right)
}


// MARK: - Process Extension For Piping
public extension Process {
    
    
    /// Initalize a process with the command and some args
    ///
    /// - Parameters:
    ///   - launchPath: Sets the receiver’s executable.
    ///   - arguments: Sets the command arguments that should be used to launch the executable.
    convenience init(_ launchPath: String, _ arguments: [String]?=nil) {
        self.init()
        self.launchPath = launchPath
        self.arguments = arguments
    }
    
    
    /// Handler for converting the pipable processs termination handler to one that returns the text
    ///
    /// - Parameter complete: ((_ process: Process) -> Void)
    /// - Returns: ((_ out: String, _ status: OSStatus) -> Void)
    internal func pipeTerminationAdapter( _ complete: PipeProcessTerminationHandler?)->ProcessTerminationHandler {
        return {
            task in
            guard
                let data = (task.standardOutput as? Pipe)?.fileHandleForReading.availableData,
                let string = String(data: data, encoding: .utf8)
            else {
                complete?("", task.terminationStatus)
                return
            }
            complete?(string, task.terminationStatus)
        }
    }
    
    
    /// Called When The Pipeable task finishes
    ///
    /// - Parameter complete: ((_ out: String, _ status: OSStatus) -> Void)
    /// - Returns: Self
    func complete( _ complete:@escaping PipeProcessTerminationHandler) -> Process {
        self.terminationHandler = pipeTerminationAdapter(complete)
        return self
    }
    
    
    /// Create a process pipe
    ///
    /// - Parameters:
    ///   - launchPath: Sets the receiver’s executable.
    ///   - arguments: Sets the command arguments that should be used to launch the executable.
    ///   - complete: ((_ process: Process) -> Void) called when the chained process completes _NOTE: this should only be on the final process in the pipe_
    /// - Returns: The chained process
    func pipe(_ launchPath: String, _ arguments: [String]?=nil, _ complete:PipeProcessTerminationHandler?=nil) -> Process {
        let process = Process(launchPath, arguments)
        return self.pipe(process, complete)
    }
    
    
    /// Create a process pipe
    ///
    /// - Parameters:
    ///   - process: Process the process to chain
    ///   - complete: ((_ process: Process) -> Void) called when the chained process completes _NOTE: this should only be on the final process in the pipe_
    /// - Returns: the process to chain
    func pipe(_ process: Process, _ complete:PipeProcessTerminationHandler?=nil) -> Process {
        let command = Pipe()
        let target = Pipe()
        let err = Pipe()
        
        self.standardOutput = command
        process.standardInput = command
        process.standardOutput = target
        process.standardError = err
        
        self.terminationHandler = {
            _ in
            process.launch()
            
            let data = err.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            err.fileHandleForReading.closeFile()
            print(string)
        }
        
        if let _ = complete {
            process.terminationHandler = self.pipeTerminationAdapter(complete)
        }

        return process
    }
}
