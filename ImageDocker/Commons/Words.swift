//
//  Words.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/10.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

struct Words {
    
    static let splash_prepareingFolders = Localize(
        eng: "Preparing folders ...",
        chs: "正在载入照片库文件夹..."
    )
    
    static let splash_preparingUI = Localize(
        eng: "Preparing UI ...",
        chs: "正在渲染用户界面..."
    )
    
    static let splash_creatingDatabaseBackup = Localize(
        eng: "Creating database backup ...",
        chs: "正在备份数据库..."
    )
    
    static let splash_connectingDatabase = Localize(
        eng: "Connecting database ... ",
        chs: "尝试连接数据库... "
    )
    
    static let splash_failedWithUnknownReason = Localize(
        eng: "failed with unknown reason",
        chs: "发生未知错误"
    )
    
    static let splash_initializingUI = Localize(
        eng: "Initializing user interface ...",
        chs: "正在载入用户界面部件..."
    )
    
    static let splash_laodingLibraries = Localize(
        eng: "Loading libraries ...",
        chs: "正在载入照片库..."
    )
    
    static let main_combineTooltip = Localize(
        eng: "Combine duplicated images to the 1st image",
        chs: "合并重复的照片到以第一张为主"
    )
    
    static let dbError = Localize(
        eng: "DB Error",
        chs: "数据库错误"
    )
    
    static let todayInPreviousYears = Localize(
        eng: "Today in Previous Years",
        chs: "往年今日"
    )
    
    static let save = Localize(
        eng: "Save",
        chs: "保存"
    )
    
    static let hidden = Localize(
        eng: "Hidden",
        chs: "隐藏"
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
    
    static let nav_cat_moments = Localize(
        eng: "Moments",
        chs: "时刻"
    )
    
    static let nav_cat_events = Localize(
        eng: "Events",
        chs: "活动"
    )
    
    static let nav_cat_places = Localize(
        eng: "Places",
        chs: "地点"
    )
    
    static let nav_cat_libraries = Localize(
        eng: "Libraries",
        chs: "照片库"
    )
    
    static let pages = Localize(
        eng: "Pages...",
        chs: "分页..."
    )
    
    static let reload = Localize(
        eng: "RELOAD",
        chs: "重新载入"
    )
    
    static let importingImages = Localize(
        eng: "Importing images ...",
        chs: "正在导入照片 ..."
    )
    
    static let extractingExif = Localize(
        eng: "Extracting EXIF ...",
        chs: "正在解析图像位置 ..."
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
        eng: "Move...",
        chs: "移动到..."
    )
    
    static let updateRepositoryName = Localize(
        eng: "Update Name & Home",
        chs: "保存名称和根路径"
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
        chs: "保存新设定"
    )
    
    static let backToOrigin = Localize(
        eng: "Back to Origin",
        chs: "恢复到原本设定"
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
    
    static let findFaces = Localize(
        eng: "Find Faces",
        chs: "识别人物"
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
    
    static let restarting = Localize(
        eng: "Restarting ...",
        chs: "重新开始任务..."
    )
    
    static let mainmenu_face = Localize(
        eng: "Faces",
        chs: "人物"
    )
    
    static let mainmenu_face_manageFaces = Localize(
        eng: "Manage Faces",
        chs: "管理已发现的人物"
    )
    
    static let mainmenu_face_scan = Localize(
        eng: "Scan faces in pictures",
        chs: "在照片中发现人物"
    )
    
    static let mainmenu_face_reScan = Localize(
        eng: "Force Re-Scan all pictures",
        chs: "在照片中重新发现人物"
    )
    
    static let mainmenu_face_recognize = Localize(
        eng: "Recognize faces in pictures",
        chs: "在照片中识别人物"
    )
    
    static let mainmenu_face_reRecognize = Localize(
        eng: "Force Re-Recognize all pictures",
        chs: "在照片中重新识别人物"
    )
    
    static let mainmenu_face_in_collection = Localize (
        eng: "Pictures in collection",
        chs: "从选中的照片集"
    )
    
    static let mainmenu_face_in_allYears = Localize(
        eng: "Pictures in all-years",
        chs: "从所有时刻"
    )
    
    static let mainmenu_face_in_year = Localize(
        eng: "Pictures in %s",
        chs: "%s 年"
    )
    
    static let mainmenu_export = Localize(
        eng: "Export",
        chs: "导出照片"
    )
    
    static let mainmenu_export_configuration = Localize(
        eng: "Configuration",
        chs: "配置..."
    )
    
    static let mainmenu_export_export = Localize(
        eng: "Export profile...",
        chs: "导出..."
    )
    
    static let exportManager = Localize (
        eng: "Export Manager",
        chs: "配置照片导出"
    )
    
    static let faceManager = Localize (
        eng: "Face Manager",
        chs: "人物管理"
    )
    
    static let scanAndImportImages = Localize (
        eng: "Scan & Import from repositories",
        chs: "扫描照片库并导入照片"
    )
    
    static let stopScanningRepository = Localize(
        eng: "Stop scanning repositories",
        chs: "停止扫描照片库"
    )
    
    static let scanAndExtractExif = Localize(
        eng: "Scan & Extract EXIF from images",
        chs: "扫描照片并解析地理位置"
    )
    
    static let imageOption = Localize(
        eng: "Image Options",
        chs: "更多修改选项"
    )
    
    static let largeView = Localize(
        eng: "Large View",
        chs: "放大展示"
    )
    
    
}
