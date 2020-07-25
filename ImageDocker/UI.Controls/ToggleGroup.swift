//
//  ToggleGroup.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/7/13.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

public final class ToggleGroup {
    
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
    
    public init(_ toggles:[String:NSButton], onSelect:((String) -> Void)? = nil){
        self.toggles = toggles
        self._selectAction = onSelect
    }
    
    public var keys:[String] {
        get {
            return keys(of: self.toggles)
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
