//
//  ImageFile.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class Image : Codable {
    //var id: Int64?      // <- the row id
    var addDate:Date?
    var address:String?
    var addressDescription:String?
    var aperture:String?
    var assignAddress:String?
    var assignAddressDescription:String?
    var assignBusinessCircle:String?
    var assignCity:String?
    var assignCountry:String?
    var assignDateTime:Date?
    var assignDistrict:String?
    var assignLatitude:String?
    var assignLatitudeBD:String?
    var assignLongitude:String?
    var assignLongitudeBD:String?
    var assignPlace:String?
    var assignProvince:String?
    var assignStreet:String?
    var audioBits:Int?
    var audioChannels:Int?
    var audioRate:Int?
    var businessCircle:String?
    var cameraMaker:String?
    var cameraModel:String?
    var city:String?
    var containerPath:String?
    var country:String?
    var dateTimeFromFilename:String?
    var district:String?
    var event:String?
    var exifCreateDate:Date?
    var exifDateTimeOriginal:Date?
    var exifModifyDate:Date?
    var exportAsFilename:String?
    var exportTime:Date?
    var exportToPath:String?
    var exposureTime:String?
    var filename:String = ""
    var filenameDate:String?
    var fileSize:String?
    var filesysCreateDate:Date?
    var gpsDate:String?
    var hidden:Bool = false
    var hideForSourceFilename:String?
    var imageHeight:Int?
    var imageSource:String?
    var imageWidth:Int?
    var iso:String?
    var latitude:String?
    var latitudeBD:String?
    var longitude:String?
    var longitudeBD:String?
    var path:String = ""
    var photoDescription:String?
    var photoTakenDate:Date?
    var photoTakenDay:Int?
    var photoTakenHour:Int?
    var photoTakenMonth:Int?
    var photoTakenYear:Int?
    var place:String?
    var province:String?
    var rotation:Int?
    var softwareModifiedTime:Date?
    var softwareName:String?
    var street:String?
    var suggestPlace:String?
    var trackCreateDate:Date?
    var trackModifyDate:Date?
    var updateDateTimeDate:Date?
    var updateEventDate:Date?
    var updateExifDate:Date?
    var updateLocationDate:Date?
    var updatePhotoTakenDate:Date?
    var videoBitRate:String?
    var videoCreateDate:Date?
    var videoDuration:String?
    var videoFormat:String?
    var videoFrameRate:Double?
    var videoModifyDate:Date?
    var shortDescription:String?
    var longDescription:String?
    var originalMD5:String?
    var exportedMD5:String?
    var exportedLongDescription:String?
    var exportState:String?
    var exportFailMessage:String?
    var duplicatesKey:String?
    var originPath:String?
    var facesPath:String?
    var id:String?
    var repositoryPath:String = ""
    var subPath:String = ""
    var hiddenByRepository:Bool = false
    var hiddenByContainer:Bool = false
    var scanedFace:Bool = false
    var recognizedFace:Bool = false
    var facesCount:Int = 0
    var recognizedPeopleIds:String = ""
    var lastTimeExtractExif:Int?
    var noneExif:Bool = false
    
    public init() {
        
    }
    
    
    static func new(filename: String, path: String, parentFolder: String, repositoryPath: String) -> Image {
        let obj = Image()
        obj.id = UUID().uuidString
        obj.filename = filename
        obj.path = path
        obj.containerPath = parentFolder
        obj.repositoryPath = repositoryPath.withStash()
        obj.subPath = path.replacingFirstOccurrence(of: repositoryPath.withStash(), with: "")
        return obj
    }
    
}

extension Image: FetchableRecord, MutablePersistableRecord, TableRecord {

}

extension Image : PostgresRecord {
    public func postgresTable() -> String {
        return "Image"
    }
    
    public func primaryKeys() -> [String] {
        return ["path"]
    }
    
    
}

