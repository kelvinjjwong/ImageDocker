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
    
}
