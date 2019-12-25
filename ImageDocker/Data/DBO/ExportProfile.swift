//
//  ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ExportProfile : Codable {
    var id: String
    var name: String
    var directory: String
    var repositoryPath: String
    var specifyPeople: Bool
    var specifyEvent: Bool
    var specifyRepository: Bool
    var people: String
    var events: String
    var duplicateStrategy: String
    var fileNaming:String
    var subFolder:String
    var patchImageDescription:Bool
    var patchDateTime:Bool
    var patchGeolocation:Bool
    var enabled: Bool
    var lastExportTime: Date?
}

extension ExportProfile: FetchableRecord, MutablePersistableRecord, TableRecord {
    
}

