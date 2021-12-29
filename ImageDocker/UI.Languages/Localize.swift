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
    
}
