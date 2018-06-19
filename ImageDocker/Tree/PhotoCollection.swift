//
//  PhotoCollection.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

enum PhotoCollectionType : Int {
    case library
    case userCreated
}

enum PhotoCollectionSource : Int {
    case library
    case moment
    case place
    case event
}

class Photo {
    
}


/* A simple example of a model class which is used by this project for storing information
 about a particular collection of objects in our sample library scenario. These objects
 are used by the SourceListItems to populate the Source List's content without having to
 synchronise the data (e.g. title) with each SourceListItem.
 */
class PhotoCollection: NSObject {
    var title = ""
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
    
    var hasDuplicates:Bool = false
    
    
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
