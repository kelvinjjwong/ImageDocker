//
//  PostgresClientKit+ImageContainer.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

class RepositoryDaoPostgresCK : RepositoryDaoInterface {
    
    
    
    let logger = LoggerFactory.get(category: "DB", subCategory: "RepositoryDaoPostgresCK")
    
    // MARK: IMAGE REPOSITORY CRUD
    
    func findRepository(volume:String, repositoryPath: String) -> ImageRepository? {
        let db = PostgresConnection.database()
        do {
            return try ImageRepository.fetchOne(db, parameters: ["repositoryVolume": volume, "repositoryPath": repositoryPath])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getRepository(id: Int) -> ImageRepository? {
        let db = PostgresConnection.database()
        do {
            return try ImageRepository.fetchOne(db, parameters: ["id": id])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getRepository(repositoryPath: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchOne(db, where: "(\"repositoryPath\" = $1 or \"repositoryPath\" = $2) and \"parentFolder\"=''", values: [repositoryPath.removeLastStash(), repositoryPath.withLastStash()])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func createRepository(name:String,
                          owner:String,
                          homeVolume:String, homePath:String,
                          repositoryVolume:String, repositoryPath:String,
                          storageVolume:String, storagePath:String,
                          faceVolume:String, facePath:String,
                          cropVolume:String, cropPath:String) -> ImageRepository? {
        if let exist = self.findRepository(volume: repositoryVolume, repositoryPath: repositoryPath) {
            return exist
        }else{
            let imageRepository = ImageRepository()
            imageRepository.name = name
            imageRepository.owner = owner
            imageRepository.homeVolume = homeVolume
            imageRepository.homePath = homePath
            imageRepository.repositoryVolume = repositoryVolume
            imageRepository.repositoryPath = repositoryPath
            imageRepository.storageVolume = storageVolume
            imageRepository.storagePath = storagePath
            imageRepository.faceVolume = faceVolume
            imageRepository.facePath = facePath
            imageRepository.cropVolume = cropVolume
            imageRepository.cropPath = cropPath
            let db = PostgresConnection.database()
            do {
                try imageRepository.save(db)
            }catch{
                self.logger.log(.error, error)
            }
            return self.findRepository(volume: repositoryVolume, repositoryPath: repositoryPath)
        }
        
    }
    
    func updateRepository(id:Int, name:String,
                          owner: String,
                          homeVolume:String, homePath:String,
                          repositoryVolume:String, repositoryPath:String,
                          storageVolume:String, storagePath:String,
                          faceVolume:String, facePath:String,
                          cropVolume:String, cropPath:String
    ) {
        if let imageRepository = self.getRepository(id: id) {
            imageRepository.name = name
            imageRepository.owner = owner
            imageRepository.homeVolume = homeVolume
            imageRepository.homePath = homePath
            imageRepository.repositoryVolume = repositoryVolume
            imageRepository.repositoryPath = repositoryPath
            imageRepository.storageVolume = storageVolume
            imageRepository.storagePath = storagePath
            imageRepository.faceVolume = faceVolume
            imageRepository.facePath = facePath
            imageRepository.cropVolume = cropVolume
            imageRepository.cropPath = cropPath
            let db = PostgresConnection.database()
            do {
                try imageRepository.save(db)
            }catch{
                self.logger.log(.error, error)
            }
        }
        
    }
    
    func linkRepositoryToDevice(id:Int, deviceId:String) {
        if let imageRepository = self.getRepository(id: id) {
            imageRepository.deviceId = deviceId
            let db = PostgresConnection.database()
            do {
                try imageRepository.save(db)
            }catch{
                self.logger.log(.error, error)
            }
        }
    }
    
    func unlinkRepositoryToDevice(id:Int) {
        if let imageRepository = self.getRepository(id: id) {
            imageRepository.deviceId = ""
            let db = PostgresConnection.database()
            do {
                try imageRepository.save(db)
            }catch{
                self.logger.log(.error, error)
            }
        }
    }
    
    func updateRepositorySequenceOrder(id:Int, sequenceOrder:Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageRepository" set "sequenceOrder" = $1 where "id" = $2
                """, parameterValues: [sequenceOrder, id])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
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
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func deleteRepository(id: Int) -> ExecuteState {
        
        let db = PostgresConnection.database()
        do {
            // delete images
            try db.execute(sql: """
                delete from "Image" where "repositoryId" = $1
                """, parameterValues: [id])
            // delete containers
            try db.execute(sql: """
                delete from "ImageContainer" where "repositoryId" = $1
                """, parameterValues: [id])
            // delete self
            try db.execute(sql: """
                delete from "ImageRepository" where "id" = $1
                """, parameterValues: [id])
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func getRepositoriesV2(orderBy: String, condition:SearchCondition?) -> [ImageRepository] {
        let db = PostgresConnection.database()
        var result:[ImageRepository] = []
        var containers:[ImageRepository] = []
        do {
            containers = try ImageRepository.fetchAll(db, orderBy: orderBy)
        }catch{
            self.logger.log(.error, error)
        }
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
        var containers:[ImageContainer] = []
        do {
            containers = try ImageContainer.fetchAll(db, parameters: ["parentFolder" : ""], orderBy: orderBy)
        }catch{
            self.logger.log(.error, error)
        }
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
            (additionalConditions, _) = ImageSQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: imagesCondition, includeHidden: true, quoteColumn: true)
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
        
        final class TempRecord : DatabaseRecord {
            var repositoryPath:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.repositoryPath)
            }
        }catch{
            self.logger.log(.error, error)
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
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func hideRepository(id: Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = true where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = true where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = true where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = true where "id" = $1
                """, parameterValues: [id])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func showRepository(id: Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = false where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = false where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = false where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = false where "id" = $1
                """, parameterValues: [id])
        }catch{
            self.logger.log(.error, error)
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
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func getLastPhotoTakenDateOfRepositories() -> [String : String] {
        let db = PostgresConnection.database()
        
        final class TempRecord : DatabaseRecord {
            
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
        do {
            let records = try TempRecord.fetchAll(db, sql:sql)
            for row in records {
                results[row.name] = row.lastPhotoTakenDate
            }
        }catch{
            self.logger.log(.error, error)
        }
        return results
    }
    
    // MARK: IMAGE CONTAINER CRUD
    
    func getOrCreateContainer(name: String, path: String, parentPath parentFolder: String, repositoryPath: String, homePath: String, storagePath: String, facePath: String, cropPath: String, subPath: String, manyChildren: Bool, hideByParent: Bool) -> (ImageContainer, Bool) {
        
        let dummy = ImageContainer(name: name,
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
        
        let db = PostgresConnection.database()
        do {
            if let container = try ImageContainer.fetchOne(db, parameters: ["path": path]) {
                return (container, false)
            }else{
                try dummy.save(db)
                return (dummy, true)
            }
        }catch{
            self.logger.log(.error, error)
            return (dummy, true)
        }
    }
    
    // FIXME: repositoryPath should be delete
    func createContainer(name: String, repositoryId: Int, parentId:Int, subPath: String, repositoryPath: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        let container = ImageContainer()
        container.name = name
        container.repositoryId = repositoryId
        container.parentId = parentId
        container.subPath = subPath.removeFirstStash().removeLastStash()
        container.repositoryPath = repositoryPath.withFirstStash().withLastStash()
        container.path = "\(repositoryPath.withFirstStash().removeLastStash())\(subPath.withFirstStash().removeLastStash())"  // legacy pk
        do {
            try container.save(db)
        }catch{
            self.logger.log(.error, error)
        }
        
        if let createdContainer = self.getContainer(path: container.path) {
            return createdContainer
        }else{
            return nil
        }
    }
    
    func saveImageContainer(container: ImageContainer) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try container.save(db)
        }catch{
            self.logger.log(.error, error)
        }
        return .OK
    }
    
    
    func getContainer(id: Int) -> ImageContainer? {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchOne(db, parameters: ["id" : id])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getRepositoryLinkingContainer(repositoryId:Int) -> ImageContainer? {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchOne(db, parameters: ["repositoryId" : repositoryId, "parentId" : 0])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getContainers(repositoryId: Int) -> [ImageContainer] {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchAll(db, parameters: ["repositoryId" : repositoryId])
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func deleteContainer(id: Int, deleteImage: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            // delete images and sub-containers' images
            if deleteImage {
                try db.execute(sql: """
                    WITH RECURSIVE c AS (
                       SELECT \(id) AS id
                       UNION ALL
                       SELECT sa.id
                       FROM "ImageContainer" AS sa
                          JOIN c ON c.id = sa."parentId"
                    )
                    DELETE FROM "Image" WHERE "containerId" in (select id from c)
                    """)
            }
            // delete container-self and sub-containers
            try db.execute(sql: """
                WITH RECURSIVE c AS (
                   SELECT \(id) AS id
                   UNION ALL
                   SELECT sa.id
                   FROM "ImageContainer" AS sa
                      JOIN c ON c.id = sa."parentId"
                )
                DELETE FROM "ImageContainer" WHERE id in (select id in c)
                """)
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
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
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func findContainer(repositoryId:Int, subPath:String) -> ImageContainer? {
        let db = PostgresConnection.database()
        var subpath = subPath
        if subPath.hasPrefix("/") {
            subpath = subpath.replacingFirstOccurrence(of: "/", with: "")
        }
        do {
            return try ImageContainer.fetchOne(db, parameters: ["repositoryId": repositoryId, "subPath": subpath])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    // FIXME: not accurate
    func findContainer(repositoryVolume:String, repositoryPath:String, subPath:String) -> ImageContainer? {
        let db = PostgresConnection.database()
        var subpath = subPath
        if subPath.hasPrefix("/") {
            subpath = subpath.replacingFirstOccurrence(of: "/", with: "")
        }
        self.logger.log(.debug, "Find container with repositoryPath: \(repositoryVolume)\(repositoryPath.withLastStash()) , subPath: \(subpath)")
        do {
            return try ImageContainer.fetchOne(db, parameters: ["repositoryPath": "\(repositoryVolume)\(repositoryPath.withLastStash())", "subPath": subpath])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getContainer(path: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchOne(db, parameters: ["path" : path])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getAllContainers() -> [ImageContainer] {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchAll(db, orderBy: "\"path\"")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getContainers(rootPath: String) -> [ImageContainer] {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchAll(db, where: "\"path\" like $1", values: ["\(rootPath.withLastStash())%"])
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    // MARK: SUB CONTAINER
    
    func getSubContainersSingleLevel(repositoryId:Int, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        do {
            if let containerOfRepository = try ImageContainer.fetchOne(db, parameters: ["repositoryId": repositoryId, "parentId" : 0]) {
                return try ImageContainer.fetchAll(db, parameters: ["repositoryId": repositoryId, "parentId": containerOfRepository.id], orderBy: "\"subPath\"")
            }else {
                return []
            }
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getSubContainersSingleLevel(containerId:Int, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        do {
            return try ImageContainer.fetchAll(db, parameters: ["parentId": containerId], orderBy: "\"subPath\"")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getSubContainers(parent path: String, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        var result:[ImageContainer] = []
        var containers:[ImageContainer] = []
        do {
            containers = try ImageContainer.fetchAll(db, parameters: ["parentFolder" : path], orderBy: "\"path\"")
        }catch{
            self.logger.log(.error, error)
        }
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
            (additionalConditions, _) = ImageSQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: imagesCondition, includeHidden: true, quoteColumn: true)
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
        
        final class TempRecord : DatabaseRecord {
            var repositoryPath:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.repositoryPath)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    func countSubContainers(parent path: String) -> Int {
        let db = PostgresConnection.database()
        self.logger.log(.trace, "countSubContainers(parent:\(path))")
        do {
            return try ImageContainer.count(db, parameters: ["parentFolder" : path])
        }catch{
            self.logger.log(.error, error)
            return 0
        }
    }
    
    func countSubContainers(containerId:Int) -> Int {
        let db = PostgresConnection.database()
        self.logger.log(.trace, "countSubContainers(containerId:\(containerId))")
        do {
            return try ImageContainer.count(db, parameters: ["parentId": containerId])
        }catch{
            self.logger.log(.error, error)
            return 0
        }
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
        self.logger.log(.trace, "countSubContainers(repositoryId:\(repositoryId))")
        do {
            if let container = try ImageContainer.fetchOne(db, parameters: ["repositoryId": repositoryId, "parentId": 0]) {
                return try ImageContainer.count(db, parameters: ["parentId": container.id])
            }else{
                self.logger.log(.error, "Unable to find ImageRepository's linked ImageContainer record in database, repositoryId:\(repositoryId)")
                if let createdContainer = self.createEmptyImageContainerLinkToRepository(repositoryId: repositoryId) {
                    return try ImageContainer.count(db, parameters: ["parentId": createdContainer.id])
                }else{
                    return 0
                }
            }
        }catch{
            self.logger.log(.error, error)
            return 0
        }
    }
    
    func countSubImages(containerId:Int) -> Int {
        let db = PostgresConnection.database()
        self.logger.log(.trace, "countSubImages(containerId:\(containerId))")
        do {
            return try Image.count(db, parameters: ["containerId": containerId])
        }catch{
            self.logger.log(.error, error)
            return 0
        }
    }
    
    func countSubHiddenImages(containerId:Int) -> Int {
        let db = PostgresConnection.database()
        self.logger.log(.trace, "countSubHiddenImages(containerId:\(containerId))")
        do {
            return try Image.count(db, parameters: ["containerId": containerId, "hidden": true])
        }catch{
            self.logger.log(.error, error)
            return 0
        }
    }
    
    // MARK: IMAGE CONTAINER QUERIES
    
    func getAllContainerPathsOfImages(rootPath: String?) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        
        final class TempRecord : DatabaseRecord {
            
            var containerpath:String = ""
            public init() {}
        }
        
        var records:[TempRecord] = []
        var sql = ""
        do {
            if let root = rootPath {
                sql = """
                select distinct "containerPath" from "Image" where ("repositoryPath" = $1 or "repositoryPath" = $2) order by "containerPath"
                """
                records = try TempRecord.fetchAll(db, sql: sql, values: [root.withLastStash(), root.removeLastStash()])
            }else{
                sql = """
                select distinct "containerPath" from "image" order by "containerPath"
                """
                records = try TempRecord.fetchAll(db, sql: sql)
            }
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.insert("\(row.containerpath)")
        }
        return result
    }
    
    func getAllContainerPathsOfImages(repositoryId: Int?) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        
        final class TempRecord : DatabaseRecord {
            
            var containerpath:String = ""
            public init() {}
        }
        
        var records:[TempRecord] = []
        do {
            var sql = ""
            if let repositoryId = repositoryId {
                sql = """
                select distinct "containerPath" from "Image" where "repositoryId"=\(repositoryId) order by "containerPath"
                """
                records = try TempRecord.fetchAll(db, sql: sql)
            }else{
                sql = """
                select distinct "containerPath" from "image" order by "containerPath"
                """
                records = try TempRecord.fetchAll(db, sql: sql)
            }
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.insert("\(row.containerpath)")
        }
        return result
    }
    
    func getAllContainerPaths(rootPath: String?) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        
        final class TempRecord : DatabaseRecord {
            
            var path:String = ""
            public init() {}
        }
        
        var records:[TempRecord] = []
        do {
            var sql = ""
            if let root = rootPath {
                sql = """
                select "path" from "ImageContainer" where "path" like $1 order by "path"
                """
                records = try TempRecord.fetchAll(db, sql: sql, values: ["\(root)%"])
            }else{
                sql = """
                select "path" from "ImageContainer" order by "path"
                """
                records = try TempRecord.fetchAll(db, sql: sql)
            }
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.insert("\(row.path)")
        }
        return result
    }
    
    func getAllContainerPaths(repositoryPath: String?) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        
        final class TempRecord : DatabaseRecord {
            
            var path:String = ""
            public init() {}
        }
        
        var records:[TempRecord] = []
        do {
            var sql = ""
            if let repoPath = repositoryPath {
                sql = """
                select "path" from "ImageContainer" where ("repositoryPath" = $1 or "repositoryPath" = $2) order by "path"
                """
                records = try TempRecord.fetchAll(db, sql: sql, values: [repoPath.withLastStash(), repoPath.removeLastStash()])
            }else{
                sql = """
                select "path" from "ImageContainer" order by "path"
                """
                records = try TempRecord.fetchAll(db, sql: sql)
            }
        }catch{
            self.logger.log(.error, error)
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
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "RepositoryDaoPostgresCK", name: "updateImageContainerWithRepositoryId", message: "\(error)")
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
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "RepositoryDaoPostgresCK", name: "updateImageContainerWithParentId", message: "\(error)")
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
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "RepositoryDaoPostgresCK", name: "updateImageContainerParentFolder", message: "\(error)")
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
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "RepositoryDaoPostgresCK", name: "updateImageContainerHideByParent", message: "\(error)")
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
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerPaths(containerId: Int, newPath: String, repositoryPath: String, parentFolder: String, subPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "path" = $1, "repositoryPath" = $2, "parentFolder" = $3, "subPath" = $4 where id = $5
                """, parameterValues: [newPath, repositoryPath.withLastStash(), parentFolder, subPath, containerId])
        }catch{
            self.logger.log(.error, error)
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
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerRepositoryPaths(containerId: Int, newPath: String, repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "path" = $1, "repositoryPath" = $2 where id = $3
                """, parameterValues: [newPath, repositoryPath.withLastStash(), containerId])
        }catch{
            self.logger.log(.error, error)
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
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerSubContainers(path:String) -> Int {
        let subContainers = self.countSubContainers(parent: path)
        self.logger.log(.trace, "[DB][PostgresClientKit+ImageContainer] updating subContainers amount to \(subContainers) - \(path)")
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "subContainers" = \(subContainers) where "path" = $1
                """, parameterValues: [path])
        }catch{
            self.logger.log(.error, error)
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
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func hideContainer(id: Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByContainer" = true where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "Image" set "hiddenByContainer" = true where "id" = $1
                """, parameterValues:[id])
        }catch{
            self.logger.log(.error, error)
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
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func showContainer(id: Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByContainer" = false where "id" = $1
                """, parameterValues: [id])
            try db.execute(sql: """
                update "Image" set "hiddenByContainer" = false where "id" = $1
                """, parameterValues:[id])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func getOwners() -> [String] {
        var result:[String] = []
        let sql = """
select distinct "owner" from "ImageRepository" order by "owner"
"""
        final class TempRecord : DatabaseRecord {
            var owner:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.owner)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    func getRepositoryIdsByOwner(owner:String) -> [Int] {
        var result:[Int] = []
        let sql = """
select "id" from "ImageRepository" where "owner"='\(owner)' order by "sequenceOrder" desc
"""
        final class TempRecord : DatabaseRecord {
            var id:Int = 0
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.id)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    func getRepositoryIdsByOwners(owners:[String]) -> [Int] {
        var result:[Int] = []
        let sql = """
select "id" from "ImageRepository" where "owner" in (\(owners.joinedSingleQuoted(separator: ","))) order by "name"
"""
        final class TempRecord : DatabaseRecord {
            var id:Int = 0
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.id)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    

}
