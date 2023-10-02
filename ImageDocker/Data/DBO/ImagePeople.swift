//
//  ImagePeople.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class ImagePeople : Codable {
    //var id: Int64?      // <- the row id
    var imageId: String = ""
    var peopleId: String = ""
    var position: String?
    
    public init() {
        
    }
}

//extension ImagePeople: FetchableRecord, MutablePersistableRecord, TableRecord {
//
//}


extension ImagePeople : PostgresRecord {
    public func postgresTable() -> String {
        return "ImagePeople"
    }
    
    public func primaryKeys() -> [String] {
        return ["imageId", "peopleId"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
