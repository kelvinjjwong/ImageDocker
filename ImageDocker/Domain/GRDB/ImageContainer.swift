//
//  ImageContainer.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImageContainer: Codable {
    //var id: Int64?      // <- the row id
    var name: String
    var parentFolder: String
    var path: String
    var imageCount: Int
    var repositoryPath: String
    var homePath: String
    var storagePath: String
    var facePath: String
    var cropPath: String
    var subPath: String
    var parentPath: String
    var hiddenByRepository: Bool
    var hiddenByContainer: Bool
    var deviceId: String
    var manyChildren: Bool
    var hideByParent: Bool
    var folderAsEvent: Bool
    var eventFolderLevel: Int
}

extension ImageContainer: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
