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
    
//    static let info_doneFindingFaces = Localize(
//        eng: "Done find faces from selected image.",
//        chs: "完成对照片的人物扫描"
//    )
    
//    static let info_doneRecognizeFaces = Localize(
//        eng: "Done recognize faces from selected image.",
//        chs: "完成对照片的人物识别"
//    )
}
