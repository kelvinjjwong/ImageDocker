//
//  ConsoleLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//

public class ConsoleLogger2 : LogWriter2 {
    
    public init() {}
    
    private let _id = "console"
    
    public func id() -> String {
        return self._id
    }
    
    public func file() -> String {
        return "console"
    }
    
    public func write(message: String) {
        print(message)
    }
}
