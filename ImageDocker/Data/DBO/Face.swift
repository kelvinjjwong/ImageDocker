//
//  Face.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/28.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class Face : Codable {
    
    var imageId:String = ""
    var pos_top:Double = 0.0
    var pos_right:Double = 0.0
    var pos_bottom:Double = 0.0
    var pos_left:Double = 0.0
    var peopleIdRecognized:String = ""
    var peopleIdAssign:String = ""
    var peopleId:String = ""
    var peopleName:String = ""
    var shortName:String = ""
    var file:String = ""
    
    public init() {
        
    }
    
}

extension Face: FetchableRecord, MutablePersistableRecord, TableRecord {

}

extension Face : PostgresRecord {
    public func postgresTable() -> String {
        return "Face"
    }
    
    public func primaryKeys() -> [String] {
        return []
    }
    
    
}
