//
//  DirectoryViewDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/18.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

class AndroidDirectoryViewDelegate : DirectoryViewDelegate {
    
    var deviceId:String
    
    init(deviceId:String){
        self.deviceId = deviceId
    }
    
    func listSubFolders(in path: String) -> [String] {
        return Android.bridge.folders(device: deviceId, in: path)
    }
    
    func listFiles(in path: String, ext:Set<String>? = nil) -> [String] {
        return Android.bridge.filenames(device: deviceId, in: path)
    }
    
    func home() -> String{
        return "/sdcard/"
    }
    
    func shortcuts() -> [DirectoryViewShortcut] {
        return [
            DirectoryViewShortcut(title: "Pictures", path: "/sdcard/Pictures/"),
            DirectoryViewShortcut(title: "Camera", path: "/sdcard/DCIM/Camera/"),
            DirectoryViewShortcut(title: "Home", path: home())
        ]
    }
    
    
}

class LocalDirectoryViewDelegate : DirectoryViewDelegate {
    func listSubFolders(in path: String) -> [String] {
        return LocalDirectory.bridge.folders(in: path)
    }
    
    func listFiles(in path: String, ext:Set<String>? = nil) -> [String] {
        return LocalDirectory.bridge.filenames(in: path)
    }
    
    func home() -> String{
        return FileManager.default.homeDirectoryForCurrentUser.path
    }
    
    func shortcuts() -> [DirectoryViewShortcut] {
        
        let desktopUrls = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        let desktopUrl = desktopUrls[desktopUrls.count - 1]
//        print(desktopUrl.path)
        
        let documentUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentUrl = documentUrls[documentUrls.count - 1]
//        print(documentUrl.path)
        
        let pictureUrls = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)
        let pictureUrl = pictureUrls[pictureUrls.count - 1]
//        print(pictureUrl.path)
        
        
        var shortcuts:[DirectoryViewShortcut] = []
        shortcuts.append(DirectoryViewShortcut(title: "Desktop", path: desktopUrl.path))
        shortcuts.append(DirectoryViewShortcut(title: "Documents", path: documentUrl.path))
        shortcuts.append(DirectoryViewShortcut(title: "Pictures", path: pictureUrl.path))
        shortcuts.append(DirectoryViewShortcut(title: "Volumes", path: "/Volumes/"))
        return shortcuts
    }
    
    
}
