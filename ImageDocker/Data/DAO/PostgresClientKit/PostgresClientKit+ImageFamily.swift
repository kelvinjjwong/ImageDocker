//
//  PostgresClientKit+ImageFamily.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/17.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

class ImageFamilyDaoPostgresCK : ImageFamilyDaoInterface {
    
    let logger = LoggerFactory.get(category: "ImageFamilyDaoPostgresCK")
    
    func getFamilies(imageId:String) -> [ImageFamily] {
        let db = PostgresConnection.database()
        do {
            return try ImageFamily.fetchAll(db, parameters: ["imageId": imageId], orderBy: "\"owner\", \"familyName\"")
        }catch {
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getFamilyIds(imageIds:[String]) -> [String] {
        if imageIds.isEmpty {
            return []
        }
        let db = PostgresConnection.database()
        final class TempRecord : DatabaseRecord {
            var familyId: String = ""
        }
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: """
            SELECT DISTINCT "familyId" from "ImageFamily" where "imageId" in (\(imageIds.joinedSingleQuoted(separator: ",")))
            """)
        }catch{
            self.logger.log(.error, error)
        }
        return records.map { $0.familyId }
    }
    
}
