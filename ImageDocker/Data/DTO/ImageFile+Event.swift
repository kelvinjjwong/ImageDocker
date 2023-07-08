//
//  ImageFile+Event.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/23.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
//import CoreLocation
//import SwiftyJSON
//import AVFoundation
//import GRDB

extension ImageFile {
    
    func assignEvent(event:ImageEvent){
        let event = event
        if imageData != nil {
            imageData?.event = event.name
            
            if event.startDate == nil {
                event.startDate = imageData?.photoTakenDate
            }else {
                if event.startDate! > (imageData?.photoTakenDate)! {
                    event.startDate = imageData?.photoTakenDate
                }
            }
            
            if event.endDate == nil {
                event.endDate = imageData?.photoTakenDate
            }else {
                if event.endDate! < (imageData?.photoTakenDate)! {
                    event.endDate = imageData?.photoTakenDate
                }
            }
            imageData?.updateEventDate = Date()
        }
        self.transformDomainToMetaInfo()
    }
}
