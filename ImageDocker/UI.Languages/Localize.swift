//
//  Localize.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/10.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

class Localize {
    
    var eng = ""
    var chs = ""
    
    init(eng:String = "", chs:String = "") {
        self.eng = eng
        self.chs = chs
    }
    
    func word() -> String {
        let lang = PreferencesController.language()
        if lang == "chs" {
            return self.chs
        }else{
            return self.eng
        }
    }
    
    func word(_ placeholder:String, _ keywords:Any...) -> String {
        let lang = PreferencesController.language()
        var template = ""
        if lang == "chs" {
            template = self.chs
        }else{
            template = self.eng
        }
        
        for i in 0..<keywords.count {
            let keyword = keywords[i]
            template = template.replacingFirstOccurrence(of: placeholder, with: "\(keyword)")
        }
        let result = template
        return result
    }
    
    func fill(arguments: String...) -> String {
        var str = self.word()
        for arg in arguments {
            str = str.replacingFirstOccurrence(of: "%s", with: arg)
        }
        return str
    }
    
}

class OptionLocalize {
    
    var options:[String:Localize] = [:]
    var allowMultiSelection = false
    
    init() {
        
    }
    
    convenience init(allowMultiSelection:Bool) {
        self.init()
        self.allowMultiSelection = allowMultiSelection
    }
    
    func add(option:String, word:Localize) -> OptionLocalize{
        self.options[option] = word
        return self
    }
    
    func word(_ op:String) -> String {
        if allowMultiSelection {
            var array:[String] = []
            for key in self.options.keys {
                if op.contains(key) {
                    if let word = self.options[key]?.word() {
                        array.append(word)
                    }
                }
            }
            return array.joined(separator: ", ")
        }else{
            if let word = self.options[op] {
                return word.word()
            }else{
                return op
            }
        }
    }
}
