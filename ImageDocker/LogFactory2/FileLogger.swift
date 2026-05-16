//
//  FileLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Foundation

public class FileLogger2 : LogWriter2 {
    
    private var _id = ""
    private var _folder = ""
    private var _filename = ""
    
    public init(id:String, folder:String, filename:String) {
        self._id = id
        self._folder = folder
        self._filename = filename
    }
    
    public func id() -> String {
        return self._id
    }
    
    public func file() -> String {
        return URL(fileURLWithPath: self._folder).appending(path: self._filename).path()
    }
    
    public func write(message: String) {
        print(message)
    }
}
