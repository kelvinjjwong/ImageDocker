//
//  LocationInfoHandler.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/27.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

protocol LocationConsumer {
    
    func consume(location:Location)
    
    func alert(status:Int, message:String, popup:Bool)
}

protocol CoordinateConsumer {
    
    func consume(coordinate:Coord)
    
    func alert(status:Int, message:String)
}
