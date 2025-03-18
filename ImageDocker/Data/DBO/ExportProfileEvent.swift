//
//  ExportProfileEvent.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2025/1/1.
//  Copyright © 2025 nonamecat. All rights reserved.
//

import Foundation
import PostgresModelFactory

public final class ExportProfileEvent : Codable {
    var id: Int = 0      // <- the row id
    var profileId: String = ""
    var eventId: String = ""
    var eventName: String = ""
    var eventNodeType: String = ""
    var eventOwner: String = ""
    var exclude:Bool = true
    
    public init() {
        
    }
    
    
}


extension ExportProfileEvent : DatabaseRecord {
    public func postgresTable() -> String {
        return "ExportProfileEvent"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    
}
