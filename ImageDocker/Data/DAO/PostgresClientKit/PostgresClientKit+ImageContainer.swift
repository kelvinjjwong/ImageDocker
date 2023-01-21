//
//  PostgresClientKit+ImageContainer.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class RepositoryDaoPostgresCK : RepositoryDaoInterface {
    
    let logger = ConsoleLogger(category: "DB", subCategory: "RepositoryDaoPostgresCK", includeTypes: [])
    
    // MARK: IMAGE REPOSITORY CRUD
    
    func findRepository(volume:String, repositoryPath: String) -> ImageRepository? {
        let db = PostgresConnection.database()
        return ImageRepository.fetchOne(db, parameters: ["repositoryVolume": volume, "repositoryPath": repositoryPath])
    }
    
    func getRepository(id: Int) -> ImageRepository? {
        let db = PostgresConnection.database()
        return ImageRepository.fetchOne(db, parameters: ["id": id])
    }
    
    func getRepository(repositoryPath: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        return ImageContainer.fetchOne(db, where: "(\"repositoryPath\" = $1 or \"repositoryPath\" = $2) and \"parentFolder\"=''", values: [repositoryPath.removeLastStash(), repositoryPath.withLastStash()])
    }
    
    func deleteRepository(repositoryRoot: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            // delete container-self
            try db.execute(sql: """
                delete from "ImageContainer" where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())"])
            // delete sub-containers
            try db.execute(sql: """
                delete from "Image" where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())"])
            return .OK
        }catch{
            self.logger.log(error)
            return .ERROR
        }
    }
    
    func getRepositoriesV2(orderBy: String, condition:SearchCondition?) -> [ImageRepository] {
        let db = PostgresConnection.database()
        var result:[ImageRepository] = []
        let containers = ImageRepository.fetchAll(db, orderBy: orderBy)
        if let imagesCondition = condition, !imagesCondition.isEmpty() {
            let containersConformCondition = self.getRepositoryPaths(imagesCondition: imagesCondition)
            if containersConformCondition.count > 0 {
                for container in containers {
                    if containersConformCondition.contains(container.repositoryPath) {
                        result.append(container)
                    }
                }
            }
        }else{
            result = containers
        }
        
        return result
    }
    
    func getRepositories(orderBy: String, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        var result:[ImageContainer] = []
        let containers = ImageContainer.fetchAll(db, parameters: ["parentFolder" : ""], orderBy: orderBy)
        if let imagesCondition = condition, !imagesCondition.isEmpty() {
            let containersConformCondition = self.getRepositoryPaths(imagesCondition: imagesCondition)
            if containersConformCondition.count > 0 {
                for container in containers {
                    if containersConformCondition.contains(container.repositoryPath) {
                        result.append(container)
                    }
                }
            }
        }else{
            result = containers
        }
        
        return result
    }
    
    func getRepositoryPaths(imagesCondition:SearchCondition) -> [String] {
        var result:[String] = []
        
        var additionalConditions = ""
        if !imagesCondition.isEmpty() {
            (additionalConditions, _) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: imagesCondition, includeHidden: true, quoteColumn: true)
        }
        if additionalConditions.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            additionalConditions = "AND \(additionalConditions)"
        }
        
        let sql = """
        select distinct "repositoryPath" from
        (
        select path, event,
        "photoTakenYear",
        "photoTakenMonth",
        "photoTakenDay",
        "imageSource",
        "longDescription",
        "shortDescription",
        "place",
        "country",
        "province",
        "city",
        "district",
        "businessCircle",
        "street",
        "address",
        "addressDescription",
        "assignPlace",
        "assignCountry",
        "assignProvince",
        "assignCity",
        "assignDistrict",
        "assignBusinessCircle",
        "assignStreet",
        "assignAddress",
        "assignAddressDescription",
        "cameraMaker",
        "cameraModel",
        "softwareName",
        "repositoryPath",
        "filename"
        from "Image"
        ) t
        where 1=1 \(additionalConditions)
        order by "repositoryPath" DESC
        """
//        self.logger.log(sql)
        
        final class TempRecord : PostgresCustomRecord {
            var repositoryPath:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.repositoryPath)
        }
        return result
    }
    
    // MARK: IMAGE REPOSITORY UPDATE
    
    func hideRepository(repositoryRoot: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = true where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())%"])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = true where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = true where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())%"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = true where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())"])
        }catch{
            self.logger.log(error)
            return .ERROR
        }
        return .OK
    }
    
    func showRepository(repositoryRoot: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = false where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())%"])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = false where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = false where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())%"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = false where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withLastStash())"])
        }catch{
            self.logger.log(error)
            return .ERROR
        }
        return .OK
    }
    
    func getLastPhotoTakenDateOfRepositories() -> [String : String] {
        let db = PostgresConnection.database()
        
        final class TempRecord : PostgresCustomRecord {
            
            var name:String = ""
            var lastPhotoTakenDate:String = ""
            public init() {}
        }
        
        let sql = """
        select "name","lastPhotoTakenDate" from
        (select "name",("path" || '/') as "repositoryPath" from "ImageContainer" where "parentFolder"='') c left join (
        select max("photoTakenDate") as "lastPhotoTakenDate","repositoryPath" from "Image" group by "repositoryPath") i on c."repositoryPath" = i."repositoryPath"
        where "lastPhotoTakenDate" is not null
        order by "name"
        """
        var results:[String:String] = [:]
        let records = TempRecord.fetchAll(db, sql:sql)
        for row in records {
            results[row.name] = row.lastPhotoTakenDate
        }
        return results
    }
    
    // MARK: IMAGE CONTAINER CRUD
    
    func getOrCreateContainer(name: String, path: String, parentPath parentFolder: String, repositoryPath: String, homePath: String, storagePath: String, facePath: String, cropPath: String, subPath: String, manyChildren: Bool, hideByParent: Bool) -> (ImageContainer, Bool) {
        
        let db = PostgresConnection.database()
        if let container = ImageContainer.fetchOne(db, parameters: ["path": path]) {
            return (container, false)
        }else{
            let container = ImageContainer(name: name,
                                       parentFolder: parentFolder,
                                       path: path,
                                       imageCount: 0,
                                       repositoryPath: repositoryPath.withLastStash(),
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
            container.save(db)
            return (container, true)
        }
    }
    
    func createContainer(name: String, repositoryId: Int, parentId:Int, subPath: String, repositoryPath: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        let container = ImageContainer()
        container.name = name
        container.repositoryId = repositoryId
        container.parentId = parentId
        container.subPath = subPath.removeFirstStash().removeLastStash()
        container.repositoryPath = repositoryPath.withFirstStash().withLastStash()
        container.path = "\(repositoryPath.withFirstStash().removeLastStash())\(subPath.withFirstStash().removeLastStash())"  // legacy pk
        container.save(db)
        
        if let createdContainer = self.getContainer(path: container.path) {
            return createdContainer
        }else{
            return nil
        }
    }
    
    func saveImageContainer(container: ImageContainer) -> ExecuteState {
        let db = PostgresConnection.database()
        container.save(db)
        return .OK
    }
    
    func deleteContainer(path: String, deleteImage: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            // delete container-self
            try db.execute(sql: """
                DELETE FROM "ImageContainer" WHERE "path"='\(path)'
                """)
            // delete sub-containers
            try db.execute(sql: """
                DELETE FROM "ImageContainer" WHERE "path" LIKE '\(path.withLastStash())%'
                """)
            // delete images
            if deleteImage {
                try db.execute(sql: """
                    DELETE FROM "Image" WHERE "path" LIKE '\(path.withLastStash())%'
                    """)
            }
            return .OK
        }catch{
            self.logger.log(error)
            return .ERROR
        }
    }
    
    func findContainer(repositoryId:Int, subPath:String) -> ImageContainer? {
        let db = PostgresConnection.database()
        var subpath = subPath
        if subPath.hasPrefix("/") {
            subpath = subpath.replacingFirstOccurrence(of: "/", with: "")
        }
        return ImageContainer.fetchOne(db, parameters: ["repositoryId": repositoryId, "subPath": subpath])
    }
    
    func findContainer(repositoryVolume:String, repositoryPath:String, subPath:String) -> ImageContainer? {
        let db = PostgresConnection.database()
        var subpath = subPath
        if subPath.hasPrefix("/") {
            subpath = subpath.replacingFirstOccurrence(of: "/", with: "")
        }
        self.logger.log(.debug, "Find container with repositoryPath: \(repositoryVolume)\(repositoryPath.withLastStash()) , subPath: \(subpath)")
        return ImageContainer.fetchOne(db, parameters: ["repositoryPath": "\(repositoryVolume)\(repositoryPath.withLastStash())", "subPath": subpath])
    }
    
    func getContainer(path: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        return ImageContainer.fetchOne(db, parameters: ["path" : path])
    }
    
    func getAllContainers() -> [ImageContainer] {
        let db = PostgresConnection.database()
        return ImageContainer.fetchAll(db, orderBy: "\"path\"")
    }
    
    func getContainers(rootPath: String) -> [ImageContainer] {
        let db = PostgresConnection.database()
        return ImageContainer.fetchAll(db, where: "\"path\" like $1", values: ["\(rootPath.withLastStash())%"])
    }
    
    // MARK: SUB CONTAINER
    
    func getSubContainersSingleLevel(repositoryId:Int, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        if let containerOfRepository = ImageContainer.fetchOne(db, parameters: ["repositoryId": repositoryId, "parentId" : 0]) {
            return ImageContainer.fetchAll(db, parameters: ["repositoryId": repositoryId, "parentId": containerOfRepository.id], orderBy: "\"subPath\"")
        }else {
            return []
        }
    }
    
    func getSubContainersSingleLevel(containerId:Int, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        return ImageContainer.fetchAll(db, parameters: ["parentId": containerId], orderBy: "\"subPath\"")
    }
    
    func getSubContainers(parent path: String, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        var result:[ImageContainer] = []
        let containers = ImageContainer.fetchAll(db, parameters: ["parentFolder" : path], orderBy: "\"path\"")
        if let imagesCondition = condition, !imagesCondition.isEmpty() {
            let containersConformCondition = self.getSubContainerPaths(parent: path, imagesCondition: imagesCondition)
            if containersConformCondition.count > 0 {
                for container in containers {
                    for conform in containersConformCondition {
                        if conform == container.path || conform.hasPrefix(container.path.withLastStash()) {
                            result.append(container)
                            break
                        }
                    }
                }
            }
        }else{
            result = containers
        }
        
        return result
    }
    
    func getSubContainerPaths(parent:String, imagesCondition:SearchCondition) -> [String] {
        var result:[String] = []
        
        var additionalConditions = ""
        if !imagesCondition.isEmpty() {
            (additionalConditions, _) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: imagesCondition, includeHidden: true, quoteColumn: true)
        }
        if additionalConditions.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            additionalConditions = "AND \(additionalConditions)"
        }
        
        let sql = """
        select DISTINCT "containerPath" from
        (
        select path, "containerPath", event,
        "photoTakenYear",
        "photoTakenMonth",
        "photoTakenDay",
        "imageSource",
        "longDescription",
        "shortDescription",
        "place",
        "country",
        "province",
        "city",
        "district",
        "businessCircle",
        "street",
        "address",
        "addressDescription",
        "assignPlace",
        "assignCountry",
        "assignProvince",
        "assignCity",
        "assignDistrict",
        "assignBusinessCircle",
        "assignStreet",
        "assignAddress",
        "assignAddressDescription",
        "cameraMaker",
        "cameraModel",
        "softwareName",
        "repositoryPath",
        "filename"
        from "Image"
        ) t
        where path like '\(parent.replacingOccurrences(of: "'", with: "''").withLastStash())%' \(additionalConditions)
        order by "containerPath" DESC
        """
//        self.logger.log(sql)
        
        final class TempRecord : PostgresCustomRecord {
            var repositoryPath:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.repositoryPath)
        }
        return result
    }
    
    func countSubContainers(parent path: String) -> Int {
        let db = PostgresConnection.database()
        return ImageContainer.count(db, parameters: ["parentFolder" : path])
    }
    
    func countSubContainers(containerId:Int) -> Int {
        let db = PostgresConnection.database()
        return ImageContainer.count(db, parameters: ["parentId": containerId])
    }
    
    func createEmptyImageContainerLinkToRepository(repositoryId:Int) -> ImageContainer? {
        if let repository = RepositoryDao.default.getRepository(id: repositoryId) {
            
            if let container = self.createContainer(name: repository.name,
                                                    repositoryId: repositoryId,
                                                    parentId: 0,
                                                    subPath: "",
                                                    repositoryPath: Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repository.repositoryVolume, repositoryPath: repository.repositoryPath)) {
                self.logger.log(.info, "Created an empty ImageContainer linking to ImageRepository, repositoryId:\(repositoryId), containerId:\(container.id), name:\(container.name)")
                return container
            }else{
                self.logger.log(.error, "Unable to create an empty ImageContainer linking to ImageRepository, repositoryId:\(repositoryId)")
                return nil
            }
        }else{
            self.logger.log(.error, "Unable to find ImageRepository record in database, repositoryId:\(repositoryId)")
            return nil
        }
    }
    
    func countSubContainers(repositoryId:Int) -> Int {
        let db = PostgresConnection.database()
        if let container = ImageContainer.fetchOne(db, parameters: ["repositoryId": repositoryId, "parentId": 0]) {
            return ImageContainer.count(db, parameters: ["parentId": container.id])
        }else{
            self.logger.log(.warning, "Unable to find ImageRepository's linked ImageContainer record in database, repositoryId:\(repositoryId)")
            if let createdContainer = self.createEmptyImageContainerLinkToRepository(repositoryId: repositoryId) {
                return ImageContainer.count(db, parameters: ["parentId": createdContainer.id])
            }else{
                return 0
            }
        }
    }
    
    func countSubImages(containerId:Int) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, parameters: ["containerId": containerId])
    }
    
    // MARK: IMAGE CONTAINER QUERIES
    
    func getAllContainerPathsOfImages(rootPath: String?) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        
        final class TempRecord : PostgresCustomRecord {
            
            var containerpath:String = ""
            public init() {}
        }
        
        var records:[TempRecord] = []
        var sql = ""
        if let root = rootPath {
            sql = """
            select distinct "containerPath" from "Image" where ("repositoryPath" = $1 or "repositoryPath" = $2) order by "containerpath"
            """
            records = TempRecord.fetchAll(db, sql: sql, values: [root.withLastStash(), root.removeLastStash()])
        }else{
            sql = """
            select distinct "containerpath" from "image" order by "containerpath"
            """
            records = TempRecord.fetchAll(db, sql: sql)
        }
        for row in records {
            result.insert("\(row.containerpath)")
        }
        return result
    }
    
    func getAllContainerPaths(rootPath: String?) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        
        final class TempRecord : PostgresCustomRecord {
            
            var path:String = ""
            public init() {}
        }
        
        var records:[TempRecord] = []
        var sql = ""
        if let root = rootPath {
            sql = """
            select "path" from "ImageContainer" where "path" like $1 order by "path"
            """
            records = TempRecord.fetchAll(db, sql: sql, values: ["\(root)%"])
        }else{
            sql = """
            select "path" from "ImageContainer" order by "path"
            """
            records = TempRecord.fetchAll(db, sql: sql)
        }
        for row in records {
            result.insert("\(row.path)")
        }
        return result
    }
    
    func getAllContainerPaths(repositoryPath: String?) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        
        final class TempRecord : PostgresCustomRecord {
            
            var path:String = ""
            public init() {}
        }
        
        var records:[TempRecord] = []
        var sql = ""
        if let repoPath = repositoryPath {
            sql = """
            select "path" from "ImageContainer" where ("repositoryPath" = $1 or "repositoryPath" = $2) order by "path"
            """
            records = TempRecord.fetchAll(db, sql: sql, values: [repoPath.withLastStash(), repoPath.removeLastStash()])
        }else{
            sql = """
            select "path" from "ImageContainer" order by "path"
            """
            records = TempRecord.fetchAll(db, sql: sql)
        }
        for row in records {
            result.insert("\(row.path)")
        }
        return result
    }
    
    // MARK: IMAGE CONTAINER UPDATE
    
    func updateImageContainerWithRepositoryId(containerId:Int, repositoryId:Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "repositoryId" = $1 where "id" = $2
                """, parameterValues: [repositoryId, containerId])
        }catch{
            self.logger.log(error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerWithParentId(containerId:Int, parentId:Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "parentId" = $1 where "id" = $2
                """, parameterValues: [parentId, containerId])
        }catch{
            self.logger.log(error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerParentFolder(path: String, parentFolder: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "parentFolder" = $1 where "path" = $2
                """, parameterValues: [path, parentFolder])
        }catch{
            self.logger.log(error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerHideByParent(path: String, hideByParent: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hideByParent" = \(hideByParent ? "true" : "false") where "path" = $1
                """, parameterValues: [path])
        }catch{
            self.logger.log(error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerPaths(oldPath: String, newPath: String, repositoryPath: String, parentFolder: String, subPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "path" = $1, "repositoryPath" = $2, "parentFolder" = $3, "subPath" = $4 where "path" = $5
                """, parameterValues: [newPath, repositoryPath.withLastStash(), parentFolder, subPath, oldPath])
        }catch{
            self.logger.log(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerRepositoryPaths(oldPath: String, newPath: String, repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "path" = $1, "repositoryPath" = $2 where "path" = $3
                """, parameterValues: [newPath, repositoryPath.withLastStash(), oldPath])
        }catch{
            self.logger.log(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerToggleManyChildren(path: String, state: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "manyChildren" = \(state ? "true" : "false") where "path" = $1
                """, parameterValues: [path])
            try db.execute(sql: """
                update "ImageContainer" set "hideByParent" = \(state ? "true" : "false") where "path" like $1
                """, parameterValues: ["\(path.withLastStash())%"])
        }catch{
            self.logger.log(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerSubContainers(path:String) -> Int {
        let subContainers = self.countSubContainers(parent: path)
        self.logger.log("[DB][PostgresClientKit+ImageContainer] updating subContainers amount to \(subContainers) - \(path)")
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "subContainers" = \(subContainers) where "path" = $1
                """, parameterValues: [path])
        }catch{
            self.logger.log(error)
            return subContainers
        }
        return subContainers
    }
    
    func hideContainer(path: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByContainer" = true where "path" = $1
                """, parameterValues: [path])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByContainer" = true where "path" like $1
                """, parameterValues: ["\(path.withLastStash())%"])
            try db.execute(sql: """
                update "Image" set "hiddenByContainer" = true where "path" like $1
                """, parameterValues:["\(path.withLastStash())%"])
        }catch{
            self.logger.log(error)
            return .ERROR
        }
        return .OK
    }
    
    func showContainer(path: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByContainer" = false where "path" = $1
                """, parameterValues: [path])
            try db.execute(sql: """
                update "Image" set "hiddenByContainer" = false where "path" like $1
                """, parameterValues:["\(path.withLastStash())%"])
        }catch{
            self.logger.log(error)
            return .ERROR
        }
        return .OK
    }
    

}
