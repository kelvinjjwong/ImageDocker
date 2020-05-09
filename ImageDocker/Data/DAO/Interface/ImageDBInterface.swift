//
//  ImageDBInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/5/8.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol ImageDBInterface {
    
    func testDatabase() -> (Bool, Error?)
    
    func versionCheck()
    
}
