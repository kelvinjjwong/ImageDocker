//
//  ImageFamily.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/5.
//  Copyright © 2023 nonamecat. All rights reserved.
//


import Foundation
import PostgresModelFactory

public final class ImageFamily : Codable {
    var id: Int = 0      // <- the row id
    var imageId: String = ""
    var familyId: String = ""
    var ownerId: String = ""
    var familyName: String = ""
    var owner:String = ""
    
    public init() {
        
    }
}


extension ImageFamily : DatabaseRecord {
    public func postgresTable() -> String {
        return "ImageFamily"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return ["id"]
    }
    
    
}
