//
//  ImageDBInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/5/8.
//  Copyright © 2020 nonamecat. All rights reserved.
//

//import Foundation
//
//public enum ImageDBLocation {
//    case localFile
//    case localDBServer
//    case remoteDBServer
//    case fromSetting
//}
//
protocol ImageDBInterface {
    
    func testDatabase() -> (Bool, Error?)
    
    
    func versionCheck()
    
    func versionCheck(dropBeforeCreate:Bool)
}
