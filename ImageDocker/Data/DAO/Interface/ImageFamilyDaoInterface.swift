//
//  ImageFamilyDaoInterface.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/17.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation

protocol ImageFamilyDaoInterface {
    
    func getFamilies(imageId:String) -> [ImageFamily]
    
}
