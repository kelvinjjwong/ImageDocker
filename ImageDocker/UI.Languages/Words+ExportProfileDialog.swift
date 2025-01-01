//
//  Words+ExportProfileDialog.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/30.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

extension Words {
    
    
    static let export_auto_profile = Localize (
        eng: "Auto Profile - %s",
        chs: "新的配置 %s"
    )
    
    static let export_profile_include = Localize (
        eng: "include",
        chs: "包含"
    )
    
    static let export_profile_exclude = Localize (
        eng: "exclude",
        chs: "排除"
    )
    
    static let export_profile_edit_profile = Localize (
        eng: "Edit Profile",
        chs: "编辑预设组合"
    )
    
    static let export_profile_name_and_path = Localize (
        eng: "General",
        chs: "概要"
    )
    
    static let export_profile_action = Localize (
        eng: "Action",
        chs: "行动"
    )
    
    static let export_profile_has_limit = Localize (
        eng: "Limit",
        chs: "限制"
    )
    
    static let export_profile_name = Localize (
        eng: "Name:",
        chs: "名称:"
    )
    
    static let export_profile_to_directory = Localize (
        eng: "To directory:",
        chs: "导出到:"
    )
    
    static let export_profile_repositories = Localize (
        eng: "Repositories:",
        chs: "照片库:"
    )
    
    static let export_profile_event_categories = Localize (
        eng: "Events Categories:",
        chs: "活动分类:"
    )
    
    static let export_profile_events = Localize (
        eng: "Events:",
        chs: "活动:"
    )
    
    static let export_profile_people = Localize (
        eng: "People:",
        chs: "照片中的人:"
    )
    
    static let export_profile_families = Localize (
        eng: "Families:",
        chs: "亲友或组织:"
    )
    
    static let export_profile_file_naming = Localize (
        eng: "File Naming",
        chs: "文件命名规则"
    )
    
    static let export_profile_file_naming_keep_origin = Localize (
        eng: "Keep origin",
        chs: "同原本的文件名一致"
    )
    
    static let export_profile_file_naming_date_time = Localize (
        eng: "Date & Time",
        chs: "拍摄日期、时间"
    )
    
    static let export_profile_file_naming_date_time_brief = Localize (
        eng: "Date & Time & Brief Note",
        chs: "拍摄日期、时间、注释"
    )
    
    static let export_profile_file_naming_options = OptionLocalize()
        .add(option: "ORIGIN", word: export_profile_file_naming_keep_origin)
        .add(option: "DATETIME", word: export_profile_file_naming_date_time)
        .add(option: "DATETIME_BRIEF", word: export_profile_file_naming_date_time_brief)
    
    static let export_profile_exif_patching = Localize (
        eng: "EXIF Patching",
        chs: "EXIF 信息变更"
    )
    
    static let export_profile_exif_patching_image_description = Localize (
        eng: "Image description",
        chs: "添加注释"
    )
    
    static let export_profile_exif_patching_geolocation = Localize (
        eng: "Geolocation",
        chs: "变更地理位置"
    )
    
    static let export_profile_exif_patching_photo_taken_date_time = Localize (
        eng: "Photo taken date & time",
        chs: "变更拍摄日期、时间"
    )
    
    static let export_profile_exif_patching_options = OptionLocalize(allowMultiSelection: true)
        .add(option: "DESCRIPTION", word: export_profile_exif_patching_image_description)
        .add(option: "DATETIME", word: export_profile_exif_patching_photo_taken_date_time)
        .add(option: "GEOLOCATION", word: export_profile_exif_patching_photo_taken_date_time)
    
    static let export_profile_when_filename_is_duplicated = Localize (
        eng: "When filename is duplicated",
        chs: "重名文件处理规则"
    )
    
    static let export_profile_when_filename_is_duplicated_overwrite = Localize (
        eng: "Overwrite",
        chs: "用新文件覆盖"
    )
    
    static let export_profile_when_filename_is_duplicated_use_device_name_as_suffix = Localize (
        eng: "Use device name as suffix",
        chs: "在文件名后面添加设备名称"
    )
    
    static let export_profile_when_filename_is_duplicated_use_device_model_as_suffix = Localize (
        eng: "Use device model as suffix",
        chs: "在文件名后面添加设备型号"
    )
    
    static let export_profile_when_filename_is_duplicated_use_number_as_suffix = Localize (
        eng: "Use number as suffix",
        chs: "在文件名后面添加顺序数字"
    )
    
    static let export_profile_when_filename_is_duplicated_options = OptionLocalize()
        .add(option: "OVERWRITE", word: export_profile_when_filename_is_duplicated_overwrite)
        .add(option: "DEVICE_NAME", word: export_profile_when_filename_is_duplicated_use_device_name_as_suffix)
        .add(option: "DEVICE_MODEL", word: export_profile_when_filename_is_duplicated_use_device_model_as_suffix)
        .add(option: "NUMBER", word: export_profile_when_filename_is_duplicated_use_number_as_suffix)
    
    static let export_profile_sub_folder = Localize (
        eng: "Sub Folder",
        chs: "文件夹命名规则"
    )
    
    static let export_profile_sub_folder_no_subfolder = Localize (
        eng: "No sub-folder",
        chs: "不使用文件夹存储文件"
    )
    
    static let export_profile_sub_folder_year_month_event = Localize (
        eng: "YEAR / MONTH (EVENT) /",
        chs: "年份 / 月份 (活动名称) /"
    )
    
    static let export_profile_sub_folder_year_month_day = Localize (
        eng: "YEAR / MONTH / DAY",
        chs: "年 / 月 / 日 /"
    )
    
    static let export_profile_sub_folder_event = Localize (
        eng: "EVENT /",
        chs: "活动名称 /"
    )
    
    static let export_profile_sub_folder_export_date_time = Localize (
        eng: "Export Date & Time /",
        chs: "导出时的日期和时间 /"
    )
    
    static let export_profile_sub_folder_options = OptionLocalize()
        .add(option: "NONE", word: export_profile_sub_folder_no_subfolder)
        .add(option: "DATE_EVENT", word: export_profile_sub_folder_year_month_event)
        .add(option: "EVENT", word: export_profile_sub_folder_event)
        .add(option: "EXPORT_TIME", word: export_profile_sub_folder_export_date_time)
    
    
    static let export_profile_save = Localize (
        eng: "Save",
        chs: "保存"
    )
    
    static let export_profile_clean_fields = Localize (
        eng: "Clean Fields",
        chs: "清除已填已选"
    )
    
    static let export_profile_assign_to_directory = Localize (
        eng: "Assign",
        chs: "指定..."
    )
    
    static let export_profile_goto_to_directory = Localize (
        eng: "Goto",
        chs: "打开"
    )
    
    static let export_profile_calculate_images = Localize (
        eng: "Calculate Images",
        chs: "统计包含的影像数目"
    )
    
    static let export_profile_copy_sql_to_clipboard = Localize (
        eng: "SQL",
        chs: "SQL"
    )
    
    static let export_profile_export = Localize (
        eng: "Export",
        chs: "执行导出"
    )
    
    static let export_profile_rehearsal_export = Localize (
        eng: "Export",
        chs: "演练导出"
    )
    
    static let export_profile_rehearsal = Localize (
        eng: "Rehearsal",
        chs: "演练"
    )
    
    static let export_profile_rehearsal_n_images = Localize (
        eng: "Rehearsal %s images",
        chs: "演练 %s 张照片"
    )
    
    static let export_profile_rehearsal_all_images = Localize (
        eng: "ALL images",
        chs: "演练所有包含的照片"
    )
    
    static let export_profile_item = Localize (
        eng: "Profile",
        chs: "预设组合"
    )
    
    static let export_profile_item_from_repository = Localize (
        eng: "From repository:",
        chs: "照片库:"
    )
    
    static let export_profile_item_sub_folder = Localize (
        eng: "Sub Folder:",
        chs: "文件夹命名:"
    )
    
    static let export_profile_item_file_naming = Localize (
        eng: "File Naming:",
        chs: "文件命名规则:"
    )
    
    static let export_profile_item_duplicated_filename_strategy = Localize (
        eng: "Duplication:",
        chs: "重名文件处理规则:"
    )
    
    static let export_profile_item_exif_patching = Localize (
        eng: "EXIF Patching:",
        chs: "EXIF 信息变更:"
    )
    
    static let export_profile_item_any = Localize (
        eng: "any",
        chs: "全部"
    )
    
    static let export_profile_item_any_people = Localize (
        eng: "Any people",
        chs: "全部人"
    )
    
    static let export_profile_item_any_event = Localize (
        eng: "Any event",
        chs: "全部活动"
    )
    
    static let export_profile_item_any_event_category = Localize (
        eng: "Any event category",
        chs: "全部活动分类"
    )
    
    static let export_profile_item_none = Localize (
        eng: "no limitation",
        chs: "没有"
    )
    
    static let export_profile_item_no_limit = Localize (
        eng: "no limitation",
        chs: "没有限制"
    )
    
    static let export_profile_item_any_family = Localize (
        eng: "Any family",
        chs: "全部家庭和组织"
    )
    
    static let export_profile_item_edit = Localize (
        eng: "Edit",
        chs: "选择"
    )
    
    static let export_profile_item_delete = Localize (
        eng: "Delete",
        chs: "删除"
    )
    
    static let export_profile_item_export = Localize (
        eng: "Export",
        chs: "导出"
    )
    
    static let export_profile_item_stop = Localize (
        eng: "STOP",
        chs: "中止"
    )
}
