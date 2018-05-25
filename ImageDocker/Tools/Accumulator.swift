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
    private let indicator:NSProgressIndicator?
    private let lblMessage:NSTextField?
    
    init(target:Int, indicator:NSProgressIndicator? = nil, suspended:Bool = false, lblMessage:NSTextField? = nil){
        count = 0
        self._target = target
        self.indicator = indicator
        self.lblMessage = lblMessage
        if indicator != nil {
            DispatchQueue.main.sync {
                indicator?.minValue = 0
                indicator?.maxValue = Double(target)
                indicator?.doubleValue = 0
                indicator?.isHidden = suspended
            }
        }
        if lblMessage != nil {
            DispatchQueue.main.sync {
                lblMessage?.stringValue = ""
            }
        }
    }
    
    func add(_ message:String = "") -> Bool{
        self.count += 1
        let completed:Bool = (count == _target)
        if indicator != nil {
            if self.count == 1 { // start counting
                DispatchQueue.main.async {
                    if self.indicator != nil {
                        self.indicator?.isHidden = false
                    }
                    if self.lblMessage != nil {
                        self.lblMessage?.stringValue = message
                    }
                }
            }
            DispatchQueue.main.async {
                self.indicator?.increment(by: 1)
            }
            
            if completed {
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
        }
        return completed
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
            DispatchQueue.main.sync {
                indicator?.maxValue = Double(value)
            }
            
        }
    }
    
    func reset() {
        count = 0
    }
}
