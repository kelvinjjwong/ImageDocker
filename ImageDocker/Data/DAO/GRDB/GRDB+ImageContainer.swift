//
//  ModelStore+ImageContainer.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStoreGRDB {
    // MARK: - CREATE
    
    func getOrCreateContainer(name:String,
                              path:String,
                              parentPath parentFolder:String = "",
                              repositoryPath:String,
                              homePath:String,
                              storagePath:String,
                              facePath:String,
                              cropPath:String,
                              subPath:String,
                              manyChildren:Bool = false,
                              hideByParent:Bool = false) -> ImageContainer {
        var container:ImageContainer?
        do {
            let db = try DatabaseQueue(path: ModelStore.localDBFile)
            try db.read { db in
                container = try ImageContainer.fetchOne(db, key: path)
            }
            if container == nil {
                let queue = try DatabaseQueue(path: ModelStore.localDBFile)
                try queue.write { db in
                    container = ImageContainer(name: name,
                                               parentFolder: parentFolder,
                                               path: path,
                                               imageCount: 0,
                                               repositoryPath: repositoryPath,
                                               homePath: homePath,
                                               storagePath: storagePath,
                                               facePath: facePath,
                                               cropPath: cropPath,
                                               subPath: subPath,
                                               parentPath: parentFolder.replacingFirstOccurrence(of: repositoryPath.withStash(), with: ""),
                                               hiddenByRepository: false,
                                               hiddenByContainer: false,
                                               deviceId: "",
                                               manyChildren: manyChildren,
                                               hideByParent: hideByParent,
                                               folderAsEvent: false,
                                               eventFolderLevel: 1,
                                               folderAsBrief: false,
                                               briefFolderLevel: -1
                    )
                    try container?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return container!
    }
    
    // MARK: - DELETE
    
    func deleteContainer(path: String, deleteImage:Bool = false) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                // delete container-self
                try db.execute("DELETE FROM ImageContainer WHERE path='\(path)'")
                // delete sub-containers
                try db.execute("DELETE FROM ImageContainer WHERE path LIKE '\(path.withStash())%'")
                // delete images
                if deleteImage {
                    try db.execute("DELETE FROM Image WHERE path LIKE '\(path.withStash())%'")
                }
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func deleteRepository(repositoryRoot:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("delete from ImageContainer where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
                try db.execute("delete from Image where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    // MARK: - GETTER
    
    func getContainer(path:String) -> ImageContainer? {
        var result:ImageContainer?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "path=?", arguments: StatementArguments([path])).fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getRepository(repositoryPath:String) -> ImageContainer? {
        var result:ImageContainer? = nil
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "(repositoryPath = ? or repositoryPath = ?) and parentFolder=''", arguments: [repositoryPath.withoutStash(), repositoryPath.withStash()]).fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: - SEARCH
    
    func getRepositories() -> [ImageContainer] {
        var result:[ImageContainer] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "parentFolder=''").order(Column("path").asc).fetchAll(db)
                print(result.count)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getAllContainers() -> [ImageContainer] {
        var containers:[ImageContainer] = []
        
        do {
            let dbPool = ModelStoreGRDB.sharedDBPool()
            try dbPool.read { db in
                containers = try ImageContainer.order(Column("path").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return containers
    }
    
    func getContainers(rootPath:String) -> [ImageContainer] {
        var result:[ImageContainer] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(Column("path").like("\(rootPath.withStash())%")).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllContainerPathsOfImages(rootPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                if let root = rootPath {
                    let sql = "select distinct containerpath from image where repositoryPath = ? order by containerpath"
                    let cursor = try Row.fetchCursor(db, sql, arguments:[root])
                    while let container = try cursor.next() {
                        if let path = container["containerpath"] {
                            result.insert("\(path)")
                        }
                    }
                }else{
                    let sql = "select distinct containerpath from image order by containerpath"
                    let cursor = try Row.fetchCursor(db, sql)
                    while let container = try cursor.next() {
                        if let path = container["containerpath"] {
                            result.insert("\(path)")
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllContainerPaths(rootPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                if let root = rootPath {
                    let cursor = try ImageContainer.filter(Column("path").like("\(root)%")).order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }else{
                    let cursor = try ImageContainer.order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllContainerPaths(repositoryPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                if let repoPath = repositoryPath {
                    let cursor = try ImageContainer.filter(sql: "repositoryPath = ?", arguments: [repoPath]).order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }else{
                    let cursor = try ImageContainer.order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - UPDATE SINGLE
    
    func saveImageContainer(container:ImageContainer) -> ExecuteState{
        var container = container
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try container.save(db)
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    // MARK: - UPDATE
    
    func updateImageContainerParentFolder(path:String, parentFolder:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set parentFolder = ? where path = ?", arguments: [parentFolder, path])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerHideByParent(path:String, hideByParent:Bool) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hideByParent = \(hideByParent ? 1 : 0) where path = ?", arguments: [path])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                //print("UPDATE CONTAINER old path = \(oldPath) with new path = \(newPath)")
                try db.execute("update ImageContainer set path = ?, repositoryPath = ?, parentFolder = ?, subPath = ? where path = ?", arguments: [newPath, repositoryPath, parentFolder, subPath, oldPath])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set path = ?, repositoryPath = ? where path = ?", arguments: [newPath, repositoryPath, oldPath])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerToggleManyChildren(path:String, state:Bool) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set manyChildren = \(state ? 1 : 0) where path = ?", arguments: [path])
                try db.execute("update ImageContainer set hideByParent = \(state ? 1 : 0) where path like ?", arguments: ["\(path.withStash())%"])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    // MARK: - SHOW HIDE
    
    func hideContainer(path:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByContainer = 1 where path = ?", arguments: [path])
                try db.execute("update ImageContainer set hiddenByContainer = 1 where path like ?", arguments: ["\(path.withStash())%"])
                try db.execute("update Image set hiddenByContainer = 1 where path like ?", arguments:["\(path.withStash())%"])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func showContainer(path:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByContainer = 0 where path = ?", arguments: [path])
                try db.execute("update Image set hiddenByContainer = 0 where path like ?", arguments:["\(path.withStash())%"])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func hideRepository(repositoryRoot:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByRepository = 1 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update ImageContainer set hiddenByRepository = 1 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
                try db.execute("update Image set hiddenByRepository = 1 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update Image set hiddenByRepository = 1 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func showRepository(repositoryRoot:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByRepository = 0 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update ImageContainer set hiddenByRepository = 0 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
                try db.execute("update Image set hiddenByRepository = 0 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update Image set hiddenByRepository = 0 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
}
