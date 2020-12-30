//
//  PostgresClientKit+Image+Statistic.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class ImageCountDaoPostgresCK : ImageCountDaoInterface {
    
    func countCopiedFromDevice(deviceId:String) -> Int {
        let db = PostgresConnection.database()
        return ImageDeviceFile.count(db, where: """
        "deviceId"=$1
        """, parameters:[deviceId])
    }
    
    func countImagesShouldImport(rawStoragePath:String, deviceId:String) -> Int {
        let db = PostgresConnection.database()
        return ImageDeviceFile.count(db, where: """
        "importToPath" in (
        select '\(rawStoragePath)' || "toSubFolder" from "ImageDevicePath"  where "deviceId"='\(deviceId)' and "exclude"=false and "excludeImported"=false
        )
        """)
    }
    
    func countImportedAsEditable(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "repositoryPath"=$1
        """, parameters:[repositoryPath])
        
    }
    
    func countExtractedExif(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "exifCreateDate" is not null and "repositoryPath"=$1
        """, parameters:[repositoryPath])
    }
    
    func countRecognizedLocation(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        ("address" is not null or "assignAddress" is not null) and "repositoryPath"=$1
        """, parameters:[repositoryPath])
    }
    
    func countRecognizedFaces(repositoryPath:String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: """
        "recognizedFace"=true and "repositoryPath"=$1
        """, parameters:[repositoryPath])
    }
    
    func countPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?) -> Int {
        let db = PostgresConnection.database()
        let (stmt, _, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        return db.count(sql: "select count(1) from \"Image\" where \(stmt)", parameterValues: sqlArgs)
    }
    
    func countHiddenPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?) -> Int {
        let db = PostgresConnection.database()
        let (_, stmtHidden, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        return db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
    }
    
    func countPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?) -> Int {
        let db = PostgresConnection.database()
        let (stmt, _, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        return db.count(sql: "select count(1) from \"Image\" where \(stmt)", parameterValues: sqlArgs)
    }
    
    func countHiddenPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?) -> Int {
        let db = PostgresConnection.database()
        let (_, stmtHidden, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        return db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
    }
    
    func countImageWithoutFace(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withStash()
        return Image.count(db, where: """
        "repositoryPath"=$1 and hidden=false and id not in (select distinct "imageId" from "ImageFace")
        """, parameters:[root])
    }
    
    func countImageNotYetFacialDetection(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withStash()
        return Image.count(db, where: """
        "repositoryPath"=$1 and hidden=false and "scanedFace"<>true and id not in (select distinct "imageId" from "ImageFace")
        """, parameters:[root])
    }
    
    func countImageWithoutId(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "id is null and path like $1", parameters:[keyword])
    }
    
    func countPhotoFiles(rootPath: String) -> Int {
        let db = PostgresConnection.database()
        return Image.count(db, where: "path like $1", parameters: ["\(rootPath)%"])
    }
    
    func countImageWithoutRepositoryPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        return Image.count(db, where: "\"repositoryPath\"='' and path like $1", parameters:[keyword])
    }
    
    func countImageWithoutSubPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "\"subPath\"='' and path like $1", parameters:[keyword])
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        return Image.count(db, where: "\"repositoryPath\" = $1 and path not like $2", parameters:[root, keyword])
    }
    
    func countImages(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "path like $1", parameters:[keyword])
    }
    
    func countHiddenImages(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "path like $1 and hidden = true", parameters:[keyword])
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "\"repositoryPath\" = '' and path like $1", parameters:[keyword])
    }
    
    func countContainersWithoutSubPath(repositoryRoot: String) -> Int {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withStash()
        let keyword = "\(root)%"
        
        return Image.count(db, where: "\"subPath\" = '' and path like $1", parameters:[keyword])
    }
    

}
