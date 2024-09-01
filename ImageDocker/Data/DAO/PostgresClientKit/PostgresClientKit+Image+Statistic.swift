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
        do {
            return try ImageDeviceFile.count(db, where: """
        "deviceId"=$1
        """, parameters:[deviceId])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
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
                                          and "localFilePath" not in
        (
        select i."subPath"
        from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r.id
        where r."deviceId"='\(deviceId)'
        )
        """
        self.logger.log("[countImagesShouldImport] \(sql)")
        do {
            return try db.count(sql: sql)
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImportedAsEditable(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        do {
            return try Image.count(db, where: """
        "repositoryPath"=$1
        """, parameters:[repositoryPath])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
        
    }
    
    func countImportedAsEditable(deviceId:String) -> Int {
        let sql = """
        select count(1) from "ImageDeviceFile" where "deviceId"='\(deviceId)'
                                          and "localFilePath" in
        (
        select i."subPath"
        from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r.id
        where r."deviceId"='\(deviceId)'
        )
        """
        let db = PostgresConnection.database()
        self.logger.log("[countImportedAsEditable] \(sql)")
        do {
            return try db.count(sql: sql)
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countExtractedExif(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        do {
            return try Image.count(db, where: """
            "exifCreateDate" is not null and "repositoryPath"=$1
            """, parameters:[repositoryPath])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countExtractedExif(repositoryId:Int) -> Int {
        let db = PostgresConnection.database()
        do {
            return try Image.count(db, where: """
            "repositoryId"=$1 and "photoTakenDate" is not null and "photoTakenYear" is not null and "photoTakenMonth" is not null and "photoTakenDay" is not null and "photoTakenYear" <> 0 and "photoTakenMonth" <> 0 and "photoTakenDay" <> 0
            """, parameters:[repositoryId])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countRecognizedLocation(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        do{
            return try Image.count(db, where: """
            "repositoryPath"=$1 and "longitude" is not null and "longitudeBD" is not null and "latitude" is not null and "latitudeBD" is not null and (("country" is not null and "city" is not null and "address" is not null) or ("assignAddress" is not null and "assignCountry" is not null and "assignCity" is not null))
            """, parameters:[repositoryPath])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countRecognizedLocation(repositoryId:Int) -> Int {
        let db = PostgresConnection.database()
        do {
            return try Image.count(db, where: """
            "repositoryId"=$1 and "longitude" is not null and "longitudeBD" is not null and "latitude" is not null and "latitudeBD" is not null and (("country" is not null and "city" is not null and "address" is not null) or ("assignAddress" is not null and "assignCountry" is not null and "assignCity" is not null))
            """, parameters:[repositoryId])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countRecognizedFaces(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        do {
            return try Image.count(db, where: """
            "recognizedFace"=true and "repositoryPath"=$1
            """, parameters:[repositoryPath])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countRecognizedFaces(repositoryId:Int) -> Int {
        let db = PostgresConnection.database()
        do {
            return try Image.count(db, where: """
        "recognizedFace"=true and "repositoryId"=$1
        """, parameters:[repositoryId])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    // count without event
    func countPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?) -> Int {
        let db = PostgresConnection.database()
        var filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .ShowAndHidden
        let (stmt, _, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: filter, year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place)
        
        do {
            return try db.count(sql: "select count(1) from \"Image\" where \(stmt)", parameterValues: sqlArgs)
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    // count without event
    func countHiddenPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?) -> Int {
        let db = PostgresConnection.database()
        var filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .HiddenOnly
        let (_, stmtHidden, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: ViewController.collectionFilter, year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place)
        do {
            return try db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    // count with event
    func countPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String) -> Int {
        let db = PostgresConnection.database()
        let filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .ShowAndHidden
        let (stmt, _, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: filter, year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place)
        do {
            return try db.count(sql: "select count(1) from \"Image\" where \(stmt)", parameterValues: sqlArgs)
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    // count with event
    func countHiddenPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String) -> Int {
        let db = PostgresConnection.database()
        let filter = ViewController.collectionFilter.clone()
        filter.includeHidden = .HiddenOnly
        let (_, stmtHidden, sqlArgs) = ImageSQLHelper.generatePostgresSQLStatementForPhotoFiles(filter: filter, year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place)
        do {
            return try db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImageWithoutFace(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        do {
            return try Image.count(db, where: """
            "repositoryPath"=$1 and hidden=false and id not in (select distinct "imageId" from "ImageFace")
            """, parameters:[root])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImageNotYetFacialDetection(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        do {
            return try Image.count(db, where: """
        "repositoryPath"=$1 and hidden=false and "scanedFace"<>true and id not in (select distinct "imageId" from "ImageFace")
        """, parameters:[root])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImageWithoutId(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "id is null and path like $1", parameters:[keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countPhotoFiles(rootPath: String) -> Int {
        let db = PostgresConnection.database()
        do {
            return try Image.count(db, where: "path like $1", parameters: ["\(rootPath)%"])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImageWithoutRepositoryPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "\"repositoryPath\"='' and path like $1", parameters:[keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImageWithoutSubPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "\"subPath\"='' and path like $1", parameters:[keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "\"repositoryPath\" = $1 and path not like $2", parameters:[root, keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countImages(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "path like $1", parameters:[keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countHiddenImages(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "path like $1 and hidden = true", parameters:[keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "\"repositoryPath\" = '' and path like $1", parameters:[keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    
    func countContainersWithoutSubPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withLastStash()
        let keyword = "\(root)%"
        do {
            return try Image.count(db, where: "\"subPath\" = '' and path like $1", parameters:[keyword])
        }catch{
            self.logger.log(.error, error)
            return -1
        }
    }
    

}
