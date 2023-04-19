//
//  Words+Tree+Device.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/31.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

extension Words {
    
    static let notification_title_tree = Localize (
        eng: "General",
        chs: "照片库"
    )
    
    static let notification_title_healthcheck = Localize (
        eng: "Health Check",
        chs: "启动自检"
    )
    
    static let notification_volume_connected = Localize (
        eng: "Volumes Connected",
        chs: "已连接的磁盘"
    )
    
    static let notification_volume_missing = Localize (
        eng: "Volumes Missing",
        chs: "断开连接的磁盘"
    )
    
    static let notification_which_volume_connected = Localize (
        eng: "%s connected",
        chs: "%s 已连接"
    )
    
    static let notification_which_volume_missing = Localize (
        eng: "%s missing",
        chs: "%s 已断开连接"
    )
    
    static let notification_none_volume_missing = Localize (
        eng: "nothing missing",
        chs: "已连接所有必需的磁盘"
    )
    
    static let notification_none_volume_connected = Localize (
        eng: "nothing connected",
        chs: "没有连接所有必需的磁盘"
    )
    
    static let device_tree_need_debug_mode = Localize (
        eng: "Enable [DEBUG MODE] in [Settings >> System >> Developer Options] if you've connected your phone via USB.",
        chs: "请通过 USB 连接移动设备，并确保移动设备已启用 [USB 调试模式]，通常在 [设置 >> 系统和更新 >> 开发人员选项]"
    )
    
    static let device_tree_setup_mountpoint_for_ios = Localize (
        eng: "Please setup mount point for iOS devices",
        chs: "请为 iOS 设备设置挂载点"
    )
    
    static let device_tree_ifuse_not_installed = Localize (
        eng: "iFuse/iDevice is not installed. Please install it by command [brew cask install osxfuse] and then [brew install ifuse] in console. To install Homebrew as a prior condition, please access [https://brew.sh] for detail.",
        chs: "iFuse/iDevice 未安装。请使用终端app运行 Homebrew 命令安装，首先 [brew cask install osxfuse] 然后 [brew install ifuse]。如果未安装 Homebrew，请访问 [https://brew.sh] 了解安装方法。"
    )
    
    static let device_tree_unable_to_connect_ios = Localize (
        eng: "Unable to connect to iOS device. Please unlock the screen and then retry.",
        chs: "不能连接 iOS 设备，请解锁屏幕然后再试一次。"
    )
    
    static let device_tree_no_ios_connected = Localize (
        eng: "No iOS devices found connected. Please connect your iPhone/iPad via USB.",
        chs: "没有发现任何 iOS 设备连接了电脑，请通过 USB 连接 iPhone/iPad 。"
    )
}
