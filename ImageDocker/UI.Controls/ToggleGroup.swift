//
//  ToggleGroup.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/7/13.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

public final class ToggleGroup {
    
    let logger = ConsoleLogger(category: "ToggleGroup")
    
    private var keysOrderred:[String] = []
    
    private var toggles:[String:NSButton]
    
    private var _selected:String = ""
    
    private var _selectAction:((String) -> Void)?
    
    public var selected:String {
        get {
            return _selected
        }
        set {
            _selected = newValue
            self.toggle()
            if let action = _selectAction {
                action(newValue)
            }
        }
    }
    
    // dictionary is no order, if you need to iterate it by order, you should specify keysOrderred array
    public init(_ toggles:[String:NSButton], keysOrderred:[String] = [], onSelect:((String) -> Void)? = nil){
        self.toggles = toggles
        self.keysOrderred = keysOrderred
        self._selectAction = onSelect
    }
    
    public var keys:[String] {
        get {
            if keysOrderred.count != 0 {
                return keysOrderred
            }else {
                return keys(of: self.toggles)
            }
        }
    }
    
    public func disable() {
        for (_, button) in toggles {
            button.isEnabled = false
        }
    }
    
    public func enable() {
        for (_, button) in toggles {
            button.isEnabled = true
        }
    }
    
    public func disable(key:String, onComplete:((String) -> Void)? = nil) {
        let keys = self.keys
        for k in keys {
            self.logger.log(k)
        }
        var i = -1
        for k in keys {
            i += 1
            if k == key {
                break
            }
        }
        self.logger.log("disable \(key) at \(i)")
        var needCheckNext = false
        for (k, button) in toggles {
            if k == key {
                button.isEnabled = false
                if button.state == .on {
                    button.state = .off
                    needCheckNext = true
                }
                break
            }
        }
        if needCheckNext {
            if i == (keys.count - 1) {
                i = 0
            }else{
                i = i + 1
            }
            
            let enableKey = keys[i]
            self.logger.log("will enable \(enableKey) at \(i)")
            for (k, button) in toggles {
                if enableKey == k {
                    button.state = .on
                    break
                }
            }
            if let action = onComplete {
                action(enableKey)
            }
        }
    }
    
    private func toggle() {
        for (_, button) in toggles {
            button.state = .off
        }
        for (key, button) in toggles {
            if key == selected {
                button.state = .on
                break
            }
        }
    }
    
    private func keys(of toggles:[String:NSButton]) -> [String]{
        var keys:[String] = []
        for (key, _) in toggles {
            keys.append(key)
        }
        return keys
    }
}
