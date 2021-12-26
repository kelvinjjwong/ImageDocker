//
//  ConsoleLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/11.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

class ConsoleLogger {
    
    private var category:String = ""
    private var subCategory:String = ""
    
    init(category:String) {
        self.category = category
    }
    
    convenience init(category:String, subCategory:String){
        self.init(category: category)
        self.subCategory = subCategory
    }
    
    private func prefix() -> String {
        if subCategory == "" {
            return "\(Date()) [\(category)]"
        }else{
            return "\(Date()) [\(category)][\(subCategory)]"
        }
    }
    
    public func timecost(_ message:String, fromDate:Date){
        log("\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds")
    }
    
    public func log(_ message:String){
        print("\(prefix()) \(message)")
    }
    
    public func log(_ message:Int){
        print("\(prefix()) \(message)")
    }
    
    public func log(_ message:Double){
        print("\(prefix()) \(message)")
    }
    
    public func log(_ message:Float){
        print("\(prefix()) \(message)")
    }
    
    public func log(_ message:Any){
        print("\(prefix()) \(message)")
    }
    
    public func log(_ error:Error){
        print("\(prefix()) \(error)")
    }
    
    public func log(_ message:String, _ error:Error){
        print("\(prefix()) \(message) - \(error)")
    }
}
