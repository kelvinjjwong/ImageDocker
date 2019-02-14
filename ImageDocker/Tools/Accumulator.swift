//
//  Accumulator.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/26.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa


// reference accumulator
class Accumulator : NSObject {
    
    var _target:Int
    private var count:Int = 0
    private var presetAddingMessage:String?
    private var presetCompleteMessage:String?
    private let indicator:NSProgressIndicator?
    private let lblMessage:NSTextField?
    private var hasOnCompleted:Bool = false
    private var onCompleted:(_ data:[String:Int]) -> Void
    private var onDataChanged:(() -> Void)?
    private var isDataChanged:Bool = false
    
    init(target:Int, indicator:NSProgressIndicator? = nil, suspended:Bool = false, lblMessage:NSTextField? = nil, startupMessage:String = ""){
        count = 0
        self._target = target
        self.indicator = indicator
        self.lblMessage = lblMessage
        self.onCompleted = { _ in
            // nothing
        }
        if indicator != nil {
            DispatchQueue.main.async {
                indicator?.minValue = 0
                indicator?.maxValue = Double(target)
                indicator?.doubleValue = 0
                indicator?.isHidden = suspended
            }
        }
        if lblMessage != nil {
            DispatchQueue.main.async {
                lblMessage?.stringValue = startupMessage
            }
        }
    }
    
    init(target:Int, indicator:NSProgressIndicator? = nil, suspended:Bool = false, lblMessage:NSTextField? = nil, presetAddingMessage:String? = nil, presetCompleteMessage:String? = nil, onCompleted: @escaping (_ data:[String:Int]) -> Void, onDataChanged: (() -> Void)? = nil, startupMessage:String = ""){
        count = 0
        self._target = target
        self.indicator = indicator
        self.lblMessage = lblMessage
        self.hasOnCompleted = true
        self.onCompleted = onCompleted
        self.presetAddingMessage = presetAddingMessage
        self.presetCompleteMessage = presetCompleteMessage
        self.onDataChanged = onDataChanged
        if indicator != nil {
            DispatchQueue.main.async {
                indicator?.minValue = 0
                indicator?.maxValue = Double(target)
                indicator?.doubleValue = 0
                indicator?.isHidden = suspended
            }
        }
        if lblMessage != nil {
            DispatchQueue.main.async {
                lblMessage?.stringValue = startupMessage
            }
        }
    }
    
    private var data:[String:Int] = [:]
    
    func assignData(key:String, value:Int){
        data[key] = value
    }
    
    func add(_ message:String = "") -> Bool{
        self.count += 1
        let completed:Bool = (count >= _target)
        if indicator != nil {
            if self.count == 1 { // start counting
                DispatchQueue.main.async {
                    if self.indicator != nil {
                        self.indicator?.isHidden = false
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                if self.lblMessage != nil {
                    if self.presetAddingMessage != nil {
                        self.lblMessage?.stringValue = "\(self.presetAddingMessage!) ( \(self.count) / \(self._target) )"
                    }else {
                        self.lblMessage?.stringValue = "\(message) ( \(self.count) / \(self._target) )"
                    }
                }
                
                self.indicator?.increment(by: 1)
            }
            
            if completed {
                self.forceComplete()
            }
        }
        return completed
    }
    
    func forceCancel() {
        DispatchQueue.main.async {
            if self.indicator != nil {
                self.indicator?.doubleValue = 0
                self.indicator?.isHidden = true
            }
            if self.lblMessage != nil {
                self.lblMessage?.stringValue = ""
            }
        }
    }
    
    func forceComplete() {
        DispatchQueue.main.async {
            if self.indicator != nil {
                self.indicator?.doubleValue = 0
                self.indicator?.isHidden = true
            }
            if self.lblMessage != nil {
                if self.presetCompleteMessage != nil {
                    self.lblMessage?.stringValue = self.presetCompleteMessage!
                }else{
                    self.lblMessage?.stringValue = ""
                }
            }
            if self.hasOnCompleted {
                print("\(Date()) ACCUMULATOR INVOKING ON COMPLETED CLOSURE")
                self.onCompleted(self.data)
            }
            
            if self.isDataChanged && self.onDataChanged != nil {
                self.onDataChanged!()
            }
            
        }
    }
    
    func working() -> Bool {
        return count < _target
    }
    
    func current() -> Int {
        return count
    }
    
    func target() -> Int {
        return _target
    }
    
    func setTarget(_ value:Int){
        self._target = value
        if indicator != nil {
            DispatchQueue.main.async {
                self.indicator?.maxValue = Double(value)
            }
            
        }
    }
    
    func reset() {
        count = 0
        if indicator != nil {
            DispatchQueue.main.async {
                self.indicator?.doubleValue = 0
            }
        }
    }
    
    func dataChanged() {
        self.isDataChanged = true
    }
    
    func display(message:String){
        if self.lblMessage != nil {
            DispatchQueue.main.async {
                self.lblMessage?.stringValue = message
            }
        }
    }
}
