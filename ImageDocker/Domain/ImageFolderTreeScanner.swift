//
//  ImageFolderScanner.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/5.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

class ImageFolderTreeScanner {
    
    static let `default` = ImageFolderTreeScanner()
    
    func walkthruDirectory(at folder:URL, resourceKeys: [URLResourceKey] = []) -> FileManager.DirectoryEnumerator{
        let enumerator = FileManager.default.enumerator(at: folder,
                                                        includingPropertiesForKeys: resourceKeys,
                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                            print("directoryEnumerator error at \(url): ", error)
                                                            return true
        })!
        return enumerator
    }
    
    func isImageFile(_ file: URL) -> Bool {
        if file.pathExtension == "jpg" || file.pathExtension == "JPG"
            || file.pathExtension == "jpeg" || file.pathExtension == "JPEG"
            || file.pathExtension == "mp4" || file.pathExtension == "MP4"
            || file.pathExtension == "MOV" || file.pathExtension == "MOV"
            || file.pathExtension == "mpg" || file.pathExtension == "MPG" {
            return true
        }
        return false
    }
    
    func countImagesInFolder(_ folder: URL) -> Int {
        var count:Int = 0
        let enumeratorFiles = self.walkthruDirectory(at: folder)
        for case let file as URL in enumeratorFiles {
            if isImageFile(file) {
                count += 1
            }
        }
        return count
    }
    
    func scanImageFolderFromDatabase() -> [ImageFolder] {
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        let containers = ModelStore.getAllContainers()
        for container in containers {
            let imageFolder:ImageFolder = ImageFolder(URL(fileURLWithPath: container.path!), countOfImages: Int(container.imageCount), updateModelStore: false)
            if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) {
                imageFolder.setParent(parent)
            }
            imageFolders.append(imageFolder)
        }
        return imageFolders
    }
    
    func scanImageFolder(path: String) -> [ImageFolder] {
        let url:URL = URL(string: path)!
        return scanImageFolder(startingURL: url)
    }
    
    func scanImageFolder(startingURL: URL) -> [ImageFolder] {
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey, .isHiddenKey, .parentDirectoryURLKey, .isReadableKey]
        
        let countOfRootImage:Int = self.countImagesInFolder(startingURL)
        imageFolders.append(ImageFolder(startingURL, countOfImages: countOfRootImage))
        
        let enumerator = self.walkthruDirectory(at: startingURL, resourceKeys: resourceKeys)
        for case let folderURL as URL in enumerator {
            do {
                let resourceValues = try folderURL.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isDirectory! && !resourceValues.isHidden! && resourceValues.isReadable! {
                    let countOfImage:Int = self.countImagesInFolder(folderURL)
                    if countOfImage > 0 {
                        let imageFolder:ImageFolder = ImageFolder(folderURL, countOfImages: countOfImage)
                        if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) {
                            imageFolder.setParent(parent)
                        }
                        imageFolders.append(imageFolder)
                    }
                }
            } catch {
                print(error)
            }
        }
        ModelStore.save()
        return imageFolders
    }
}
