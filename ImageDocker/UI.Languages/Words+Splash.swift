//
//  Words+Splash.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/30.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

extension Words {
    
    static let splash_backing_up_database = Localize(
        eng: "Backup from [🗃️ %s] to [🗄️ %s] ...",
        chs: "正在备份数据库 [🗃️ %s] 到 [🗄️ %s] ..."
    )
    
    static let splash_connecting_database = Localize(
        eng: "Connecting database [🗃️ %s] ...",
        chs: "正在尝试连接数据库 [🗃️ %s] ..."
    )
    
    static let splash_prepareingFolders = Localize(
        eng: "Preparing folders ...",
        chs: "正在载入照片库文件夹..."
    )
    
    static let splash_preparingUI = Localize(
        eng: "Preparing UI ...",
        chs: "正在渲染用户界面..."
    )
    
    static let splash_creatingDatabaseBackup = Localize(
        eng: "Creating database backup 🗃️ ...",
        chs: "正在备份数据库 🗃️ ..."
    )
    
    static let splash_connectingDatabase = Localize(
        eng: "Connecting database 🗃️ ... ",
        chs: "尝试连接数据库 🗃️ ... "
    )
    
    static let splash_failedWithUnknownReason = Localize(
        eng: "failed with unknown reason",
        chs: "发生未知错误"
    )
    
    static let splash_initializingUI = Localize(
        eng: "Initializing user interface ...",
        chs: "正在载入用户界面部件..."
    )
    
    static let splash_loadingLibraries = Localize(
        eng: "Loading libraries ...",
        chs: "正在载入照片库..."
    )
    
    static let splash_creatingDatabaseBackup_failed_missing_volumes = Localize(
        eng: "Unable to create database backup, missing volume: %s",
        chs: "无法创建数据库备份，磁盘未挂载: %s"
    )
    
    static let splash_loadingLibraries_failed_missing_volumes = Localize(
        eng: "Unable to load libraries, missing volume(s): %s",
        chs: "无法载入照片库，磁盘未挂载: %s"
    )
    
    static let dbError = Localize(
        eng: "DB Error",
        chs: "数据库错误"
    )
    
    static let todayInPreviousYears = Localize(
        eng: "Today in Previous Years",
        chs: "往年今日"
    )
}
