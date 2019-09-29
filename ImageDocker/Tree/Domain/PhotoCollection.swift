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
    var url:URL = URL(fileURLWithPath: "/")
    var identifier = ""
    var photoCount:Int = 0
    var photos = [Any]()
    var type: PhotoCollectionType?
    var imageFolder:ImageFolder? = nil
    var source : PhotoCollectionSource?
    var year:Int = 0
    var month:Int = 0
    var day:Int = 0
    var place:String = ""
    var event:String = ""
    var gov:String = ""
    var placeData:String = ""
    var countryData:String = ""
    var provinceData:String = ""
    var cityData:String = ""
    
    var deviceConnected = false
    
    var isAwaitingEntry:Bool = false
    
    var hasDuplicates:Bool = false
    var isDateEntry:Bool = true
    
    var enableMoreButton = false
    var imageOfMoreButton:NSImage? = nil
    
    var treeNodeView:LCSourceListTableCellView? = nil
    var buttonAction: ((_ sender:NSButton) -> Void)? = nil
    var buttonMenu:[MenuAction] = []
    
    override init(){
        super.init()
    }
    
    convenience init(title: String, identifier: String, type: PhotoCollectionType, source: PhotoCollectionSource) {
        self.init()
        self.title = title
        self.identifier = identifier
        self.type = type
        self.source = source
    }
}
