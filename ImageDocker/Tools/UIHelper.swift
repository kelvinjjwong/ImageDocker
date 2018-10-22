//
//  UIHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/10/15.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

struct UIHelper {
    
    static func windowSize() -> (width:CGFloat, height:CGFloat, widthMax:CGFloat, heightMax:CGFloat, originPoint:CGPoint, isSmallScreen:Bool) {
        let dockerHeight = 80
        let menubarHeight = 20
        
        let screenWidth = NSScreen.main?.frame.width
        let screenHeight = NSScreen.main?.frame.height
        
        let windowOriginPoint = CGPoint(x: 0, y: dockerHeight)
        let newWidth = screenWidth!
        let newHeight = screenHeight! - CGFloat(dockerHeight + menubarHeight)
        
        var smallScreen = false
        if Float(screenWidth!) < 1500 {
            smallScreen = true
        }
        
        return (width:newWidth, height:newHeight, widthMax: screenWidth!, heightMax: screenHeight!, originPoint: windowOriginPoint, isSmallScreen: smallScreen)
    }
}
