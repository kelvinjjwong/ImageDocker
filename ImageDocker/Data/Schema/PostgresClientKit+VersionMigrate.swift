//
//  PostgresClientKit+VersionMigrate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresModelFactory

extension PostgresConnection {
    
    func versionCheck() {
        self.versionCheck(dropBeforeCreate: false)
    }
    
    func versionCheck(dropBeforeCreate:Bool) {
        self.versionCheck(dropBeforeCreate: dropBeforeCreate, db: PostgresConnection.database())
    }
    
//    func versionCheck(dropBeforeCreate:Bool, location:ImageDBLocation) {
//        self.versionCheck(dropBeforeCreate: dropBeforeCreate, db: PostgresConnection.database())
//    }
    
    func versionCheck(dropBeforeCreate:Bool, db:PostgresDB) {
        let migrator = DatabaseVersionMigrator(db).dropBeforeCreate(dropBeforeCreate).cleanVersions(false)
        
        migrator.version("v1") { db in
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
                t.column("dateTimeFromFilename", .text)
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
        
        migrator.version("v2") { db in
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
        
        migrator.version("v3") { db in
            try db.alter(table: "Image", body: { t in
                t.add("shortDescription", .text)
                t.add("longDescription", .text)
                t.add("originalMD5", .text)
                t.add("exportedMD5", .text)
                t.add("exportedLongDescription", .text)
                t.add("exportState", .text)
                t.add("exportFailMessage", .text)
            })
            
            try db.alter(table: "ImageDevice", body: { t in
                t.add("marketName", .text)
            })
        }
        
        migrator.version("v4") { db in
            try db.alter(table: "Image", body: { t in
                t.add("delFlag", .boolean)
            })
        }
        
        migrator.version("v5") { db in
            try db.alter(table: "Image", body: { t in
                t.add("duplicatesKey", .text)
            })
        }
        
        migrator.version("v6") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("repositoryPath", .text).notNull().defaults(to: "")
            })
            
            try db.alter(table: "ImageDevice", body: { t in
                t.add("repositoryPath", .text)
            })
            try db.alter(table: "Image", body: { t in
                t.add("originPath", .text)
                t.add("facesPath", .text)
                t.add("id", .text)
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
        
        migrator.version("v7") { db in
            try db.alter(table: "ImageDeviceFile", body: { t in
                t.add("localFilePath", .text)
            })
        }
        
        migrator.version("v8") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("homePath", .text).notNull().defaults(to: "")
                t.add("storagePath", .text).notNull().defaults(to: "")
                t.add("facePath", .text).notNull().defaults(to: "")
                t.add("cropPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.version("v9") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("subPath", .text).notNull().defaults(to: "")
            })
            try db.alter(table: "Image", body: { t in
                t.add("subPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.version("v10") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("parentPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.version("v11") { db in
            try db.alter(table: "ImageDevice", body: { t in
                t.add("homePath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.version("v12") { db in
            try db.alter(table: "Image", body: { t in
                t.add("hiddenByRepository", .boolean).defaults(to: false).indexed()
                t.add("hiddenByContainer", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v13") { db in
            try db.alter(table: "Image", body: { t in
                t.add("repositoryPath", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.version("v14") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("hiddenByRepository", .boolean).defaults(to: false).indexed()
                t.add("hiddenByContainer", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v15") { db in
            try db.create(table: "ImageDevicePath", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("deviceId", .text).notNull().indexed()
                t.column("path", .text).notNull().indexed()
                t.column("toSubFolder", .text).notNull()
                t.column("exclude", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v16") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("deviceId", .text).defaults(to: "")
            })
        }
        
        migrator.version("v17") { db in
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
                t.add("iconRepositoryPath", .text).notNull().defaults(to: "")
                t.add("iconCropPath", .text).notNull().defaults(to: "")
                t.add("iconSubPath", .text).notNull().defaults(to: "")
                t.add("iconFilename", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.version("v18") { db in
            try db.alter(table: "ImageFace", body: { t in
                t.add("sampleChangeDate", .date)
            })
        }
        
        migrator.version("v19") { db in
            try db.alter(table: "ImageFace", body: { t in
                t.add("locked", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v20") { db in
            try db.alter(table: "Image", body: { t in
                t.add("scanedFace", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v21") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("manyChildren", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v22") { db in
            try db.alter(table: "ImageDevicePath", body: { t in
                t.add("manyChildren", .boolean).defaults(to: false).indexed()
            })
            try db.alter(table: "ImageContainer", body: { t in
                t.add("hideByParent", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v23") { db in
            try db.alter(table: "Image", body: { t in
                t.add("recognizedFace", .boolean).defaults(to: false).indexed()
                t.add("facesCount", .integer).defaults(to: 0)
            })
        }
        
        migrator.version("v24") { db in
            try db.alter(table: "Image", body: { t in
                t.add("recognizedPeopleIds", .text).defaults(to: "")
            })
        }
        
        migrator.version("v25") { db in
            try db.alter(table: "ImageDevicePath", body: { t in
                t.add("excludeImported", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v26") { db in
            try db.alter(table: "Image", body: { t in
                t.add("lastTimeExtractExif", .integer).defaults(to: 0)
                t.add("noneExif", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v27") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("useFirstFolderAsEvent", .boolean).defaults(to: false)
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
        
        migrator.version("v28") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add("patchImageDescription", .boolean).defaults(to: false)
            })
            
            try db.create(table: "ExportLog", body: { t in
                t.column("imageId", .text).notNull().indexed()
                t.column("profileId", .text).notNull().indexed()
                t.column("lastExportTime", .datetime)
            })
        }
        
        migrator.version("v29") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add("patchDateTime", .boolean).defaults(to: false)
                t.add("patchGeolocation", .boolean).defaults(to: false)
                t.add("fileNaming", .text).defaults(to: "")
                t.add("subFolder", .text).defaults(to: "")
            })
            
            try db.alter(table: "ExportLog", body: { t in
                t.add("repositoryPath", .text).defaults(to: "").indexed()
                t.add("subfolder", .text).defaults(to: "")
                t.add("filename", .text).defaults(to: "")
            })
        }
        
        migrator.version("v30") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("folderAsEvent", .boolean).defaults(to: false)
                t.add("eventFolderLevel", .integer).defaults(to: 2)
            })
        }
        
        migrator.version("v31") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("folderAsBrief", .boolean).defaults(to: false)
                t.add("briefFolderLevel", .integer).defaults(to: -1)
            })
        }
        
        migrator.version("v32") { db in
            try db.alter(table: "ImageEvent", body: { t in
                t.add("category", .text).defaults(to: "")
            })
        }
        
        migrator.version("v33") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add("specifyFamily", .boolean).defaults(to: false)
                t.add("family", .text).defaults(to: "")
            })
        }
        
        migrator.version("v34") { db in
            try db.alter(table: "ExportLog", body: { t in
                t.add("exportedMd5", .text).defaults(to: "")
                t.add("state", .boolean).defaults(to: false)
                t.add("failMessage", .text).defaults(to: "")
            })
        }
        
        migrator.version("v35") { db in
            try db.alter(table: "ExportLog", body: { t in
                t.add("shouldDelete", .boolean).defaults(to: false)
            })
        }
        
        migrator.version("v36") { db in
            try db.create(table: "PeopleEvent", body: { t in
                t.column("peopleId", .text).notNull().indexed()
                t.column("event", .text).notNull().indexed()
            })
        }
        
        migrator.version("v37") { db in
            try db.alter(table: "ImageEvent", body: { t in
                t.add("owner", .text).defaults(to: "")
                t.add("ownerAge", .text).defaults(to: "")
                t.add("attenders", .text).defaults(to: "")
                t.add("family", .text).defaults(to: "")
                t.add("activity1", .text).defaults(to: "")
                t.add("activity2", .text).defaults(to: "")
                t.add("imageCount", .integer).defaults(to: 0)
                t.add("note", .text).defaults(to: "")
                t.add("lastUpdateTime", .datetime)
            })
        }
        
        migrator.version("v38") { db in
            try db.alter(table: "ImageEvent", body: { t in
                t.add("ownerNickname", .text).defaults(to: "")
                t.add("ownerId", .text).defaults(to: "")
            })
        }
        
        migrator.version("v39") { db in
            try db.alter(table: "ImageEvent", body: { t in
                t.add("owner2", .text).defaults(to: "")
                t.add("owner2Nickname", .text).defaults(to: "")
                t.add("owner2Id", .text).defaults(to: "")
                t.add("owner3", .text).defaults(to: "")
                t.add("owner3Nickname", .text).defaults(to: "")
                t.add("owner3Id", .text).defaults(to: "")
            })
        }
        
        migrator.version("v40") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("subContainers", .integer).defaults(to: 0)
            })
        }
        
        migrator.version("v41") { db in
            try db.alter(table: "Image", body: { t in
                t.add("resizedFilePath", .text).defaults(to: "")
                t.add("taggedFilePath", .text).defaults(to: "")
                t.add("fileExt", .text).defaults(to: "")
                t.add("peopleId", .text).defaults(to: "")
                t.add("peopleIdRecognized", .text).defaults(to: "")
                t.add("peopleIdAssign", .text).defaults(to: "")
                t.add("trainingSample", .boolean).defaults(to: false)
                t.add("facesReviewed", .boolean).defaults(to: false)
            })
        }
        
        migrator.version("v42") { db in
            try db.create(table: "Face", body: { t in
                t.column("imageId", .text).notNull().indexed()
                t.column("pos_top", .double).defaults(to: 0.0)
                t.column("pos_right", .double).defaults(to: 0.0)
                t.column("pos_bottom", .double).defaults(to: 0.0)
                t.column("pos_left", .double).defaults(to: 0.0)
                t.column("peopleIdRecognized", .text).notNull().defaults(to: "")
                t.column("peopleIdAssign", .text).notNull().defaults(to: "")
                t.column("peopleId", .text).notNull().defaults(to: "")
                t.column("peopleName", .text).notNull().defaults(to: "")
                t.column("shortName", .text).notNull().defaults(to: "")
                t.column("file", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.version("v43") { db in
            try db.alter(table: "ImageDevice", body: { t in
                t.add("deviceWidth", .integer).defaults(to: 0)
                t.add("deviceHeight", .integer).defaults(to: 0)
            })
        }
        
        migrator.version("v44") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add("eventCategories", .text).defaults(to: "")
            })
        }
        
        migrator.version("v45") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add("specifyEventCategory", .boolean).defaults(to: false)
            })
        }
        
        migrator.version("v46") { db in
            try db.create(table: "ImageRepository", body: { t in
                t.column("id", .serial).primaryKey().unique().notNull()
                t.column("name", .text).defaults(to: "")
                t.column("homeVolume", .text).defaults(to: "")
                t.column("homePath", .text).defaults(to: "")
                t.column("repositoryVolume", .text).defaults(to: "")
                t.column("repositoryPath", .text).defaults(to: "")
                t.column("storageVolume", .text).defaults(to: "")
                t.column("storagePath", .text).defaults(to: "")
                t.column("faceVolume", .text).defaults(to: "")
                t.column("facePath", .text).defaults(to: "")
                t.column("cropVolume", .text).defaults(to: "")
                t.column("cropPath", .text).defaults(to: "")
                t.column("deviceId", .text).defaults(to: "")
                t.column("useFirstFolderAsEvent", .boolean).defaults(to: false)
                t.column("folderAsEvent", .boolean).defaults(to: false)
                t.column("eventFolderLevel", .integer).defaults(to: 2)
                t.column("folderAsBrief", .boolean).defaults(to: false)
                t.column("briefFolderLevel", .integer).defaults(to: -1)
            })
        }
        
        migrator.version("v47") { db in
            try db.create(table: "RepositoryDevice", body: { t in
                t.column("id", .serial).primaryKey().unique().notNull()
                t.column("repositoryId", .integer).defaults(to: 0)
                t.column("deviceId", .text).defaults(to: "")
                t.column("startYear", .integer).defaults(to: 0)
                t.column("startMonth", .integer).defaults(to: 0)
                t.column("startDay", .integer).defaults(to: 0)
            })
        }
        
        migrator.version("v48") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("repositoryId", .integer).defaults(to: 0).indexed()
            })
        }
        
        migrator.version("v49") { db in
            try db.alter(table: "Image", body: { t in
                t.add("repositoryId", .integer).defaults(to: 0).indexed()
            })
        }
        
        migrator.version("v50") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add("id", .serial).defaults(to: "nextval('\"ImageContainer_id_seq\"'::regclass)").indexed()
                t.add("parentId", .integer).defaults(to: 0).indexed()
            })
        }
        
        migrator.version("v51") { db in
            try db.alter(table: "Image", body: { t in
                t.add("containerId", .integer).defaults(to: 0).indexed()
            })
        }
        
        migrator.version("v52") { db in
            try db.alter(table: "Image", body: { t in
                t.add("deviceId", .text).defaults(to: "").indexed()
                t.add("deviceFileId", .text).defaults(to: "")
            })
        }
        
        migrator.version("v53") { db in
            try db.alter(table: "ImageDeviceFile", body: { t in
                t.add("devicePathId", .text).defaults(to: "").indexed()
                t.add("importedImageId", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.version("v54") { db in
            try db.alter(table: "People", body: { t in
                t.add("coreMember", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.version("v55") { db in
            try db.alter(table: "ImageRepository", body: { t in
                t.add("owner", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.version("v56") { db in
            try db.alter(table: "Family", body: { t in
                t.add("owner", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.version("v57") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add("targetVolume", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.version("v58") { db in
            try db.create(table: "ImageFamily", body: { t in
                t.column("id", .serial).primaryKey().unique().notNull()
                t.column("imageId", .text).defaults(to: "").indexed()
                t.column("familyId", .text).defaults(to: "").indexed()
                t.column("ownerId", .text).defaults(to: "").indexed()
                t.column("familyName", .text).defaults(to: "")
                t.column("owner", .text).defaults(to: "")
            })
        }
        
        migrator.version("v59") { db in
            try db.alter(table: "People", body: { t in
                t.add("coreMemberColor", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.version("v60") { db in
            try db.alter(table: "ImageDeviceFile", body: { t in
                t.add("repositoryId", .integer).defaults(to: 0).indexed()
            })
        }
        
        migrator.version("v61") { db in
            try db.create(table: "ExportProfileEvent", body: { t in
                t.column("id", .serial).primaryKey().unique().notNull()
                t.column("profileId", .text).notNull().indexed()
                t.column("eventId", .text).notNull().indexed()
                t.column("eventName", .text).notNull().indexed()
                t.column("eventNodeType", .text).notNull().indexed()
                t.column("eventOwner", .text).notNull().indexed()
                t.column("exclude", .boolean).defaults(to: true)
            })
            
            try db.alter(table: "ExportProfile", body: { t in
                t.add("style", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.version("v62") { db in
            try db.alter(table: "ExportProfile", body: { t in
                t.add("repositoryId", .integer).defaults(to: 0).indexed()
            })
        }
        
        migrator.version("v63") { db in
            try db.alter(table: "Image", body: { t in
                t.add("tags", .jsonb)
            })
            
            try db.alter(table: "ImageDevice", body: { t in
                t.add("metaInfo", .jsonb)
            })
        }
        
        migrator.version("v64") { db in
            try db.alter(table: "Image", body: { t in
                t.add("tagx", .text_array)
            })
        }
        
        migrator.version("v65") { db in
            try db.alter(table: "ImageDevice", body: { t in
                t.change("homePath").null().defaults(to: "")
            })
        }
        
        migrator.version("v66") { db in
            try db.alter(table: "ImageRepository", body: { t in
                t.add("sequenceOrder", .integer).defaults(to: 0)
            })
        }
        
        do {
            try migrator.migrate()
        }catch{
            self.logger.log(.error, error)
        }
    }
}
