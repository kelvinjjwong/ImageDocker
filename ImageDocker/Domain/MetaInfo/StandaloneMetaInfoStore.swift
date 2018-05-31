//
//  StandaloneMetaInfoStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/31.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

class StandaloneMetaInfoStore: MetaInfoStoreDelegate {
    
    var metaInfo:[MetaInfo] = [MetaInfo]()
    
    func setMetaInfo(_ info:MetaInfo){
        setMetaInfo(info, ifNotExists: false)
    }
    
    func setMetaInfo(_ info:MetaInfo, ifNotExists: Bool){
        if info.value == nil || info.value == "" || info.value == "null" {return}
        var exists:Int = 0
        for exist:MetaInfo in self.metaInfo {
            if exist.category == info.category && exist.subCategory == info.subCategory && exist.title == info.title {
                if ifNotExists == false {
                    exist.value = info.value
                }
                exists = 1
            }
        }
        if exists == 0 {
            self.metaInfo.append(info)
        }
    }
    
    func updateMetaInfoView() {
        // do nothing
    }
    
    func getMeta(category:String, subCategory:String = "", title:String) -> String? {
        for meta in metaInfo {
            if meta.category == category && meta.subCategory == subCategory && meta.title == title {
                return meta.value
            }
        }
        return nil
    }
    
    func getInfos() -> [MetaInfo] {
        return self.metaInfo
    }
}

class MetaInfoReader {
    
    public static func getMeta(info:[MetaInfo], category:String, subCategory:String = "", title:String) -> String? {
        for meta in info {
            if meta.category == category && meta.subCategory == subCategory && meta.title == title {
                return meta.value
            }
        }
        return nil
    }
}
