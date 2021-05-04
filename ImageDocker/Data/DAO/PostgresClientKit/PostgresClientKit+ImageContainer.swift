//
//  PostgresClientKit+ImageContainer.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class RepositoryDaoPostgresCK : RepositoryDaoInterface {
    
    func getOrCreateContainer(name: String, path: String, parentPath parentFolder: String, repositoryPath: String, homePath: String, storagePath: String, facePath: String, cropPath: String, subPath: String, manyChildren: Bool, hideByParent: Bool) -> ImageContainer {
        
        let db = PostgresConnection.database()
        if let container = ImageContainer.fetchOne(db, parameters: ["path": path]) {
            return container
        }else{
            let container = ImageContainer(name: name,
                                       parentFolder: parentFolder,
                                       path: path,
                                       imageCount: 0,
                                       repositoryPath: repositoryPath.withStash(),
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
            container.save(db)
            return container
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
                DELETE FROM "ImageContainer" WHERE "path" LIKE '\(path.withStash())%'
                """)
            // delete images
            if deleteImage {
                try db.execute(sql: """
                    DELETE FROM "Image" WHERE "path" LIKE '\(path.withStash())%'
                    """)
            }
            return .OK
        }catch{
            print(error)
            return .ERROR
        }
    }
    
    func deleteRepository(repositoryRoot: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            // delete container-self
            try db.execute(sql: """
                delete from "ImageContainer" where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withStash())"])
            // delete sub-containers
            try db.execute(sql: """
                delete from "Image" where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withStash())"])
            return .OK
        }catch{
            print(error)
            return .ERROR
        }
    }
    
    func getContainer(path: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        return ImageContainer.fetchOne(db, parameters: ["path" : path])
    }
    
    func getRepository(repositoryPath: String) -> ImageContainer? {
        let db = PostgresConnection.database()
        return ImageContainer.fetchOne(db, where: "(\"repositoryPath\" = $1 or \"repositoryPath\" = $2) and \"parentFolder\"=''", values: [repositoryPath.withoutStash(), repositoryPath.withStash()])
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
//        print(sql)
        
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
    
    func getSubContainers(parent path: String, condition:SearchCondition?) -> [ImageContainer] {
        let db = PostgresConnection.database()
        var result:[ImageContainer] = []
        let containers = ImageContainer.fetchAll(db, parameters: ["parentFolder" : path], orderBy: "\"path\"")
        if let imagesCondition = condition, !imagesCondition.isEmpty() {
            let containersConformCondition = self.getSubContainerPaths(parent: path, imagesCondition: imagesCondition)
            if containersConformCondition.count > 0 {
                for container in containers {
                    for conform in containersConformCondition {
                        if conform == container.path || conform.hasPrefix(container.path.withStash()) {
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
        where path like '\(parent.replacingOccurrences(of: "'", with: "''").withStash())%' \(additionalConditions)
        order by "containerPath" DESC
        """
//        print(sql)
        
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
    
    func getAllContainers() -> [ImageContainer] {
        let db = PostgresConnection.database()
        return ImageContainer.fetchAll(db, orderBy: "\"path\"")
    }
    
    func getContainers(rootPath: String) -> [ImageContainer] {
        let db = PostgresConnection.database()
        return ImageContainer.fetchAll(db, where: "\"path\" like $1", values: ["\(rootPath.withStash())%"])
    }
    
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
            records = TempRecord.fetchAll(db, sql: sql, values: [root.withStash(), root.withoutStash()])
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
            records = TempRecord.fetchAll(db, sql: sql, values: [repoPath.withStash(), repoPath.withoutStash()])
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
    
    func saveImageContainer(container: ImageContainer) -> ExecuteState {
        let db = PostgresConnection.database()
        container.save(db)
        return .OK
    }
    
    func updateImageContainerParentFolder(path: String, parentFolder: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "parentFolder" = $1 where "path" = $2
                """, parameterValues: [path, parentFolder])
        }catch{
            print(error)
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
            print(error)
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
                """, parameterValues: [newPath, repositoryPath.withStash(), parentFolder, subPath, oldPath])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageContainerRepositoryPaths(oldPath: String, newPath: String, repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "path" = $1, "repositoryPath" = $2 where "path" = $3
                """, parameterValues: [newPath, repositoryPath.withStash(), oldPath])
        }catch{
            print(error)
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
                """, parameterValues: ["\(path.withStash())%"])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func hideContainer(path: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByContainer" = true where "path" = $1
                """, parameterValues: [path])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByContainer" = true where "path" like $1
                """, parameterValues: ["\(path.withStash())%"])
            try db.execute(sql: """
                update "Image" set "hiddenByContainer" = true where "path" like $1
                """, parameterValues:["\(path.withStash())%"])
        }catch{
            print(error)
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
                """, parameterValues:["\(path.withStash())%"])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func hideRepository(repositoryRoot: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = true where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withStash())%"])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = true where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withStash())"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = true where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withStash())%"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = true where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withStash())"])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func showRepository(repositoryRoot: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = false where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withStash())%"])
            try db.execute(sql: """
                update "ImageContainer" set "hiddenByRepository" = false where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withStash())"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = false where "path" like $1
                """, parameterValues: ["\(repositoryRoot.withStash())%"])
            try db.execute(sql: """
                update "Image" set "hiddenByRepository" = false where "repositoryPath" = $1
                """, parameterValues: ["\(repositoryRoot.withStash())"])
        }catch{
            print(error)
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
        order by "name"
        """
        var results:[String:String] = [:]
        let records = TempRecord.fetchAll(db, sql:sql)
        for row in records {
            results[row.name] = row.lastPhotoTakenDate
        }
        return results
    }
    

}
