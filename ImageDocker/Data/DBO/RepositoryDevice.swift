//
//  RepositoryDevice.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/7.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
import GRDB
import PostgresModelFactory

public final class RepositoryDevice: Codable {
    var id: Int = 0      // <- the row id
    var repositoryId: Int = 0
    var deviceId: String = ""
    var startYear: Int = 0
    var startMonth: Int = 0
    var startDay: Int = 0
    
    public init() {
        
    }
}

extension RepositoryDevice: FetchableRecord, MutablePersistableRecord, TableRecord {

}


extension RepositoryDevice : PostgresRecord {
    public func postgresTable() -> String {
        "RepositoryDevice"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return ["id"]
    }
    
    
}
