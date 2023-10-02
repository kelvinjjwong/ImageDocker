//
//  ImageFile+SourceFilename.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/23.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
import CoreLocation
//import SwiftyJSON
import AVFoundation
//import GRDB

extension ImageFile {
    
    
    
    // MARK: RECOGNIZE IMAGE SOURCE
    
    func recognizeImageSource(){
        guard imageData != nil && imageData?.imageSource == nil else {return}
        
        let imageSource = Naming.Source.recognize(url: self.url)
        
        if imageData != nil && imageSource != "" {
            imageData?.imageSource = imageSource
        }
    }
    
    // MARK: RECOGNIZE DATETIME
    
    func recognizeDateTimeFromFilename() -> String {
        
//        guard !isRecognizedDateTimeFromFilename else {return ""}
        let dateString = Naming.DateTime.recognize(url: self.url)
        if dateString != "" {
            if self.imageData != nil {
                self.imageData?.dateTimeFromFilename = dateString
            }
//            isRecognizedDateTimeFromFilename = true
        }
        return dateString
    }

}
