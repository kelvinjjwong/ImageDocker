//
//  MetaInfoHandler.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/26.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

protocol MetaInfoStoreDelegate {
    func setMetaInfo(_ info:MetaInfo?)
    func setMetaInfo(_ info:MetaInfo?, ifNotExists: Bool)
    func updateMetaInfoView()
    func getMeta(category:String, subCategory:String, title:String) -> String?
    func getInfos() -> [MetaInfo]
}

protocol MetaInfoConsumeDelegate {
    func consume(_ infos:[MetaInfo])
}
