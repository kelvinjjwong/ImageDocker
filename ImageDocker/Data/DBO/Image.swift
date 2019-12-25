//
//  ImageFile.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct Image : Codable {
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
    var filename:String
    var filenameDate:String?
    var fileSize:String?
    var filesysCreateDate:Date?
    var gpsDate:String?
    var hidden:Bool
    var hideForSourceFilename:String?
    var imageHeight:Int?
    var imageSource:String?
    var imageWidth:Int?
    var iso:String?
    var latitude:String?
    var latitudeBD:String?
    var longitude:String?
    var longitudeBD:String?
    var path:String
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
    var repositoryPath:String
    var subPath:String
    var hiddenByRepository:Bool
    var hiddenByContainer:Bool
    var scanedFace:Bool
    var recognizedFace:Bool
    var facesCount:Int
    var recognizedPeopleIds:String
    var lastTimeExtractExif:Int?
    var noneExif:Bool
    
    
    static func new(filename: String, path: String, parentFolder: String, repositoryPath: String) -> Image {
        return Image(
            //id: nil,
            addDate: nil,
            address: nil,
            addressDescription: nil,
            aperture: nil,
            assignAddress: nil,
            assignAddressDescription: nil,
            assignBusinessCircle: nil,
            assignCity: nil,
            assignCountry: nil,
            assignDateTime: nil,
            assignDistrict: nil,
            assignLatitude: nil,
            assignLatitudeBD: nil,
            assignLongitude: nil,
            assignLongitudeBD: nil,
            assignPlace: nil,
            assignProvince: nil,
            assignStreet: nil,
            audioBits: nil,
            audioChannels: nil,
            audioRate: nil,
            businessCircle: nil,
            cameraMaker: nil,
            cameraModel: nil,
            city: nil,
            containerPath: parentFolder,
            country: nil,
            dateTimeFromFilename: nil,
            district: nil,
            event: nil,
            exifCreateDate: nil,
            exifDateTimeOriginal: nil,
            exifModifyDate: nil,
            exportAsFilename: nil,
            exportTime: nil,
            exportToPath: nil,
            exposureTime: nil,
            filename: filename,
            filenameDate: nil,
            fileSize: nil,
            filesysCreateDate: nil,
            gpsDate: nil,
            hidden: false,
            hideForSourceFilename: nil,
            imageHeight: nil,
            imageSource: nil,
            imageWidth: nil,
            iso: nil,
            latitude: nil,
            latitudeBD: nil,
            longitude: nil,
            longitudeBD: nil,
            path: path,
            photoDescription: nil,
            photoTakenDate: nil,
            photoTakenDay: nil,
            photoTakenHour: nil,
            photoTakenMonth: nil,
            photoTakenYear: nil,
            place: nil,
            province: nil,
            rotation: nil,
            softwareModifiedTime: nil,
            softwareName: nil,
            street: nil,
            suggestPlace: nil,
            trackCreateDate: nil,
            trackModifyDate: nil,
            updateDateTimeDate: nil,
            updateEventDate: nil,
            updateExifDate: nil,
            updateLocationDate: nil,
            updatePhotoTakenDate: nil,
            videoBitRate: nil,
            videoCreateDate: nil,
            videoDuration: nil,
            videoFormat: nil,
            videoFrameRate: nil,
            videoModifyDate: nil,
            shortDescription: nil,
            longDescription: nil,
            originalMD5: nil,
            exportedMD5: nil,
            exportedLongDescription: nil,
            exportState: nil,
            exportFailMessage: nil,
            duplicatesKey: nil,
            originPath: nil,
            facesPath: nil,
            id: UUID().uuidString,
            repositoryPath: repositoryPath.withStash(),
            subPath: path.replacingFirstOccurrence(of: repositoryPath.withStash(), with: ""),
            hiddenByRepository: false,
            hiddenByContainer: false,
            scanedFace:false,
            recognizedFace:false,
            facesCount:0,
            recognizedPeopleIds:"",
            lastTimeExtractExif: 0,
            noneExif: false
        )
    }
    
}

extension Image: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
