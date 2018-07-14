//
//  Duplicate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/7/14.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

class Duplicate {
    
    var year:Int = 0
    var month:Int = 0
    var day:Int = 0
    var date:Date = Date()
    var place:String = ""
    var event:String = ""
    
}

class Duplicates {
    
    var duplicates:[Duplicate] = []
    var categories:[String] = []
    var paths:[String] = []
}
