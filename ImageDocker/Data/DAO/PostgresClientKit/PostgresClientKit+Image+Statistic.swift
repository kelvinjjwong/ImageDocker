//
//  PostgresClientKit+Image+Statistic.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class ImageCountDaoPostgresCK : ImageCountDaoInterface {
    
    
    let logger = LoggerFactory.get(category: "ImageCountDao", subCategory: "Postgres", includeTypes: [])
    
    func countCopiedFromDevice(deviceId:String) -> Int {
        let db = PostgresConnection.database()
        return ImageDeviceFile.count(db, where: """
        "deviceId"=$1
        """, parameters:[deviceId])
    }
    
    func countImagesShouldImport(deviceId:String) -> Int {
        let db = PostgresConnection.database()
//        let sql = """
//        "importToPath" in (
//        select '\(rawStoragePath)' || "toSubFolder" from "ImageDevicePath"  where "deviceId"='\(deviceId)' and "exclude"=false and "excludeImported"=false
//        )
//        """
        let sql = """
        select count(1) from "ImageDeviceFile" where "deviceId"='\(deviceId)'
                                          and "importToPath" || '/' || "importAsFilename" not in
        (
        select r."storageVolume" || r."storagePath" || '/' || i."subPath"
        from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r.id
        where r."deviceId"='\(deviceId)'
        )
        """
        self.logger.log("[countImagesShouldImport] \(sql)")
        return db.count(sql: sql)
    }
    
    func countImportedAsEditable(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "repositoryPath"=$1
        """, parameters:[repositoryPath])
        
    }
    
    func countImportedAsEditable(deviceId:String) -> Int {
        let sql = """
        select count(1) from "ImageDeviceFile" where "deviceId"='\(deviceId)'
                                          and "importToPath" || '/' || "importAsFilename" in
        (
        select r."storageVolume" || r."storagePath" || '/' || i."subPath"
        from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r.id
        where r."deviceId"='\(deviceId)'
        )
        """
        let db = PostgresConnection.database()
        self.logger.log("[countImportedAsEditable] \(sql)")
        return db.count(sql: sql)
    }
    
    func countExtractedExif(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "exifCreateDate" is not null and "repositoryPath"=$1
        """, parameters:[repositoryPath])
    }
    
    func countExtractedExif(repositoryId:Int) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "exifCreateDate" is not null and "repositoryId"=$1
        """, parameters:[repositoryId])
    }
    
    func countRecognizedLocation(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        ("address" is not null or "assignAddress" is not null) and "repositoryPath"=$1
        """, parameters:[repositoryPath])
    }
    
    func countRecognizedLocation(repositoryId:Int) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        ("address" is not null or "assignAddress" is not null) and "repositoryId"=$1
        """, parameters:[repositoryId])
    }
    
    func countRecognizedFaces(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "recognizedFace"=true and "repositoryPath"=$1
        """, parameters:[repositoryPath])
    }
    
    func countRecognizedFaces(repositoryId:Int) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "recognizedFace"=true and "repositoryId"=$1
        """, parameters:[repositoryId])
    }
    
    // count without event
    func countPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?) -> Int {
        let db = PostgresConnection.database()
        var filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .ShowAndHidden
        let (stmt, _, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: filter, year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place)
        
        return db.count(sql: "select count(1) from \"Image\" where \(stmt)", parameterValues: sqlArgs)
    }
    
    // count without event
    func countHiddenPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?) -> Int {
        let db = PostgresConnection.database()
        var filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .HiddenOnly
        let (_, stmtHidden, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: ViewController.collectionFilter, year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place)
        return db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
    }
    
    // count with event
    func countPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String) -> Int {
        let db = PostgresConnection.database()
        let filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .ShowAndHidden
        let (stmt, _, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: filter, year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place)
        return db.count(sql: "select count(1) from \"Image\" where \(stmt)", parameterValues: sqlArgs)
    }
    
    // count with event
    func countHiddenPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String) -> Int {
        let db = PostgresConnection.database()
        let filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .HiddenOnly
        let (_, stmtHidden, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: filter, year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place)
        return db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
    }
    
    func countImageWithoutFace(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        return Image.count(db, where: """
        "repositoryPath"=$1 and hidden=false and id not in (select distinct "imageId" from "ImageFace")
        """, parameters:[root])
    }
    
    func countImageNotYetFacialDetection(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        return Image.count(db, where: """
        "repositoryPath"=$1 and hidden=false and "scanedFace"<>true and id not in (select distinct "imageId" from "ImageFace")
        """, parameters:[root])
    }
    
    func countImageWithoutId(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "id is null and path like $1", parameters:[keyword])
    }
    
    func countPhotoFiles(rootPath: String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: "path like $1", parameters: ["\(rootPath)%"])
    }
    
    func countImageWithoutRepositoryPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        return Image.count(db, where: "\"repositoryPath\"='' and path like $1", parameters:[keyword])
    }
    
    func countImageWithoutSubPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "\"subPath\"='' and path like $1", parameters:[keyword])
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        return Image.count(db, where: "\"repositoryPath\" = $1 and path not like $2", parameters:[root, keyword])
    }
    
    func countImages(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "path like $1", parameters:[keyword])
    }
    
    func countHiddenImages(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "path like $1 and hidden = true", parameters:[keyword])
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "\"repositoryPath\" = '' and path like $1", parameters:[keyword])
    }
    
    func countContainersWithoutSubPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "\"subPath\" = '' and path like $1", parameters:[keyword])
    }
    

}
