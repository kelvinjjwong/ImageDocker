//
//  ConsoleLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/11.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

enum LogType: String{
    case error
    case warning
    case info
    case debug
    case todo
    case trace
    case performance
}

protocol Logger {
    func timecost(_ message:String, fromDate:Date)
    func log(_ message:String)
    func log(_ logType:LogType, _ message:String)
    func log(_ message:Int)
    func log(_ logType:LogType, _ message:Int)
    func log(_ message:Double)
    func log(_ logType:LogType, _ message:Double)
    func log(_ message:Float)
    func log(_ logType:LogType, _ message:Float)
    func log(_ message:Any)
    func log(_ logType:LogType, _ message:Any)
    func log(_ message:Error)
    func log(_ logType:LogType, _ message:Error)
    func log(_ message:String, _ error:Error)
    func log(_ logType:LogType, _ message:String, _ error:Error)
}

class ConsoleLogger : Logger {
    
    private let dtFormatter = ISO8601DateFormatter()
    
    private var category:String = ""
    private var subCategory:String = ""
    private var displayTypes:[LogType] = [.info, .error, .todo, .warning] // .debug not included by default
    
    init(category:String) {
        self.category = category
        self.dtFormatter.timeZone = TimeZone.current
    }
    
    convenience init(category:String, subCategory:String){
        self.init(category: category)
        self.subCategory = subCategory
    }
    
    convenience init(category:String, displayTypes:[LogType]){
        self.init(category: category)
        self.displayTypes = displayTypes
    }
    
    convenience init(category:String, subCategory:String, displayTypes:[LogType]){
        self.init(category: category)
        self.subCategory = subCategory
        self.displayTypes = displayTypes
    }
    
    convenience init(category:String, excludeTypes:[LogType]){
        self.init(category: category)
        let defaultTypes:Set<LogType> = Set(self.displayTypes)
        let removeTypes:Set<LogType> = Set(excludeTypes)
        self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
    }
    
    convenience init(category:String, subCategory:String, excludeTypes:[LogType]){
        self.init(category: category)
        self.subCategory = subCategory
        let defaultTypes:Set<LogType> = Set(self.displayTypes)
        let removeTypes:Set<LogType> = Set(excludeTypes)
        self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
    }
    
    convenience init(category:String, includeTypes:[LogType]){
        self.init(category: category)
        for t in includeTypes {
            if let _ = self.displayTypes.firstIndex(of: t) {
               // continue
            }else{
                self.displayTypes.append(t)
            }
        }
    }
    
    convenience init(category:String, subCategory:String, includeTypes:[LogType]){
        self.init(category: category)
        self.subCategory = subCategory
        for t in includeTypes {
            if let _ = self.displayTypes.firstIndex(of: t) {
               // continue
            }else{
                self.displayTypes.append(t)
            }
        }
    }
    
    private func prefix() -> String {
        if subCategory == "" {
            return "\(self.dtFormatter.string(from: Date())) [\(category)]"
        }else{
            return "\(self.dtFormatter.string(from: Date())) [\(category)][\(subCategory)]"
        }
    }
    
    public func timecost(_ message:String, fromDate:Date){
        log(.performance, "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds")
    }
    
    fileprivate func iconOfType(_ logType:LogType) -> String {
        switch logType {
        case LogType.error:
            return "📕"
        case LogType.warning:
            return "📙"
        case LogType.debug:
            return "📓"
        case LogType.todo:
            return "⚠️"
        case LogType.trace:
            return "🐢"
        case LogType.performance:
            return "🕘"
        default:
            return "📗"
        }
    }
    
    public func log(_ message:String){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            print("\(self.iconOfType(LogType.info)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ logType:LogType, _ message:String){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            print("\(self.iconOfType(logType)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ message:Int){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            print("\(self.iconOfType(LogType.info)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ logType:LogType, _ message:Int){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            print("\(self.iconOfType(logType)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ message:Double){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            print("\(self.iconOfType(LogType.info)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ logType:LogType, _ message:Double){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            print("\(self.iconOfType(logType)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ message:Float){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            print("\(self.iconOfType(LogType.info)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ logType:LogType, _ message:Float){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            print("\(self.iconOfType(logType)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ message:Any){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            print("\(self.iconOfType(LogType.info)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ logType:LogType, _ message:Any){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            print("\(self.iconOfType(logType)) \(prefix()) \(message)")
        }
    }
    
    public func log(_ error:Error){
        if let _ = self.displayTypes.firstIndex(of: .error) {
            print("\(self.iconOfType(LogType.error)) \(prefix()) \(error)")
        }
    }
    
    public func log(_ logType:LogType, _ error:Error){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            print("\(self.iconOfType(logType)) \(prefix()) \(error)")
        }
    }
    
    public func log(_ message:String, _ error:Error){
        if let _ = self.displayTypes.firstIndex(of: .error) {
            print("\(self.iconOfType(LogType.error)) \(prefix()) \(message) - \(error)")
        }
    }
    
    public func log(_ logType:LogType, _ message:String, _ error:Error){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            print("\(self.iconOfType(logType)) \(prefix()) \(message) - \(error)")
        }
    }
}
