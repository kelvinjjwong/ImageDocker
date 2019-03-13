//
//  ImageFace.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/17.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImageFace : Codable {
    //var id: Int64?      // <- the row id
    var id: String
    var imageId: String
    var imageDate: Date?
    var imageYear:Int
    var imageMonth:Int
    var imageDay:Int
    var repositoryPath: String
    var cropPath: String
    var subPath : String
    var filename : String
    var peopleId : String?
    var peopleAge:Int
    var recognizeBy : String?
    var recognizeVersion : String?
    var recognizeDate : Date?
    var sampleChoice : Bool
    var faceX:String
    var faceY:String
    var faceWidth:String
    var faceHeight:String
    var frameX:String
    var frameY:String
    var frameWidth:String
    var frameHeight:String
    var iconChoice : Bool
    var tagOnly : Bool
    var remark:String
    var sampleChangeDate: Date?
    
    static func fromPerson(peopleId:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> ImageFace {
        return ImageFace(id: "",
                         imageId: "",
                         imageDate: nil,
                         imageYear:0,
                         imageMonth:0,
                         imageDay:0,
                         repositoryPath: repositoryPath,
                         cropPath: cropPath,
                         subPath: subPath,
                         filename: filename,
                         peopleId: peopleId,
                         peopleAge: 0,
                         recognizeBy: nil,
                         recognizeVersion: nil,
                         recognizeDate: nil,
                         sampleChoice: false,
                         faceX: "",
                         faceY: "",
                         faceWidth: "",
                         faceHeight: "",
                         frameX: "",
                         frameY: "",
                         frameWidth: "",
                         frameHeight: "",
                         iconChoice: false,
                         tagOnly: false,
                         remark: "",
                         sampleChangeDate: nil)
    }
    
    static func new(imageId:String, repositoryPath:String, cropPath:String, subPath:String, filename:String,
                    faceX:String, faceY:String, faceWidth:String, faceHeight:String,
                    frameX:String, frameY:String, frameWidth:String, frameHeight:String,
                    imageDate:Date? = nil, tagOnly:Bool = false, remark:String = "",
                    year:Int = 0, month:Int = 0, day:Int = 0) -> ImageFace {
        return ImageFace(id: UUID().uuidString,
                         imageId: imageId,
                         imageDate: imageDate,
                         imageYear:year,
                         imageMonth:month,
                         imageDay:day,
                         repositoryPath: repositoryPath,
                         cropPath: cropPath,
                         subPath: subPath,
                         filename: filename,
                         peopleId: nil,
                         peopleAge: 0,
                         recognizeBy: nil,
                         recognizeVersion: nil,
                         recognizeDate: nil,
                         sampleChoice: false,
                         faceX: faceX,
                         faceY: faceY,
                         faceWidth: faceWidth,
                         faceHeight: faceHeight,
                         frameX: frameX,
                         frameY: frameY,
                         frameWidth: frameWidth,
                         frameHeight: frameHeight,
                         iconChoice: false,
                         tagOnly: tagOnly,
                         remark: remark,
                         sampleChangeDate: nil)
    }
}

extension ImageFace: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
