//
//  Protocol.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//
import Cocoa
import LoggerFactory

public protocol LogWriter2 {
    func id() -> String
    func write(message: String)
    func file() -> String
}


public class Logger2 {
    
    fileprivate var logMessageBuilder:LogMessageBuilder
    fileprivate var displayTypes:[LogType] = [.info, .error, .todo, .warning] // .debug not included by default
    
    private var _category = ""
    private var _subCategory = ""
    
    private var writerFinder:LogWriterFinder?
    
    public init(finder:LogWriterFinder, category:String, subCategory:String, types:[LogType] = []) {
        self.writerFinder = finder
        self._category = category
        self._subCategory = subCategory
        self.logMessageBuilder = LogMessageBuilder(category: category, subCategory: subCategory)
        
        if !types.isEmpty {
            for t in types {
                if let _ = self.displayTypes.firstIndex(of: t) {
                    // continue
                }else{
                    self.displayTypes.append(t)
                }
            }
        }
    }
    
    private var _registered_writer_ids:[String] = []
    
    public func registerWriter(id: String) {
        if !self._registered_writer_ids.contains(id) {
            self._registered_writer_ids.append(id)
        }
    }
    
    
    private func write(_ msg:String, type:LogType = .info) {
        for _writer_id in self._registered_writer_ids {
            if let writerFinder = self.writerFinder, let writer = writerFinder.findWriter(id: _writer_id) {
                writer.write(message: msg)
            }
        }
    }
    
    public func timecost(_ message:String, fromDate:Date) {
        guard self.displayTypes.contains(.performance) && LoggerFactory.isLogTypeEnabled(.performance, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .performance, message: "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds", error: nil)
        self.write(msg)
    }
    
    public func log(_ message:String) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String) {
//        print("\(logType) contains? \(self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory))")
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Int) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg, type: .info)
    }
    
    public func log(_ logType:LogType, _ message:Int) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Double) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Double) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Float) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    public func log(_ logType:LogType, _ message:Float) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg, type: logType)
    }
    
    public func log(_ message:Any) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Any) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ message:Error) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: message)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:Error) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        self.write(msg)
    }
    
    public func log(_ message:String, _ error:Error) {
        guard self.displayTypes.contains(.info) && LoggerFactory.isLogTypeEnabled(.info, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error)
        self.write(msg)
    }
    
    public func log(_ logType:LogType, _ message:String, _ error:Error) {
        guard self.displayTypes.contains(logType) && LoggerFactory.isLogTypeEnabled(logType, category: _category, subCategory: _subCategory) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: error)
        self.write(msg, type: logType)
    }
}
