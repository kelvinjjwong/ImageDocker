//
//  Words+AlertDialog.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/30.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Foundation

extension Words {
    
    
    static let dialog_ok = Localize (
        eng: "OK",
        chs: "确定"
    )
    
    static let dialog_cancel = Localize (
        eng: "Cancel",
        chs: "取消"
    )
    
    static let dialog_save = Localize (
        eng: "Save",
        chs: "保存"
    )
    
    static let dialog_delete = Localize (
        eng: "Delete",
        chs: "删除"
    )
    
    static let dialog_reload = Localize (
        eng: "Reload",
        chs: "刷新"
    )
    
    static let dialog_new = Localize (
        eng: "New",
        chs: "新建"
    )
    
    static let dialog_update = Localize (
        eng: "Update",
        chs: "修改"
    )
    
    static let dialog_event_new = Localize(
        eng: "Are you sure to create a new event?",
        chs: "这将 [新建] 一个活动，是否确定？"
    )
    
    static let dialog_event_new_or_update = Localize(
        eng: "Would you like to create a new event [%s]\n\n or update the existing event [%s]\n\n     to [%s] ?",
        chs: "你希望 [新建] 活动 [%s]\n\n还是 [修改] 现存活动 [%s]\n\n    成为 [%s] ？"
    )
    
    static let dialog_event_update = Localize(
        eng: "Are you sure to update an existing event?",
        chs: "这将 [修改] 这个活动，是否确定？"
    )
    
    static let dialog_event_delete = Localize(
        eng: "Are you sure to delete an existing event?",
        chs: "这将 [删除] 这个活动，是否确定？"
    )
    
    static let warning_should_not_select_multiple_items = Localize(
        eng: "Should not select multiple items",
        chs: "请检查并取消多选"
    )
    
    static let dialog_update_images = Localize(
        eng: "Are you sure to update selected images?",
        chs: "是否确定 [批量修改] 选中的这些照片？"
    )
}
