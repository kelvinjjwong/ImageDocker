//
//  LocationInfoHandler.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/27.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

protocol LocationDelegate {
    
    func handleLocation(address:String, latitude:Double, longitude:Double)
    
    func handleMessage(status:Int, message:String)
}
