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
    var photos = [Any]()
    var type: PhotoCollectionType?
    var imageFolder:ImageFolder? = nil
    
    override init(){
        super.init()
    }
    
    convenience init(title: String, identifier: String, type: PhotoCollectionType) {
        self.init()
        self.title = title
        self.identifier = identifier
        self.type = type
    }
}
