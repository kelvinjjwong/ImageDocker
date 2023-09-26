//
//  ModelStore+ImageContainer.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB
import LoggerFactory

class RepositoryDaoGRDB : RepositoryDaoInterface {
    
    
    
    let logger = LoggerFactory.get(category: "DB", subCategory: "RepositoryDaoGRDB")
    
    func createRepository(name:String,
                          owner:String,
                          homeVolume:String, homePath:String,
                          repositoryVolume:String, repositoryPath:String,
                          storageVolume:String, storagePath:String,
                          faceVolume:String, facePath:String,
                          cropVolume:String, cropPath:String) -> ImageRepository? {
        self.logger.log(.todo, "todo DAO for SQLite")
        return nil
    }
    
    func updateRepository(id:Int, name:String,
                          owner:String,
                          homeVolume:String, homePath:String,
                          repositoryVolume:String, repositoryPath:String,
                          storageVolume:String, storagePath:String,
                          faceVolume:String, facePath:String,
                          cropVolume:String, cropPath:String
    ){
        self.logger.log(.todo, "todo DAO for SQLite")
    }
    
    func linkRepositoryToDevice(id:Int, deviceId:String) {
        self.logger.log(.todo, "todo DAO for SQLite")
    }
    
    func findRepository(volume:String, repositoryPath: String) -> ImageRepository? {
        // TODO: todo DAO for SQLite
        self.logger.log(.todo, "todo DAO for SQLite")
        return nil
    }
    
    func getRepository(id: Int) -> ImageRepository? {
        // TODO: todo DAO for SQLite
        self.logger.log(.todo, "todo DAO for SQLite")
        return nil
    }
    
    
    func getContainer(id: Int) -> ImageContainer? {
        
        self.logger.log(.todo, "todo DAO for SQLite")
        return nil
    }
    
    func getRepositoryLinkingContainer(repositoryId:Int) -> ImageContainer? {
        self.logger.log(.todo, "todo DAO for SQLite")
        return nil
    }
    
    func getContainers(repositoryId: Int) -> [ImageContainer] {
        
        self.logger.log(.todo, "todo DAO for SQLite")
        return []
    }
    
    func deleteContainer(id: Int, deleteImage: Bool) -> ExecuteState {
        
        self.logger.log(.todo, "todo DAO for SQLite")
        return .ERROR
    }
    
    func hideContainer(id: Int) -> ExecuteState {
        
        self.logger.log(.todo, "todo DAO for SQLite")
        return .ERROR
    }
    
    func showContainer(id: Int) -> ExecuteState {
        
        self.logger.log(.todo, "todo DAO for SQLite")
        return .ERROR
    }
    
    // MARK: - CREATE
    
    func createContainer(name: String, repositoryId: Int, parentId:Int, subPath: String, repositoryPath: String) -> ImageContainer? {
        // TODO: todo DAO for SQLite
        self.logger.log(.todo, "todo DAO for SQLite")
        return nil
    }
    
    func createEmptyImageContainerLinkToRepository(repositoryId:Int) -> ImageContainer? {
        self.logger.log(.todo, "todo DAO for SQLite")
        return nil
    }
    
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
                              hideByParent:Bool = false) -> (ImageContainer, Bool) {
        var exists = false
        var container:ImageContainer?
        do {
            let db = try DatabaseQueue(path: SQLiteDataSource.default.getDataSource())
            try db.read { db in
                container = try ImageContainer.fetchOne(db, key: path)
            }
            if container == nil {
                exists = false
                let queue = try DatabaseQueue(path: SQLiteDataSource.default.getDataSource())
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
                                               parentPath: parentFolder.replacingFirstOccurrence(of: repositoryPath.withLastStash(), with: ""),
                                               hiddenByRepository: false,
                                               hiddenByContainer: false,
                                               deviceId: "",
                                               manyChildren: manyChildren,
                                               hideByParent: hideByParent,
                                               folderAsEvent: false,
                                               eventFolderLevel: 1,
                                               folderAsBrief: false,
                                               briefFolderLevel: -1,
                                               subContainers: 0,
                                               repositoryId: 0
                    )
                    try container?.save(db)
                }
            }else{
                exists = true
            }
        }catch{
            self.logger.log(error)
        }
        return (container!, exists)
    }
    
    // MARK: - DELETE
    
    func deleteContainer(path: String, deleteImage:Bool = false) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                // delete container-self
                try db.execute(sql: "DELETE FROM ImageContainer WHERE path='\(path)'")
                // delete sub-containers
                try db.execute(sql: "DELETE FROM ImageContainer WHERE path LIKE '\(path.withLastStash())%'")
                // delete images
                if deleteImage {
                    try db.execute(sql: "DELETE FROM Image WHERE path LIKE '\(path.withLastStash())%'")
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func deleteRepository(repositoryRoot:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "delete from ImageContainer where repositoryPath = ?", arguments: ["\(repositoryRoot.withLastStash())"])
                try db.execute(sql: "delete from Image where repositoryPath = ?", arguments: ["\(repositoryRoot.withLastStash())"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func deleteRepository(id: Int) -> ExecuteState {
        self.logger.log(.todo, "TODO function for SQLite")
        return .ERROR
    }
    
    func hideRepository(id: Int) -> ExecuteState {
        self.logger.log(.todo, "TODO function for SQLite")
        return .ERROR
    }
    
    func showRepository(id: Int) -> ExecuteState {
        self.logger.log(.todo, "TODO function for SQLite")
        return .ERROR
    }
    
    // MARK: - REPOSITORY QUERY
    
    func getRepository(repositoryPath:String) -> ImageContainer? {
        var result:ImageContainer? = nil
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "(repositoryPath = ? or repositoryPath = ?) and parentFolder=''", arguments: [repositoryPath.removeLastStash(), repositoryPath.withLastStash()]).fetchOne(db)
            }
        }catch{
            self.logger.log(error)
        }
        return result
        
    }
    
    func getRepositoriesV2(orderBy: String = "path", condition:SearchCondition?) -> [ImageRepository] {
        self.logger.log(.todo, "TODO function for SQLite")
        return []
    }
    
    func getRepositories(orderBy:String = "path", condition:SearchCondition?) -> [ImageContainer] {
        var result:[ImageContainer] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "parentFolder=''").order(Column(orderBy).asc).fetchAll(db)
                self.logger.log(result.count)
            }
        }catch{
            self.logger.log(error)
        }
        return result
        
    }
    
    func getRepositoryPaths(imagesCondition:SearchCondition) -> [String] {
        // TDOO: GRDB implement for getRepositoryPaths
        return []
    }
    
    // MARK: SUB CONTAINERS QUERY
    
    func getSubContainersSingleLevel(repositoryId:Int, condition:SearchCondition?) -> [ImageContainer] {
        self.logger.log(.todo, "TODO function for SQLite")
        return []
    }
    
    func getSubContainersSingleLevel(containerId:Int, condition:SearchCondition?) -> [ImageContainer] {
        self.logger.log(.todo, "TODO function for SQLite")
        return []
    }
    
    func getSubContainers(parent path:String, condition:SearchCondition?) -> [ImageContainer] {
        var result:[ImageContainer] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "parentFolder=?", arguments: [path]).order(Column("path").asc).fetchAll(db)
                self.logger.log(result.count)
            }
        }catch{
            self.logger.log(error)
        }
        return result
        
    }
    
    func getSubContainerPaths(parent path:String, imagesCondition:SearchCondition) -> [String] {
        // TODO: GRDB implement for getSubContainerPaths
        return []
    }
    
    func countSubContainers(parent path:String) -> Int {
        var result = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "parentFolder=?", arguments: [path]).fetchCount(db)
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func countSubContainers(repositoryId:Int) -> Int {
        self.logger.log(.todo, "TODO function for SQLite")
        return 0
    }
    
    func countSubContainers(containerId:Int) -> Int {
        self.logger.log(.todo, "TODO function for SQLite")
        return 0
    }
    
    func countSubImages(containerId:Int) -> Int {
        self.logger.log(.todo, "TODO function for SQLite")
        return 0
    }
    
    // MARK: CONTAINERS QUERY
    
    func findContainer(repositoryId:Int, subPath:String) -> ImageContainer? {
        // TODO: todo DAO for SQLite
        logger.log(.todo, "TODO DAO function for SQLite")
        return nil
    }
    
    func findContainer(repositoryVolume:String, repositoryPath:String, subPath:String) -> ImageContainer? {
        // TODO: todo DAO for SQLite
        logger.log(.todo, "TODO DAO function for SQLite")
        return nil
    }
    
    func getContainer(path:String) -> ImageContainer? {
        var result:ImageContainer?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "path=?", arguments: StatementArguments([path])).fetchOne(db)
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getAllContainers() -> [ImageContainer] {
        var containers:[ImageContainer] = []
        
        do {
            let dbPool = try SQLiteConnectionGRDB.default.sharedDBPool()
            try dbPool.read { db in
                containers = try ImageContainer.order(Column("path").asc).fetchAll(db)
            }
        }catch{
            self.logger.log(error)
        }
        return containers
    }
    
    func getContainers(rootPath:String) -> [ImageContainer] {
        var result:[ImageContainer] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(Column("path").like("\(rootPath.withLastStash())%")).fetchAll(db)
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getAllContainerPathsOfImages(rootPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                if let root = rootPath {
                    let sql = "select distinct containerpath from image where (repositoryPath = ? or repositoryPath = ? ) order by containerpath"
                    let cursor = try Row.fetchCursor(db, sql: sql, arguments:[root.withLastStash(), root.removeLastStash()])
                    while let container = try cursor.next() {
                        if let path = container["containerpath"] {
                            result.insert("\(path)")
                        }
                    }
                }else{
                    let sql = "select distinct containerpath from image order by containerpath"
                    let cursor = try Row.fetchCursor(db, sql: sql)
                    while let container = try cursor.next() {
                        if let path = container["containerpath"] {
                            result.insert("\(path)")
                        }
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    
    func getAllContainerPathsOfImages(repositoryId:Int? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                if let repositoryId = repositoryId {
                    let sql = "select distinct containerpath from image where repositoryId = ? order by containerpath"
                    let cursor = try Row.fetchCursor(db, sql: sql, arguments:[repositoryId])
                    while let container = try cursor.next() {
                        if let path = container["containerpath"] {
                            result.insert("\(path)")
                        }
                    }
                }else{
                    let sql = "select distinct containerpath from image order by containerpath"
                    let cursor = try Row.fetchCursor(db, sql: sql)
                    while let container = try cursor.next() {
                        if let path = container["containerpath"] {
                            result.insert("\(path)")
                        }
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getAllContainerPaths(rootPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            self.logger.log(error)
        }
        return result
    }
    
    func getAllContainerPaths(repositoryPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                if let repoPath = repositoryPath {
                    let cursor = try ImageContainer.filter(sql: "repositoryPath = ? or repositoryPath = ?", arguments: [repoPath.withLastStash(), repoPath.removeLastStash()]).order(sql: "path").fetchCursor(db)
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
            self.logger.log(error)
        }
        return result
    }
    
    // MARK: - UPDATE SINGLE
    
    func saveImageContainer(container:ImageContainer) -> ExecuteState{
        var container = container
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try container.save(db)
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    // MARK: - UPDATE
    
    func updateImageContainerSubContainers(path:String) -> Int {
        let subContainers = self.countSubContainers(parent: path)
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set subContainer = \(subContainers) where path = ?", arguments: [path])
            }
        }catch{
            self.logger.log(error)
            return subContainers
        }
        return subContainers
    }
    
    func updateImageContainerWithRepositoryId(containerId:Int, repositoryId:Int) -> ExecuteState {
        self.logger.log(.todo, "TODO function for SQLite")
        return .ERROR
    }
    
    func updateImageContainerWithParentId(containerId:Int, parentId:Int) -> ExecuteState {
        self.logger.log(.todo, "TODO function for SQLite")
        return .ERROR
    }
    
    func updateImageContainerParentFolder(path:String, parentFolder:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set parentFolder = ? where path = ?", arguments: [parentFolder, path])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerHideByParent(path:String, hideByParent:Bool) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set hideByParent = \(hideByParent ? 1 : 0) where path = ?", arguments: [path])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                //self.logger.log("UPDATE CONTAINER old path = \(oldPath) with new path = \(newPath)")
                try db.execute(sql: "update ImageContainer set path = ?, repositoryPath = ?, parentFolder = ?, subPath = ? where path = ?", arguments: [newPath, repositoryPath.withLastStash(), parentFolder, subPath, oldPath])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerPaths(containerId:Int, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                //self.logger.log("UPDATE CONTAINER old path = \(oldPath) with new path = \(newPath)")
                try db.execute(sql: "update ImageContainer set path = ?, repositoryPath = ?, parentFolder = ?, subPath = ? where containerId = ?", arguments: [newPath, repositoryPath.withLastStash(), parentFolder, subPath, containerId])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set path = ?, repositoryPath = ? where path = ?", arguments: [newPath, repositoryPath.withLastStash(), oldPath])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerRepositoryPaths(containerId:Int, newPath:String, repositoryPath:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set path = ?, repositoryPath = ? where id = ?", arguments: [newPath, repositoryPath.withLastStash(), containerId])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageContainerToggleManyChildren(path:String, state:Bool) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set manyChildren = \(state ? 1 : 0) where path = ?", arguments: [path])
                try db.execute(sql: "update ImageContainer set hideByParent = \(state ? 1 : 0) where path like ?", arguments: ["\(path.withLastStash())%"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    // MARK: - SHOW HIDE
    
    func hideContainer(path:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set hiddenByContainer = 1 where path = ?", arguments: [path])
                try db.execute(sql: "update ImageContainer set hiddenByContainer = 1 where path like ?", arguments: ["\(path.withLastStash())%"])
                try db.execute(sql: "update Image set hiddenByContainer = 1 where path like ?", arguments:["\(path.withLastStash())%"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func showContainer(path:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set hiddenByContainer = 0 where path = ?", arguments: [path])
                try db.execute(sql: "update Image set hiddenByContainer = 0 where path like ?", arguments:["\(path.withLastStash())%"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func hideRepository(repositoryRoot:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set hiddenByRepository = 1 where path like ?", arguments: ["\(repositoryRoot.withLastStash())%"])
                try db.execute(sql: "update ImageContainer set hiddenByRepository = 1 where repositoryPath = ?", arguments: ["\(repositoryRoot.withLastStash())"])
                try db.execute(sql: "update Image set hiddenByRepository = 1 where path like ?", arguments: ["\(repositoryRoot.withLastStash())%"])
                try db.execute(sql: "update Image set hiddenByRepository = 1 where repositoryPath = ?", arguments: ["\(repositoryRoot.withLastStash())"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func showRepository(repositoryRoot:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update ImageContainer set hiddenByRepository = 0 where path like ?", arguments: ["\(repositoryRoot.withLastStash())%"])
                try db.execute(sql: "update ImageContainer set hiddenByRepository = 0 where repositoryPath = ?", arguments: ["\(repositoryRoot.withLastStash())"])
                try db.execute(sql: "update Image set hiddenByRepository = 0 where path like ?", arguments: ["\(repositoryRoot.withLastStash())%"])
                try db.execute(sql: "update Image set hiddenByRepository = 0 where repositoryPath = ?", arguments: ["\(repositoryRoot.withLastStash())"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
        
    // MARK: - DATE
    
    func getLastPhotoTakenDateOfRepositories() -> [String:String] {
        let sql = """
select name,lastPhotoTakenDate from
(select name,(path || '/') repositoryPath from imageContainer where parentFolder='') c left join (
select max(photoTakenDate) lastPhotoTakenDate,repositoryPath from image group by repositoryPath) i on c.repositoryPath = i.repositoryPath
order by name
"""
        var results:[String:String] = [:]
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                for row in rows {
                    if let name = row["name"] as String?, let date = row["lastPhotoTakenDate"] as String? {
                        results[name] = date
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        
        return results
    }
    
    func getOwners() -> [String] {
        return []
    }
}
