//
//  PostgresClientKit+ImageFamily.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/17.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class ImageFamilyDaoPostgresCK : ImageFamilyDaoInterface {
    
    let logger = LoggerFactory.get(category: "ImageFamilyDaoPostgresCK")
    
    func getFamilies(imageId:String) -> [ImageFamily] {
        let db = PostgresConnection.database()
        return ImageFamily.fetchAll(db, parameters: ["imageId": imageId], orderBy: "\"owner\", \"familyName\"")
    }
    
}
