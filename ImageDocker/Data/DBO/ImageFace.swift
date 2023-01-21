//
//  ImageFace.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/17.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class ImageFace : Codable {
    //var id: Int64?      // <- the row id
    var id: String = ""
    var imageId: String = ""
    var imageDate: Date?
    var imageYear:Int = 0
    var imageMonth:Int = 0
    var imageDay:Int = 0
    var repositoryPath: String = ""
    var cropPath: String = ""
    var subPath : String = ""
    var filename : String = ""
    var peopleId : String?
    var peopleAge:Int = 0
    var recognizeBy : String?
    var recognizeVersion : String?
    var recognizeDate : Date?
    var sampleChoice : Bool = false
    var faceX:String = ""
    var faceY:String = ""
    var faceWidth:String = ""
    var faceHeight:String = ""
    var frameX:String = ""
    var frameY:String = ""
    var frameWidth:String = ""
    var frameHeight:String = ""
    var iconChoice : Bool = false
    var tagOnly : Bool = false
    var remark:String = ""
    var sampleChangeDate: Date?
    var locked:Bool = false
    
    public init() {
        
    }
    
    static func fromPerson(peopleId:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> ImageFace {
        let obj = ImageFace()
        obj.peopleId = peopleId
        obj.repositoryPath = repositoryPath
        obj.cropPath = cropPath
        obj.subPath = subPath
        obj.filename = filename
        return obj
    }
    
    static func new(imageId:String, repositoryPath:String, cropPath:String, subPath:String, filename:String,
                    faceX:String, faceY:String, faceWidth:String, faceHeight:String,
                    frameX:String, frameY:String, frameWidth:String, frameHeight:String,
                    imageDate:Date? = nil, tagOnly:Bool = false, remark:String = "",
                    year:Int = 0, month:Int = 0, day:Int = 0) -> ImageFace {
        let obj = ImageFace()
        obj.id = UUID().uuidString
        obj.imageId = imageId
        obj.imageDate = imageDate
        obj.imageYear = year
        obj.imageMonth = month
        obj.imageDay = day
        obj.repositoryPath = repositoryPath
        obj.cropPath = cropPath
        obj.subPath = subPath
        obj.filename = filename
        obj.faceX = faceX
        obj.faceY = faceY
        obj.faceWidth = faceWidth
        obj.faceHeight = faceHeight
        obj.frameX = frameX
        obj.frameY = frameY
        obj.frameWidth = frameWidth
        obj.frameHeight = frameHeight
        obj.tagOnly = tagOnly
        obj.remark = remark
        return obj
    }
}

extension ImageFace: FetchableRecord, MutablePersistableRecord, TableRecord {

}


extension ImageFace : PostgresRecord {
    public func postgresTable() -> String {
        return "ImageFace"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
