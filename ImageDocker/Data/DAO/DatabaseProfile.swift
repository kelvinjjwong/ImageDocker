//
//  DatabaseProfile.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/22.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation

class DatabaseProfile {
    
    var name = ""
    var engine = ""
    var selected = false
    
    var host = ""
    var port:Int = 0
    var user = ""
    var database = ""
    var schema = ""
    var password = ""
    var nopsw = true
    var ssl = false
    
    public func toJSON() -> String {
        let json = JSON(self)
        let jsonString = json.rawString(.utf8, options: [.fragmentsAllowed, .withoutEscapingSlashes]) ?? "{}"
        return jsonString
    }
    
    public static func fromJSON(_ jsonString:String) -> DatabaseProfile {
        let json = JSON(parseJSON: jsonString)
        let profile = DatabaseProfile()
        profile.name = json["name"].stringValue
        profile.engine = json["engine"].stringValue
        profile.selected = json["selected"].boolValue
        
        profile.host = json["host"].stringValue
        profile.port = json["port"].intValue
        profile.user = json["user"].stringValue
        profile.database = json["database"].stringValue
        profile.schema = json["schema"].stringValue
        profile.password = json["password"].stringValue
        profile.nopsw = json["nopsw"].boolValue
        profile.ssl = json["ssl"].boolValue
        return profile
    }
}
