//
//  Words+PreviewImage.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/30.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

extension Words {
    
    
    static let imageOption = Localize(
        eng: "More Ops",
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
        chs: "在 Finder 检视可修改版本的文件"
    )
    
    static let findBackupVersionFromFinder = Localize(
        eng: "Find backup version from Finder",
        chs: "在 Finder 检视原始版本的文件"
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
    
    static let rescanImageExif = Localize(
        eng: "Scan image EXIF again",
        chs: "再次扫描照片的元数据"
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
    
    static let double_click_to_copy_value = Localize(
        eng: "Double click to copy value",
        chs: "双击以取值"
    )
    
    static let copied_meta_value_to_pasteboard = Localize(
        eng: "Copied image's meta value to pasteboard.",
        chs: "已将照片的资讯复制到剪贴板"
    )
    
    static let n_images = Localize(
        eng: "%s images",
        chs: "%s 张照片"
    )
    
    static let _meta:[String:Localize] = [
        "System"     : Localize(eng: "System", chs: "系统"),
        "Location"   : Localize(eng: "Location", chs: "地理位置"),
        "DateTime"   : Localize(eng: "DateTime", chs: "日期"),
        "Camera"     : Localize(eng: "Camera", chs: "相机"),
        "Coordinate" : Localize(eng: "Coordinate", chs: "地理坐标"),
        "Software"   : Localize(eng: "Software", chs: "处理软件"),
        "Repository" : Localize(eng: "Repository", chs: "照片库"),
        "Device"     : Localize(eng: "Device", chs: "外部设备"),
        "Event"      : Localize(eng: "Event", chs: "活动"),
        "Video"      : Localize(eng: "Video", chs: "影片"),
        "Audio"      : Localize(eng: "Audio", chs: "音轨"),
        "Original"   : Localize(eng: "Original", chs: "初始数值"),
        "Assigned"   : Localize(eng: "Assigned", chs: "指定"),
        "File"       : Localize(eng: "File", chs: "文件"),
        "Baidu"      : Localize(eng: "Baidu", chs: "百度地图"),
        "Name"       : Localize(eng: "Name", chs: "名称"),
        "Type"       : Localize(eng: "Type", chs: "类型"),
        "Country"    : Localize(eng: "Country", chs: "国家"),
        "Province"   : Localize(eng: "Province", chs: "省份/州"),
        "City"       : Localize(eng: "City", chs: "城市"),
        "District"   : Localize(eng: "District", chs: "区"),
        "Street"     : Localize(eng: "Street", chs: "街道"),
        "BusinessCircle" : Localize(eng: "BusinessCircle", chs: "商业圈"),
        "Address"    : Localize(eng: "Address", chs: "地址"),
        "Description": Localize(eng: "Description", chs: "描述"),
        "Suggest Place": Localize(eng: "Suggest Place", chs: "地标"),
        "Format"     : Localize(eng: "Format", chs: "格式"),
        "Manufacture": Localize(eng: "Manufacture", chs: "厂商"),
        "Model"      : Localize(eng: "Model", chs: "型号"),
        "Source"     : Localize(eng: "Source", chs: "来源"),
        "Size"       : Localize(eng: "Size", chs: "尺寸"),
        "Frame Rate" : Localize(eng: "Frame Rate", chs: "码流率"),
        "Image Width": Localize(eng: "Image Width", chs: "画面宽度"),
        "Image Height": Localize(eng: "Image Height", chs: "画面高度"),
        "Duration"   : Localize(eng: "Duration", chs: "持续时间"),
        "Avg Bitrate": Localize(eng: "Avg Bitrate", chs: "平均码流率"),
        "Rotation"   : Localize(eng: "Rotation", chs: "画面方向偏转角度"),
        "Channels"   : Localize(eng: "Channels", chs: "通道数"),
        "BitsPerSample": Localize(eng: "BitsPerSample", chs: "采样位数"),
        "SampleRate" : Localize(eng: "SampleRate", chs: "采样码流率"),
        "ExposureTime": Localize(eng: "ExposureTime", chs: "曝光时间"),
        "Aperture"   : Localize(eng: "Aperture", chs: "光圈"),
        "SubPath"    : Localize(eng: "SubPath", chs: "相对路径"),
        "Filename"   : Localize(eng: "Filename", chs: "文件名"),
        "Full path"  : Localize(eng: "Container Path", chs: "文件夹路径"),
        "Latitude (WGS84)" : Localize(eng: "Latitude (WGS84)", chs: "纬度 (WGS84)"),
        "Longitude (WGS84)" : Localize(eng: "Longitude (WGS84)", chs: "经度 (WGS84)"),
        "Latitude (BD09)" : Localize(eng: "Latitude (BD09)", chs: "纬度 (BD09)"),
        "Longitude (BD09)" : Localize(eng: "Longitude (BD09)", chs: "经度 (BD09)"),
        "DateTimeOriginal" : Localize(eng: "DateTimeOriginal", chs: "原始日期"),
        "FileCreateDate" : Localize(eng: "FileCreateDate", chs: "文件创建日期"),
        "FileModifyDate" : Localize(eng: "FileModifyDate", chs: "文件最后修改日期"),
        "From Filename" : Localize(eng: "From Filename", chs: "文件名里包含的日期"),
        "FileSysCreateDate" : Localize(eng: "FileSysCreateDate", chs: "文件系统创建日期"),
        "Software Modified" : Localize(eng: "Software Modified", chs: "照片软件修改日期"),
        "GPS Date" : Localize(eng: "GPS Date", chs: "卫星导航系统日期"),
        "VideoCreateDate" : Localize(eng: "VideoCreateDate", chs: "影片创建日期"),
        "VideoModifyDate" : Localize(eng: "VideoModifyDate", chs: "影片最后修改日期"),
        "TrackCreateDate" : Localize(eng: "TrackCreateDate", chs: "轨道创建日期"),
        "TrackModifyDate" : Localize(eng: "TrackModifyDate", chs: "轨道最后修改日期")
    ]
    
    static func meta(_ key:String) -> Localize {
        if let m = _meta[key] {
            return m
        }else{
            return Localize(eng: key, chs: key)
        }
    }
    
//    static let info_doneFindingFaces = Localize(
//        eng: "Done find faces from selected image.",
//        chs: "完成对照片的人物扫描"
//    )
    
//    static let info_doneRecognizeFaces = Localize(
//        eng: "Done recognize faces from selected image.",
//        chs: "完成对照片的人物识别"
//    )
}
