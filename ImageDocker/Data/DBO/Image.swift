//
//  ImageFile.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class Image : Codable {
    //var id: Int64?      // <- the row id
    var audioBits:Int?
    var audioChannels:Int?
    var audioRate:Int?
    var hidden:Bool = false
    var imageHeight:Int?
    var imageWidth:Int?
    var photoTakenDay:Int?
    var photoTakenMonth:Int?
    var photoTakenYear:Int?
    var photoTakenHour:Int?
    var rotation:Int?
    var addDate:Date?
    var assignDateTime:Date?
    var exifCreateDate:Date?
    var exifDateTimeOriginal:Date?
    var exifModifyDate:Date?
    var exportTime:Date?
    var filenameDate:String?
    var filesysCreateDate:Date?
    var photoTakenDate:Date?
    var softwareModifiedTime:Date?
    var trackCreateDate:Date?
    var trackModifyDate:Date?
    var updateDateTimeDate:Date?
    var updateEventDate:Date?
    var updateExifDate:Date?
    var updateLocationDate:Date?
    var updatePhotoTakenDate:Date?
    var videoCreateDate:Date?
    var videoFrameRate:Double?
    var videoModifyDate:Date?
    
    var address:String?
    var addressDescription:String?
    var aperture:String?
    var assignAddress:String?
    var assignAddressDescription:String?
    var assignBusinessCircle:String?
    var assignCity:String?
    var assignCountry:String?
    var assignDistrict:String?
    var assignLatitude:String?
    var assignLatitudeBD:String?
    var assignLongitude:String?
    var assignLongitudeBD:String?
    var assignPlace:String?
    var assignProvince:String?
    var assignStreet:String?
    var businessCircle:String?
    var cameraMaker:String?
    var cameraModel:String?
    var city:String?
    var containerPath:String?
    var country:String?
    var dateTimeFromFilename:String?
    var district:String?
    var event:String?
    var exportAsFilename:String?
    var exportToPath:String?
    var exposureTime:String?
    var fileSize:String?
    var filename:String = ""
    var gpsDate:String?
    var hideForSourceFilename:String?
    var imageSource:String?
    var iso:String?
    var latitude:String?
    var latitudeBD:String?
    var longitude:String?
    var longitudeBD:String?
    var path:String = ""
    var photoDescription:String?
    var place:String?
    var province:String?
    var softwareName:String?
    var street:String?
    var suggestPlace:String?
    var videoBitRate:String?
    var videoDuration:String?
    var videoFormat:String?
    var shortDescription:String?
    var longDescription:String?
    var originalMD5:String?
    var exportedMD5:String?
    var exportedLongDescription:String?
    var exportState:String?
    var exportFailMessage:String?
    var delFlag:Bool?
    var duplicatesKey:String?
    var originPath:String?
    var facesPath:String?
    var id:String?
    var subPath:String = ""
    var hiddenByRepository:Bool = false
    var hiddenByContainer:Bool = false
    var repositoryPath:String = ""
    var scanedFace:Bool = false
    var recognizedFace:Bool = false
    var facesCount:Int = 0
    var recognizedPeopleIds:String = ""
    var lastTimeExtractExif:Int?
    var noneExif:Bool = false
    var resizedFilePath:String? = ""
    var taggedFilePath:String? = ""
    var fileExt:String? = ""
    var peopleId:String? = ""
    var peopleIdRecognized:String? = ""
    var peopleIdAssign:String? = ""
    var trainingSample:Bool? = false
    var facesReviewed:Bool? = false
    var repositoryId:Int = 0
    var containerId:Int = 0
    var deviceId:String = ""
    var deviceFileId:String = ""
    
    public init() {
        
    }
    
    
    static func new(filename: String, path: String, parentFolder: String, repositoryPath: String) -> Image {
        let obj = Image()
        obj.id = UUID().uuidString
        obj.filename = filename
        obj.path = path
        obj.containerPath = parentFolder
        obj.repositoryPath = repositoryPath.withLastStash()
        obj.subPath = path.replacingFirstOccurrence(of: repositoryPath.withLastStash(), with: "")
        return obj
    }
    
}

//extension Image: FetchableRecord, MutablePersistableRecord, TableRecord {
//
//}

extension Image : PostgresRecord {
    public func postgresTable() -> String {
        return "Image"
    }
    
    public func primaryKeys() -> [String] {
        return ["path"]
    }
    
    public func autofillColumns() -> [String] {
        return ["id"]
    }
    
    
}

