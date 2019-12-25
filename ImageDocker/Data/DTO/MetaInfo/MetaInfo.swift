//
//  MetaInfo.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

final class MetaInfo: NSObject {

    var category:String!
    var subCategory:String!
    var title:String!
    var value:String?
    
    init(category:String, subCategory:String = "", title:String, value:String?) {
        self.category = category
        self.subCategory = subCategory
        self.title = title
        self.value = value
        super.init()
    }
}
