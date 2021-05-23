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
    
    static let recognizeFaces = Localize(
        eng: "Recognize faces",
        chs: "识别人物"
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
    
    static let scan = Localize(
        eng: "Scan",
        chs: "扫描"
    )
    
    static let forceScan = Localize(
        eng: "Force-Scan",
        chs: "重新扫描"
    )
    
    static let recognize = Localize(
        eng: "Recognize",
        chs: "识别"
    )
    
    static let forceRecognize = Localize(
        eng: "Force-Recognize",
        chs: "重新识别"
    )
    
    static let facesInCollection = Localize(
        eng: " faces in collection",
        chs: "照片选集里的人物"
    )
    
    static let imagesInAllYears = Localize(
        eng: "all-years",
        chs: "全部时刻"
    )
    
    static let facesInArea = Localize(
        eng: " faces in %s",
        chs: "%s里的人物"
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
    
    static let previewEditableVersion = Localize(
        eng: "Preview editable version",
        chs: "展示可修改版本"
    )
    
    static let previewBackupVersion = Localize(
        eng: "Preview backup version",
        chs: "展示原始版本"
    )
    
    static let findEditableVersionFromFinder = Localize(
        eng: "Find editable version from Finder",
        chs: "检视可修改版本的文件"
    )
    
    static let findBackupVersionFromFinder = Localize(
        eng: "Find backup version from Finder",
        chs: "检视原始版本的文件"
    )
    
    static let pickDateTimeFromDateTimeOriginal = Localize(
        eng: "Pick date time from DateTimeOriginal",
        chs: "选取 DateTimeOriginal 作为照片时间"
    )
    
    static let pickDateTimeFromFilename = Localize(
        eng: "Pick date time from Filename",
        chs: "选取文件名里的时间戳作为照片时间"
    )
    
    static let pickDateTimeFromFileCreateDate = Localize(
        eng: "Pick date time from FileCreateDate",
        chs: "选取文件创建时间作为照片时间"
    )
    
    static let pickDateTimeFromFileModifyDate = Localize(
        eng: "Pick date time from FileModifyDate",
        chs: "选取文件修改时间作为照片时间"
    )
    
    static let pickDateTimeFromSoftwareModifiedDate = Localize(
        eng: "Pick date time from Software Modified Date",
        chs: "选取修图软件修改照片的时间作为照片时间"
    )
    
    static let turn90clockwise = Localize(
        eng: "Turn 90° clockwise",
        chs: "顺时针旋转 90 度"
    )
    
    static let turn90counterClockwise = Localize(
        eng: "Turn -90° counter-clockwise",
        chs: "逆时针旋转 90 度"
    )
    
    static let turnUpsideDown = Localize(
        eng: "Upside down",
        chs: "上下翻转"
    )
    
    static let saveImageDirection = Localize(
        eng: "Save image direction",
        chs: "存储照片方向"
    )
    
    static let extractExif = Localize(
        eng: "Extract EXIF from image",
        chs: "从照片解析地理位置"
    )
    
    static let extractDateTimeFromFilename = Localize(
        eng: "Extract date time from filename",
        chs: "从文件名解析照片时间"
    )
    
    static let writeNotes = Localize(
        eng: "Write notes",
        chs: "编辑照片说明"
    )
    
    static let replaceImageWithBackupVersion = Localize(
        eng: "Replace image with backup version",
        chs: "将照片恢复到原始版本"
    )
    
    static let editableVersion = Localize(
        eng: "EDITABLE VERSION",
        chs: "可修改的版本"
    )
    
    static let backupVersion = Localize(
        eng: "BACKUP VERSION",
        chs: "原始的版本"
    )
    
    static let copiedDateToBatchDatePicker = Localize(
        eng: "Copied %s to date picker in batch editor.",
        chs: "已复制日期 %s 到批量选区"
    )
    
    static let error_imageMissingDateTimeInFilename = Localize(
        eng: "Selected image does not have date time in filename, may need re-scan its EXIF.",
        chs: "选取的照片文件名不包含时间戳，可能需要再扫描它的EXIF。"
    )
    
    static let error_imageMissingDateTimeOriginal = Localize(
        eng: "Selected image does not have DateTimeOriginal, may need re-scan its EXIF.",
        chs: "选取的照片不包含 DateTimeOriginal，可能需要再扫描它的EXIF。"
    )
    
    static let error_imageMissingFileCreateDate = Localize(
        eng: "Selected image does not have FileCreateDate, may need re-scan its EXIF.",
        chs: "选取的照片不包含文件创建时间，可能需要再扫描它的EXIF。"
    )
    
    static let error_imageMissingFileModifyDate = Localize(
        eng: "Selected image does not have FileModifyDate, may need re-scan its EXIF.",
        chs: "选取的照片不包含文件修改时间，可能需要再扫描它的EXIF。"
    )
    
    static let error_imageMissingSoftwareModifyDate = Localize(
        eng: "Selected image does not have SoftwareModifyDate, may need re-scan its EXIF.",
        chs: "选取的照片不包含修图软件修改照片的时间，可能需要再扫描它的EXIF。"
    )
    
    static let info_doneExtractExif = Localize(
        eng: "Done extract EXIF for selected image.",
        chs: "完成解析所选照片的地理位置。"
    )
    
    static let info_doneExtractDateTimeFromFilename = Localize(
        eng: "Done extract date time from filename for selected image.",
        chs: "完成解析所选照片文件名里的时间戳。"
    )
    
    static let error_extractDateTimeFromFilename = Localize(
        eng: "Failed to extract date time from filename for selected image.",
        chs: "不能从所选照片文件名里解析时间戳。"
    )
    
    static let info_doneReplacedImageToBackupVersion = Localize(
        eng: "Done replaced image with backup version for selected image.",
        chs: "成功将所选照片恢复到原始版本"
    )
    
    static let error_replaceImageToBackupVersion = Localize(
        eng: "Failed to replace image with backup version for selected image.",
        chs: "不能将所选照片恢复到原始版本"
    )
    
    static let error_imageMissingBackupVersion = Localize(
        eng: "Error: Selected image's backup version does not exist.",
        chs: "错误：所选照片缺失原始版本"
    )
    
    static let error_imageMissingEditableVersion = Localize(
        eng: "Error: Selected image's editable version does not exist.",
        chs: "错误：所选照片缺失可修改的版本"
    )
    
    static let info_doneFindingFaces = Localize(
        eng: "Done find faces from selected image.",
        chs: "完成对照片的人物扫描"
    )
    
    static let info_doneRecognizeFaces = Localize(
        eng: "Done recognize faces from selected image.",
        chs: "完成对照片的人物识别"
    )
    
    
    
}
