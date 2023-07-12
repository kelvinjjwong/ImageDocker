//
//  Words+EditRepository.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/30.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

extension Words {
    
    static let repository_name = Localize(
        eng: "Name",
        chs: "照片库名称"
    )
    
    static let repository_box_store_images = Localize(
        eng: "Where to store images?",
        chs: "照片存储的位置"
    )
    
    static let repository_box_store_faces = Localize(
        eng: "Where to store faces?",
        chs: "人物脸孔存储的位置"
    )
    
    static let repository_box_link_to_device = Localize(
        eng: "Link to",
        chs: "照片来源的设备"
    )
    
    static let repository_initial_event = Localize(
        eng: "Initial Event",
        chs: "活动的初值策略"
    )
    
    static let repository_initial_brief = Localize(
        eng: "Initial Brief",
        chs: "描述的初值策略"
    )
    
    static let repository_home_path = Localize(
        eng: "Home",
        chs: "主文件夹"
    )
    
    static let repository_editable_images_path = Localize(
        eng: "Editable Images",
        chs: "可修改的照片的存储点"
    )
    
    static let repository_raw_images_path = Localize(
        eng: "Raw Images",
        chs: "不可修改的照片的存储"
    )
    
    static let repository_faces_images_path = Localize(
        eng: "Faces",
        chs: "人物脸孔的存储点"
    )
    
    static let repository_crops_images_path = Localize(
        eng: "Crops",
        chs: "剪切的存储点"
    )
    
    static let save = Localize(
        eng: "Save",
        chs: "保存"
    )
    
    static let total = Localize(
        eng: "Total",
        chs: "总计"
    )
    
    static let imageMissingRepositoryPath = Localize(
        eng: "No-repo",
        chs: "缺根路径"
    )
    
    static let imageMissingSubPath = Localize(
        eng: "No-sub",
        chs: "缺分支路径"
    )
    
    static let imageMissingId = Localize(
        eng: "No-id",
        chs: "缺标识"
    )
    
    static let imageNotMatchingRepository = Localize (
        eng: "NotMatch-Repo",
        chs: "与照片库不匹配"
    )
    
    static let containerNoRepo = Localize(
        eng: "container-no-repo",
        chs: "文件夹未关联照片库"
    )
    
    static let containerNoSub = Localize(
        eng: "container-no-sub",
        chs: "文件夹未关联分支路径"
    )
    
    static let uncategorized = Localize(
        eng: "Uncategorized",
        chs: "未分类"
    )
    
    static let nav_cat_devices = Localize(
        eng: "Devices",
        chs: "外部设备"
    )
    
    static let imageWithoutFace = Localize(
        eng: "No-face",
        chs: "照片不包含人脸"
    )
    
    static let imageNotYetScanFace = Localize(
        eng: "Not-yet-scan",
        chs: "照片未识别人脸"
    )
    
    static let repositoryConfiguration = Localize(
        eng: "Repository Configuration",
        chs: "照片库设定"
    )
    
    static let addRepository = Localize(
        eng: "Add Repository",
        chs: "添加照片库"
    )
    
    static let assign = Localize(
        eng: "Assign",
        chs: "指定"
    )
    
    static let moveTo = Localize(
        eng: "Choose",
        chs: "选择..."
    )
    
    static let updateRepositoryName = Localize(
        eng: "Update Name & Home",
        chs: "保存名称和路径"
    )
    
    static let editRepository = Localize(
        eng: "Edit Repository",
        chs: "修改照片库设定"
    )
    
    static let enableRepository = Localize(
        eng: "Enable Repository",
        chs: "启用照片库"
    )
    
    static let disableRepository = Localize(
        eng: "Disable Repository",
        chs: "停用照片库"
    )
    
    static let cannotFindRepositoryPath = Localize(
        eng: "ERROR: Cannot find repository with path",
        chs: "错误：找不到照片库的路径"
    )
    
    static let browsePath = Localize(
        eng: "Browse...",
        chs: "选取路径..."
    )
    
    static let viewInFinder = Localize(
        eng: "View in Finder",
        chs: "检视文件夹"
    )
    
    static let update = Localize(
        eng: "Update",
        chs: "保存新存储点"
    )
    
    static let backToOrigin = Localize(
        eng: "Back to Origin",
        chs: "恢复到原存储点"
    )
    
    static let followHome = Localize(
        eng: "Follow Home",
        chs: "跟随根路径"
    )
    
    static let link = Localize(
        eng: "Link",
        chs: "绑定"
    )
    
    static let checkPaths = Localize(
        eng: "Check Paths",
        chs: "检查路径正确性"
    )
    
    static let clean = Localize(
        eng: "Clean",
        chs: "解绑"
    )
    
    static let preview = Localize(
        eng: "Preview",
        chs: "预览"
    )
    
    static let updateEmptyEvents = Localize(
        eng: "Update Empty Events",
        chs: "填充活动空白"
    )
    
    static let updateEmptyBriefs = Localize(
        eng: "Update Empty Briefs",
        chs: "填充描述空白"
    )
    
    static let updateAllEvents = Localize(
        eng: "Update All Events",
        chs: "修改所有照片的活动"
    )
    
    static let updateAllBriefs = Localize(
        eng: "Update All Briefs",
        chs: "修改所有照片的描述"
    )
    
    static let pathFollowDevicePath = Localize(
        eng: "Let paths of Repository follow Device's",
        chs: "照片库路径沿用外设路径"
    )
    
    static let copyEditableImagesToRaw = Localize (
        eng: "Copy Editable Images to Raw Storage",
        chs: "使用可修改照片覆盖原始版本"
    )
    
    static let normalizeDuplicatedHiddens = Localize (
        eng: "Normalize Hidden of Duplicates",
        chs: "梳理重复照片的隐藏版本"
    )
    
    static let hideImagesOfRepository = Localize (
        eng: "Hide Images",
        chs: "隐藏所有照片"
    )
    
    static let showImagesOfRepository = Localize(
        eng: "Show Images",
        chs: "显示所有照片"
    )
    
    static let deleteAllImages = Localize(
        eng: "DELETE all images",
        chs: "删除所有照片"
    )
    
    static let stat = Localize(
        eng: "Statistic",
        chs: "统计"
    )
    
    static let saveRepository = Localize(
        eng: "Save Repository",
        chs: "存储照片库的修改"
    )
    
    static let useFolderAsEvent = Localize(
        eng: "Use folder name as event name",
        chs: "使用文件夹名称作为活动名称"
    )
    
    static let useFolderAsBrief = Localize(
        eng: "Use folder name as image's brief",
        chs: "使用文件夹名称作为照片描述"
    )
}
