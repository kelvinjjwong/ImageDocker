//
//  Icons.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/20.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import SwiftyGifMac

struct Icons {
    static let node:NSImage = NSImage(imageLiteralResourceName: "photos")
    static let more:NSImage = NSImage(imageLiteralResourceName: "more_horizontal")

    static let filter:NSImage = NSImage(imageLiteralResourceName: "filter")
    static let goto:NSImage = NSImage(imageLiteralResourceName: "goto")


    static let photos:NSImage = NSImage(imageLiteralResourceName: "photos")
    static let events:NSImage = NSImage(imageLiteralResourceName: "airplane")
    static let people:NSImage = NSImage(imageLiteralResourceName: "people")
    static let places:NSImage = NSImage(imageLiteralResourceName: "places")
    static let album:NSImage = NSImage(imageLiteralResourceName: "album")
    static let folder:NSImage = NSImage(imageLiteralResourceName: "folderOpen")
    static let folderAlt:NSImage = NSImage(imageLiteralResourceName: "folderOpenAlt")
    static let calendar:NSImage = NSImage(imageLiteralResourceName: "calendar")
    static let clock:NSImage = NSImage(imageLiteralResourceName: "clock")
    static let flag:NSImage = NSImage(imageLiteralResourceName: "flag")
    static let anchor:NSImage = NSImage(imageLiteralResourceName: "anchor")
    static let phone:NSImage = NSImage(imageLiteralResourceName: "phone")
    static let phoneConnected:NSImage = NSImage(imageLiteralResourceName: "phone_connected")
    static let print:NSImage = NSImage(imageLiteralResourceName: "print")
    static let share:NSImage = NSImage(imageLiteralResourceName: "share")
    static let moreVertical:NSImage = NSImage(imageLiteralResourceName: "more_vertical")
    static let moreHorizontal:NSImage = NSImage(imageLiteralResourceName: "more_horizontal")
    static let play:NSImage = NSImage(imageLiteralResourceName: "play")
    static let pause:NSImage = NSImage(imageLiteralResourceName: "pause")


    static let unknownFace:NSImage = NSImage(imageLiteralResourceName: "UnknownFace")
    static let face:NSImage = NSImage(imageLiteralResourceName: "face")
    
    static let expandLeftPanel:NSImage = NSImage(imageLiteralResourceName: "expand_left")
    static let expandRightPanel:NSImage = NSImage(imageLiteralResourceName: "expand_right")
    static let expandBottomPanel:NSImage = NSImage(imageLiteralResourceName: "expand_bottom")
    static let expandPreviewPanel:NSImage = NSImage(imageLiteralResourceName: "list")
    static let collapseLeftPanel:NSImage = NSImage(imageLiteralResourceName: "collapse_left")
    static let collapseRightPanel:NSImage = NSImage(imageLiteralResourceName: "collapse_right")
    static let collapseBottomPanel:NSImage = NSImage(imageLiteralResourceName: "collapse_bottom")
    static let collapsePreviewPanel:NSImage = NSImage(imageLiteralResourceName: "map")
    static let duplicates:NSImage = NSImage(imageLiteralResourceName: "combine")
    
    static let person:NSImage = NSImage(imageLiteralResourceName: "person")
    static let smile:NSImage = NSImage(imageLiteralResourceName: "smile")
    static let remove:NSImage = NSImage(imageLiteralResourceName: "ClearDarkGray")
    static let edit:NSImage = NSImage(imageLiteralResourceName: "edit")
    static let saveEdit:NSImage = NSImage(named: NSImage.menuOnStateTemplateName)!
    
    static let database_postgresql = NSImage(imageLiteralResourceName: "database_postgresql")
    static let database_mysql = NSImage(imageLiteralResourceName: "database_mysql")
    static let database_archive = NSImage(imageLiteralResourceName: "database_archive")
    static let database_unknown = NSImage(imageLiteralResourceName: "database_unknown")
    
    static let disk_local = NSImage(imageLiteralResourceName: "disk_local")
    static let disk_network = NSImage(imageLiteralResourceName: "disk_network")
    
    static let gif_open_box = try? NSImage(imageName: "open-box.gif")
    static let gif_boating = try? NSImage(imageName: "boating.gif")
    static let gif_flying = try? NSImage(imageName: "flying.gif")
    static let gif_forward = try? NSImage(imageName: "forward.gif")
    static let gif_running = try? NSImage(imageName: "running.gif")
    static let gif_running2 = try? NSImage(imageName: "running2.gif")
    static let gif_sailing = try? NSImage(imageName: "sailing.gif")
    static let gif_package_time = try? NSImage(imageName: "package_time.gif")
    static let gif_vehicle = try? NSImage(imageName: "vehicle.gif")
    static let gif_success = try? NSImage(imageName: "success.gif")
    static let gif_scan = try? NSImage(imageName: "scan.gif")
    static let gif_failure = try? NSImage(imageName: "failure.gif")
    static let gif_loading_fade = try? NSImage(imageName: "loading_fade.gif")
    static let gif_loading_hand = try? NSImage(imageName: "loading_hand.gif")
    static let gif_loading_colorful = try? NSImage(imageName: "loading_colorful.gif")

    static let gifManager = SwiftyGifManager(memoryLimit:100)
    
    static func show_gif(name:String, view:NSImageView, loopCount:Int = -1) {
        if let gif = try? NSImage(imageName: "\(name).gif") {
            view.setImage(gif, manager: gifManager, loopCount: loopCount)
            
        }else{
            view.clear()
        }
    }
    
    static func databaseIcon(engine:String) -> NSImage {
        switch(engine.lowercased()) {
            case "postgresql":
                return Icons.database_postgresql
            case "mysql":
                return Icons.database_mysql
            case "archive":
                return Icons.database_archive
            default:
                return Icons.database_unknown
        }
    }
}
