//
//  ImageFamilyDao.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/17.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

public final class ImageFamilyDao {
    
    let logger = LoggerFactory.get(category: "ImageFamilyDao")
    
    private let impl:ImageFamilyDaoInterface
    
    init(_ impl:ImageFamilyDaoInterface) {
        self.impl = impl
    }
    
    static var `default`:ImageFamilyDao {
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return ImageFamilyDao(ImageFamilyDaoPostgresCK())
        }else{
            return ImageFamilyDao(ImageFamilyDaoPostgresCK())
        }
    }
    
    func getFamilies(imageId:String) -> [ImageFamily] {
        return self.impl.getFamilies(imageId: imageId)
    }
    
    func getFamilyIds(imageIds:[String]) -> [String] {
        return self.impl.getFamilyIds(imageIds: imageIds)
    }
    
}
