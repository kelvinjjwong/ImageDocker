//
//  UIHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/10/15.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

struct UIHelper {
    
    ///
    ///NSScreen.visibleFrame
    ///The returned rectangle is always based on the current user-interface settings and does not include the area currently occupied by the dock and menu bar. Because it is based on the current user-interface settings, the returned rectangle can change between calls and should not be cached.
    ///
    ///https://developer.apple.com/documentation/appkit/nsscreen/1388369-visibleframe
    ///
    static func windowSize() -> (width:CGFloat, height:CGFloat, widthMax:CGFloat, heightMax:CGFloat, originPoint:CGPoint, isSmallScreen:Bool) {

        let screenWidth = NSScreen.main?.visibleFrame.width // visibleFrame
        let screenHeight = NSScreen.main?.visibleFrame.height
        
        let windowOriginPoint = CGPoint(x: 0, y: 0)
        
        var smallScreen = false
        if Float(screenWidth!) < 1500 {
            smallScreen = true
        }
        
        return (width:screenWidth ?? 0, height:screenHeight ?? 0, widthMax: screenWidth!, heightMax: screenHeight!, originPoint: windowOriginPoint, isSmallScreen: smallScreen)
    }
}
