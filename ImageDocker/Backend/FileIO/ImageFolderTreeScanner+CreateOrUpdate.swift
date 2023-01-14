//
//  ImageFolderTreeScanner+CreateOrUpdate.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/14.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation

extension ImageFolderTreeScanner {
    
    func createRepository(name:String,
                                 path:String,
                                 homePath:String,
                                 storagePath:String,
                                 facePath:String,
                                 cropPath:String) -> ImageFolder {
        self.logger.log("Creating repository with name:\(name) , path:\(path)")
        return ImageFolder(URL(fileURLWithPath: path),
                            name: name,
                            repositoryPath: path,
                            homePath: homePath,
                            storagePath: storagePath,
                            facePath: facePath,
                            cropPath: cropPath)
    }
    
    func createImageIfAbsent(url:String, fileUrlToRepo:[String:ImageContainer], indicator:Accumulator? = nil) -> ExecuteState {
        //self.logger.log("CREATING PHOTO \(url.path)")
        if let repo = fileUrlToRepo[url]{
            self.logger.log(">>> Creating image \(url), repo: \(repo.repositoryPath)")
            let image = ImageFile(url: URL(fileURLWithPath: url),
                                  repository: repo,
                                  indicator: indicator,
                                  quickCreate: true
            )
            
            return image.save()
        }else{
            return .NO_RECORD
        }
    }
    
    // TODO: this procedure keep running in background for a long long time, keep getting and counting db records, need consider performance issue, or need change data structure
    func updateContainers(onCompleted: (() -> Void)? = nil , indicator:Accumulator? = nil) {
        var imageFolders:[ImageFolder] = []
        let exists = RepositoryDao.default.getAllContainers()
        if exists.count > 0 {
            for exist in exists{
                //self.logger.log("Updating image count of container: \(exist.path)")
                let imageFolder = ImageFolder(URL(fileURLWithPath: exist.path),
                                              name: exist.name,
                                              repositoryPath: exist.repositoryPath,
                                              homePath: exist.homePath,
                                              storagePath: exist.storagePath,
                                              facePath: exist.facePath,
                                              cropPath: exist.cropPath,
                                              countOfImages: Int(exist.imageCount)
                )
                imageFolders.append(imageFolder)
                
                let count = ImageCountDao.default.countPhotoFiles(rootPath: "\(imageFolder.url.path)/")
                if let container = imageFolder.containerFolder {
                    if container.imageCount != count {
                        var countChange = ""
                        if container.imageCount > count {
                            countChange = "-\(container.imageCount - count)"
                        }else{
                            countChange = "+\(container.imageCount - count)"
                        }
                        self.logger.log("= changing \(container.imageCount) to \(count)")  // don't delete this comment to avoid crash
                        container.imageCount = count
                        let updateState = RepositoryDao.default.saveImageContainer(container: container)
                        if indicator != nil {
                            if updateState == .OK {
                                self.logger.log("Updated image count [\(container.name) \(countChange) (\(container.parentFolder))]")
                                indicator?.display(message: "Updated [\(container.name) \(countChange) (\(container.parentFolder))]")
                            }else{
                                self.logger.log("[\(updateState)] Failed to update image count [\(container.name) \(countChange) (\(container.parentFolder))]")
                                indicator?.display(message: "Failed to update [\(container.name) \(countChange) (\(container.parentFolder))]")
                            }
                        }
                    }
                }
            }
            //ModelStore.save()
        }
        if onCompleted != nil {
            onCompleted!()
        }
    }
    
}
