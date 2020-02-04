//
//  PhotoCollection.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

enum PhotoCollectionType : Int {
    case library
    case userCreated
}

enum PhotoCollectionSource : Int {
    case library
    case moment
    case place
    case event
    case device
}

class Photo {
    
}


/* A model class which is used for storing information
 about a particular collection of entries in tree. These entries
 are used by the SourceListItems to populate the Source List's content without having to
 synchronise the data (e.g. title) with each SourceListItem.
 */
class PhotoCollection: NSObject {
    var title = ""
    var identifier = ""
    var photoCount:Int = 0
    var year:Int = 0
    var month:Int = 0
    var day:Int = 0
    var place:String = ""
    var event:String = ""
    var gov:String = ""
    
    var hasDuplicates:Bool = false
    
    var placeData:String = "" // deprecated
    var countryData:String = "" // deprecated
    var provinceData:String = "" // deprecated
    var cityData:String = "" // deprecated
    
    var isDateEntry:Bool = true // deprecated
    var url:URL = URL(fileURLWithPath: "/") // deprecated
    var isAwaitingEntry:Bool = false // deprecated
    var photos = [Any]() // deprecated
    var type: PhotoCollectionType? // deprecated
    var imageFolder:ImageFolder? = nil // deprecated
    var source : PhotoCollectionSource? // deprecated
    var enableMoreButton = false // deprecated
    var imageOfMoreButton:NSImage? = nil // deprecated
    var treeNodeView:LCSourceListTableCellView? = nil // deprecated
    var buttonAction: ((_ sender:NSButton) -> Void)? = nil // deprecated
    var buttonMenu:[MenuAction] = [] // deprecated
    var deviceConnected = false // deprecated
    
    override init(){
        super.init()
    }
    
    convenience init(imageCount:Int, year:Int, month:Int = 0, day:Int = 0, event:String = "", gov:String = "", place:String = "") {
        self.init()
        self.photoCount = imageCount
        self.year = year
        self.month = month
        self.day = day
        self.event = event
        self.gov = gov
        self.place = place
    }
    
    // deprecated
    convenience init(title: String, identifier: String, type: PhotoCollectionType, source: PhotoCollectionSource) {
        self.init()
        self.title = title
        self.identifier = identifier
        self.type = type
        self.source = source
    }
}
