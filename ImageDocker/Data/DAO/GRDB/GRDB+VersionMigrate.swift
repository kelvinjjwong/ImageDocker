//
//  ModelStore+VersionMigrate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension SQLiteConnectionGRDB {
    // MARK: - SCHEMA VERSION MIGRATION
    
    func versionCheck(dropBeforeCreate: Bool, location: ImageDBLocation) {
        self.versionCheck()
    }
    
    func versionCheck(dropBeforeCreate: Bool) {
        self.versionCheck()
    }
    
    func versionCheck(){
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1") { db in
            try db.create(table: "ImageEvent", body: { t in
                t.column("name", .text).primaryKey().unique().notNull()
                t.column("startDate", .datetime)
                t.column("startYear", .integer)
                t.column("startMonth", .integer)
                t.column("startDay", .integer)
                t.column("endDate", .datetime)
                t.column("endYear", .integer)
                t.column("endMonth", .integer)
                t.column("endDay", .integer)
            })
            
            try db.create(table: "ImagePlace", body: { t in
                t.column("name", .text).primaryKey().unique().notNull()
                t.column("latitude", .text)
                t.column("latitudeBD", .text)
                t.column("longitude", .text)
                t.column("longitudeBD", .text)
                t.column("country", .text).indexed()
                t.column("province", .text).indexed()
                t.column("city", .text).indexed()
                t.column("district", .text)
                t.column("businessCircle", .text)
                t.column("street", .text)
                t.column("address", .text)
                t.column("addressDescription", .text)
            })
            
            try db.create(table: "ImageContainer", body: { t in
                t.column("path", .text).primaryKey().unique().notNull()
                t.column("name", .text).indexed()
                t.column("parentFolder", .text).indexed()
                t.column("imageCount", .integer)
            })
            
            try db.create(table: "Image", body: { t in
                t.column("audioBits", .integer)
                t.column("audioChannels", .integer)
                t.column("audioRate", .integer)
                t.column("hidden", .boolean).defaults(to: false).indexed()
                t.column("imageHeight", .integer)
                t.column("imageWidth", .integer)
                t.column("photoTakenDay", .integer).defaults(to: 0).indexed()
                t.column("photoTakenMonth", .integer).defaults(to: 0).indexed()
                t.column("photoTakenYear", .integer).defaults(to: 0).indexed()
                t.column("photoTakenHour", .integer).defaults(to: 0).indexed()
                t.column("rotation", .integer)
                t.column("addDate", .datetime)
                t.column("assignDateTime", .datetime)
                t.column("exifCreateDate", .datetime)
                t.column("exifDateTimeOriginal", .datetime)
                t.column("exifModifyDate", .datetime)
                t.column("exportTime", .datetime)
                t.column("filenameDate", .datetime)
                t.column("filesysCreateDate", .datetime)
                t.column("photoTakenDate", .datetime).indexed()
                t.column("softwareModifiedTime", .datetime)
                t.column("trackCreateDate", .datetime)
                t.column("trackModifyDate", .datetime)
                t.column("updateDateTimeDate", .datetime).indexed()
                t.column("updateEventDate", .datetime).indexed()
                t.column("updateExifDate", .datetime).indexed()
                t.column("updateLocationDate", .datetime).indexed()
                t.column("updatePhotoTakenDate", .datetime).indexed()
                t.column("videoCreateDate", .datetime)
                t.column("videoFrameRate", .double)
                t.column("videoModifyDate", .datetime)
                t.column("address", .text)
                t.column("addressDescription", .text)
                t.column("aperture", .text)
                t.column("assignAddress", .text)
                t.column("assignAddressDescription", .text)
                t.column("assignBusinessCircle", .text)
                t.column("assignCity", .text)
                t.column("assignCountry", .text)
                t.column("assignDistrict", .text)
                t.column("assignLatitude", .text)
                t.column("assignLatitudeBD", .text)
                t.column("assignLongitude", .text)
                t.column("assignLongitudeBD", .text)
                t.column("assignPlace", .text).indexed()
                t.column("assignProvince", .text)
                t.column("assignStreet", .text)
                t.column("businessCircle", .text)
                t.column("cameraMaker", .text).indexed()
                t.column("cameraModel", .text).indexed()
                t.column("city", .text).indexed()
                t.column("containerPath", .text).indexed()
                t.column("country", .text).indexed()
                t.column("datetimeFromFilename", .text)
                t.column("district", .text)
                t.column("event", .text).indexed()
                t.column("exportAsFilename", .text)
                t.column("exportToPath", .text)
                t.column("exposureTime", .text)
                t.column("fileSize", .text)
                t.column("filename", .text).indexed()
                t.column("gpsDate", .text)
                t.column("hideForSourceFilename", .text).indexed()
                t.column("imageSource", .text).indexed()
                t.column("iso", .text)
                t.column("latitude", .text)
                t.column("latitudeBD", .text)
                t.column("longitude", .text)
                t.column("longitudeBD", .text)
                t.column("path", .text).primaryKey().unique().notNull()
                t.column("photoDescription", .text)
                t.column("place", .text).indexed()
                t.column("province", .text).indexed()
                t.column("softwareName", .text).indexed()
                t.column("street", .text)
                t.column("suggestPlace", .text)
                t.column("videoBitRate", .text)
                t.column("videoDuration", .text)
                t.column("videoFormat", .text)
            })
        }
        
        migrator.registerMigration("v2") { db in
            try db.create(table: "ImageDevice", body: { t in
                t.column("deviceId", .text).primaryKey().unique().notNull()
                t.column("type", .text)
                t.column("manufacture", .text)
                t.column("model", .text)
                t.column("name", .text)
                t.column("storagePath", .text)
            })
            
            try db.create(table: "ImageDeviceFile", body: { t in
                t.column("fileId", .text).primaryKey().unique().notNull() // deviceId:/path/filename.jpg
                t.column("deviceId", .text)
                t.column("filename", .text)
                t.column("path", .text)
                t.column("fileDateTime", .text)
                t.column("fileSize", .text)
                t.column("fileMD5", .text)
                t.column("importDate", .text)
                t.column("importToPath", .text)
                t.column("importAsFilename", .text)
            })
        }
        
        migrator.registerMigration("v3") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "shortDescription", .text)
                t.add(column: "longDescription", .text)
                t.add(column: "originalMD5", .text)
                t.add(column: "exportedMD5", .text)
                t.add(column: "exportedLongDescription", .text)
                t.add(column: "exportState", .text)
                t.add(column: "exportFailMessage", .text)
            })
            
            try db.alter(table: "ImageDevice", body: { t in
                t.add(column: "marketName", .text)
            })
        }
        
        migrator.registerMigration("v4") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "delFlag", .boolean)
            })
        }
        
        migrator.registerMigration("v5") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "duplicatesKey", .text)
            })
        }
        
        migrator.registerMigration("v6") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "repositoryPath", .text).notNull().defaults(to: "")
            })
            
            try db.alter(table: "ImageDevice", body: { t in
                t.add(column: "repositoryPath", .text)
            })
            try db.alter(table: "Image", body: { t in
                t.add(column: "originPath", .text)
                t.add(column: "facesPath", .text)
                t.add(column: "id", .text)
            })
            
            try db.create(table: "People", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("name", .text).notNull().indexed()
                t.column("shortName", .text).indexed()
            })
            try db.create(table: "PeopleRelationship", body: { t in
                t.column("subject", .text).notNull().indexed()
                t.column("object", .text).notNull().indexed()
                t.column("callName", .text).notNull()
            })
            try db.create(table: "Family", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("name", .text).notNull().indexed()
                t.column("category", .text).indexed()
            })
            try db.create(table: "FamilyMember", body: { t in
                t.column("familyId", .text).notNull().indexed()
                t.column("peopleId", .text).notNull().indexed()
            })
            try db.create(table: "FamilyJoint", body: { t in
                t.column("bigFamilyId", .text).notNull().indexed()
                t.column("smallFamilyId", .text).notNull().indexed()
            })
            try db.create(table: "ImagePeople", body: { t in
                t.column("imageId", .text).notNull().indexed()
                t.column("peopleId", .text).notNull().indexed()
                t.column("position", .text)
            })
        }
        
        migrator.registerMigration("v7") { db in
            try db.alter(table: "ImageDeviceFile", body: { t in
                t.add(column: "localFilePath", .text)
            })
        }
        
        migrator.registerMigration("v8") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "homePath", .text).notNull().defaults(to: "")
                t.add(column: "storagePath", .text).notNull().defaults(to: "")
                t.add(column: "facePath", .text).notNull().defaults(to: "")
                t.add(column: "cropPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v9") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "subPath", .text).notNull().defaults(to: "")
            })
            try db.alter(table: "Image", body: { t in
                t.add(column: "subPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v10") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "parentPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v11") { db in
            try db.alter(table: "ImageDevice", body: { t in
                t.add(column: "homePath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v12") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "hiddenByRepository", .boolean).defaults(to: false).indexed()
                t.add(column: "hiddenByContainer", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v13") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "repositoryPath", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.registerMigration("v14") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "hiddenByRepository", .boolean).defaults(to: false).indexed()
                t.add(column: "hiddenByContainer", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v15") { db in
            try db.create(table: "ImageDevicePath", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("deviceId", .text).notNull().indexed()
                t.column("path", .text).notNull().indexed()
                t.column("toSubFolder", .text).notNull()
                t.column("exclude", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v16") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "deviceId", .text).defaults(to: "")
            })
        }
        
        migrator.registerMigration("v17") { db in
            try db.create(table: "ImageFace", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("imageId", .text).notNull().indexed()
                t.column("imageDate", .datetime)
                t.column("imageYear", .integer).defaults(to: 0)
                t.column("imageMonth", .integer).defaults(to: 0)
                t.column("imageDay", .integer).defaults(to: 0)
                t.column("repositoryPath", .text).notNull().indexed()
                t.column("cropPath", .text).notNull()
                t.column("subPath", .text).notNull()
                t.column("filename", .text).notNull()
                t.column("peopleId", .text)
                t.column("peopleAge", .integer).defaults(to: 0).indexed()
                t.column("recognizeBy", .text)
                t.column("recognizeVersion", .text)
                t.column("recognizeDate", .datetime)
                t.column("sampleChoice", .boolean).defaults(to: false).indexed()
                t.column("faceX", .text).defaults(to: "")
                t.column("faceY", .text).defaults(to: "")
                t.column("faceWidth", .text).defaults(to: "")
                t.column("faceHeight", .text).defaults(to: "")
                t.column("frameX", .text).defaults(to: "")
                t.column("frameY", .text).defaults(to: "")
                t.column("frameWidth", .text).defaults(to: "")
                t.column("frameHeight", .text).defaults(to: "")
                t.column("iconChoice", .boolean).defaults(to: false).indexed()
                t.column("tagOnly", .boolean).defaults(to: false).indexed()
                t.column("remark", .text).defaults(to: "")
            })
            
            
            try db.alter(table: "People", body: { t in
                t.add(column: "iconRepositoryPath", .text).notNull().defaults(to: "")
                t.add(column: "iconCropPath", .text).notNull().defaults(to: "")
                t.add(column: "iconSubPath", .text).notNull().defaults(to: "")
                t.add(column: "iconFilename", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v18") { db in
            try db.alter(table: "ImageFace", body: { t in
                t.add(column: "sampleChangeDate", .date)
            })
        }
        
        migrator.registerMigration("v19") { db in
            try db.alter(table: "ImageFace", body: { t in
                t.add(column: "locked", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v20") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "scanedFace", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v21") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "manyChildren", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v22") { db in
            try db.alter(table: "ImageDevicePath", body: { t in
                t.add(column: "manyChildren", .boolean).defaults(to: false).indexed()
            })
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "hideByParent", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v23") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "recognizedFace", .boolean).defaults(to: false).indexed()
                t.add(column: "facesCount", .integer).defaults(to: 0)
            })
        }
        
        migrator.registerMigration("v24") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "recognizedPeopleIds", .text).defaults(to: "")
            })
        }
        
        migrator.registerMigration("v25") { db in
            try db.alter(table: "ImageDevicePath", body: { t in
                t.add(column: "excludeImported", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v26") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "lastTimeExtractExif", .integer).defaults(to: 0)
                t.add(column: "noneExif", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v27") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "useFirstFolderAsEvent", .boolean).defaults(to: false)
            })
            
            try db.create(table: "ExportProfile", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("name", .text).notNull().indexed()
                t.column("directory", .text).notNull()
                t.column("duplicateStrategy", .text).notNull()
                t.column("specifyPeople", .boolean).defaults(to: false)
                t.column("specifyEvent", .boolean).defaults(to: false)
                t.column("specifyRepository", .boolean).defaults(to: false)
                t.column("people", .text).defaults(to: "")
                t.column("events", .text).defaults(to: "")
                t.column("repositoryPath", .text).defaults(to: "").indexed()
                t.column("enabled", .boolean).defaults(to: true).indexed()
                t.column("lastExportTime", .datetime)
            })
        }
        
        migrator.registerMigration("v28") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add(column: "patchImageDescription", .boolean).defaults(to: false)
            })
            
            try db.create(table: "ExportLog", body: { t in
                t.column("imageId", .text).notNull().indexed()
                t.column("profileId", .text).notNull().indexed()
                t.column("lastExportTime", .datetime)
            })
        }
        
        migrator.registerMigration("v29") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add(column: "patchDateTime", .boolean).defaults(to: false)
                t.add(column: "patchGeolocation", .boolean).defaults(to: false)
                t.add(column: "fileNaming", .text).defaults(to: "")
                t.add(column: "subFolder", .text).defaults(to: "")
            })
            
            try db.alter(table: "ExportLog", body: { t in
                t.add(column: "repositoryPath", .text).defaults(to: "").indexed()
                t.add(column: "subfolder", .text).defaults(to: "")
                t.add(column: "filename", .text).defaults(to: "")
            })
        }
        
        migrator.registerMigration("v30") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "folderAsEvent", .boolean).defaults(to: false)
                t.add(column: "eventFolderLevel", .integer).defaults(to: 2)
            })
        }
        
        migrator.registerMigration("v31") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "folderAsBrief", .boolean).defaults(to: false)
                t.add(column: "briefFolderLevel", .integer).defaults(to: -1)
            })
        }
        
        migrator.registerMigration("v32") { db in
            try db.alter(table: "ImageEvent", body: { t in
                t.add(column: "category", .text).defaults(to: "")
            })
        }
        
        migrator.registerMigration("v33") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add(column: "specifyFamily", .boolean).defaults(to: false)
                t.add(column: "family", .text).defaults(to: "")
            })
        }
        
        
        do {
            let dbQueue = try DatabaseQueue(path: SQLiteDataSource.default.getDataSource())
            try migrator.migrate(dbQueue)
        }catch{
            print(error)
        }
    }
}
