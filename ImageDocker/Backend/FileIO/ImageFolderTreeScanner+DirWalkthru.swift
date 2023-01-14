//
//  ImageFolderTreeScanner+DirWalkthru.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/14.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation

extension ImageFolderTreeScanner {
    
    // in use
    func walkthruDirectoryForPaths(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil) -> DirectoryPaths{
        let result = DirectoryPaths()
        let startingURL = URL(fileURLWithPath: repository.path)
        let realPhysicalPath = startingURL.resolvingSymlinksInPath().path.withStash()
        let repositoryPath = repository.path.withStash()
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey, URLResourceKey.isDirectoryKey]
        guard let directoryEnumerator = FileManager.default.enumerator(at: startingURL,
                                                               includingPropertiesForKeys: resourceValueKeys,
                                                               options: options,
                                                               errorHandler: { url, error in
                                                                self.logger.log("`directoryEnumerator` error: \(error).")
                                                                return true
        }
            ) else { return result}
        
        for case let url as NSURL in directoryEnumerator {
            do {
                if ImageFolderTreeScanner.default.suppressedScan {
                    break
                }
                let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
                guard isRegularFileResourceValue.boolValue else { continue }
                guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
                guard (UTTypeConformsTo(fileType as CFString, kUTTypeImage) || UTTypeConformsTo(fileType as CFString, kUTTypeMovie)) else { continue }
                let url = url as URL
                
                // to support soft link
                let path = url.path.replacingFirstOccurrence(of: realPhysicalPath, with: repositoryPath)
                let transformedURL = URL(fileURLWithPath: path)
                self.logger.log("[FileSys Scan] Getting entry: \(path)")
                
                if indicator != nil {
                    indicator?.display(message: Words.filesys_scan_repository.fill(arguments: repositoryPath))
                }
                
                TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_repository.fill(arguments: repositoryPath), increase: false)
                
                result.filesysUrls.insert(path)
                result.fileUrlToRepo[path] = repository
                let folderUrl = transformedURL.deletingLastPathComponent()
                result.foldersysUrls.insert(folderUrl.path)
            }
            catch {
                self.logger.log("Unexpected error occured: \(error).")
            }
        }
        if indicator != nil {
            indicator?.display(message: "")
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: "", increase: false)
        return result
    }
}
