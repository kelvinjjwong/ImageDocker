//
//  Helper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/25.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

// MARK: Collection / Array

extension Collection {
    func count(where test: (Element) throws -> Bool) rethrows -> Int {
        return try self.filter(test).count
    }
}

// MARK: Int

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

// MARK: Double

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: String

extension String {
    
    func emptyThenNil() -> String? {
        if self == "" {
            return nil
        }else{
            return self
        }
    }
    
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
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
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
            print("\(Date()) [String] invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
    
    func withLastStash() -> String {
        if !self.hasSuffix("/") {
            return "\(self)/"
        }
        return self
    }
    
    func withFirstStash() -> String {
        if !self.hasPrefix("/") {
            return "/\(self)"
        }
        return self
    }
    
    func removeLastStash() -> String {
        if self.hasSuffix("/") {
            return self.substring(from: 0, to: -1)
        }
        return self
    }
    
    func removeFirstStash() -> String {
        if self.hasPrefix("/") {
            return self.replacingFirstOccurrence(of: "/", with: "")
        }
        return self
    }
    
    func lastPartOfUrl() -> String {
        if self.contains(find: "/") {
            let subPathParts = self.components(separatedBy: "/")
            return subPathParts[subPathParts.count - 1]
        }else{
            return self
        }
    }
    
    func parentPath() -> String {
        let p = URL(fileURLWithPath: self.withFirstStash()).deletingLastPathComponent().path
        return p.removeFirstStash()
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
        let target = path.withLastStash()
        let me = self.withLastStash()
        return target.starts(with: me) && target != me
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
    
    func separate(by separator:String) -> [String] {
        var str = self
        if str.hasPrefix(separator) {
            str = str.substring(from: 1, to: str.count)
        }
        if str.hasSuffix(separator) {
            str = str.substring(from: 0, to: -1)
        }
        if str.contains(separator) {
            return str.components(separatedBy: separator)
        }
        return [str]
    }
    
    func getVolumeFromThisPath() -> (String, String) {
        if self.hasPrefix("/Volumes/") {
            let parts = self.components(separatedBy: "/")
            let volume = "/\(parts[1])/\(parts[2])"
            let _path = self.replacingFirstOccurrence(of: volume, with: "")
            return (volume, _path)
        }else{
            return ("", self)
        }
    }
    
    func getVolumeFromThisPath(repositoryPath: String) -> (String, String) {
        var volume = ""
        var _path = self
        if self.hasPrefix("/Volumes/") {
            let parts = self.components(separatedBy: "/")
            volume = "/\(parts[1])/\(parts[2])"
            _path = self.replacingFirstOccurrence(of: volume, with: "")
        }
        if _path.hasPrefix(repositoryPath) {
            _path = _path.replacingFirstOccurrence(of: repositoryPath, with: "")
        }
        return (volume, _path)
    }
    
    func isDirectoryExists() -> Bool {
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDir) {
            if isDir.boolValue == true {
                return true
            }
        }
        return false
    }
    
    func isFileExists() -> Bool {
        if FileManager.default.fileExists(atPath: self) {
            return true
        }
        return false
    }
    
    func mkdirs(logger:Logger? = nil) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
        }catch{
            if let logger = logger {
                logger.log(error)
            }
            return false
        }
        return true
    }
    
    func copyFile(to targetFilePath:String, logger:Logger? = nil) -> Bool{
        do{
            try FileManager.default.copyItem(atPath: self, toPath: targetFilePath)
        }catch{
            if let logger = logger {
                logger.log(error)
            }
            return false
        }
        return true
    }
    
    func moveFile(to targetFilePath:String, logger:Logger? = nil) -> Bool {
        do {
            try FileManager.default.moveItem(atPath: self, toPath: targetFilePath)
        }catch{
            if let logger = logger {
                logger.log(error)
            }
            return false
        }
        return true
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
     }

     func appendToURL(fileURL: URL) throws {
         let data = self.data(using: String.Encoding.utf8)!
         try data.append(fileURL: fileURL)
     }
 }

 extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }

// MARK: URL

extension URL {
    func walkthruDirectory(resourceKeys: [URLResourceKey] = []) -> FileManager.DirectoryEnumerator{
        let enumerator = FileManager.default.enumerator(at: self,
                                                        includingPropertiesForKeys: resourceKeys,
                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
            print("directory walkthru error, url:\(url)")
            print(error)
            return true
        })!
        return enumerator
    }
    
    func isImageFile() -> Bool {
        if Naming.FileType.recognize(from: self) != .other {
            return true
        }
        return false
    }
    
    func countImagesInFolder() -> Int {
        var count:Int = 0
        let enumeratorFiles = self.walkthruDirectory()
        for case let file as URL in enumeratorFiles {
            if file.isImageFile() {
                count += 1
            }
        }
        return count
    }
}

// MARK: -

// MARK: MemoryReleasable

class MemoryReleasable {
    
    let logger = ConsoleLogger(category: "RAM", subCategory: "HighRamJob")
    
    static let `default` = MemoryReleasable()
    
    func run(when condition:(() -> Bool), shouldStop: (() -> Bool), do closure:(() -> Void)) {
        let limitRam = Setting.performance.peakMemory() * 1024
        var continousWorking = true
        var attempt = 0
        while(condition()) {
            
            if(shouldStop()) {
                return
            }
            
            if limitRam > 0 {
                var taskInfo = mach_task_basic_info()
                var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
                let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                    }
                }
                
                if kerr == KERN_SUCCESS {
                    let usedRam = taskInfo.resident_size / 1024 / 1024
                    
                    if usedRam >= limitRam {
                        attempt += 1
                        //self.logger.log("waiting for releasing memory for Setting up containers' parent, attempt: \(attempt)")
                        continousWorking = false
                        sleep(10)
                    }else{
//                            self.logger.log("continue for Setting up containers' parent, last attempt: \(attempt)")
                        continousWorking = true
                    }
                }
            }
            
            if continousWorking {
                autoreleasepool { () -> Void in
                    closure()
                } // end of autorelease
                
            } // end of continuous working
        }
    }
}

// MARK: -

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


// MARK: Process Extension For Piping
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
            let _ = String(data: data, encoding: String.Encoding.utf8)!
            err.fileHandleForReading.closeFile()
//            self.logger.log(string)
        }
        
        if let _ = complete {
            process.terminationHandler = self.pipeTerminationAdapter(complete)
        }

        return process
    }
}
