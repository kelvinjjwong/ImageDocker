//
//  Words+Preferences.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2022/11/2.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Foundation

extension Words {
    
    static let preference_dialog_title = Localize(
        eng: "Preference",
        chs: "偏好配置"
    )
    
    static let preference_tab_general = Localize(
        eng: "General",
        chs: "通用"
    )
    
    static let preference_tab_general_ui_language = Localize(
        eng: "User interface language:",
        chs: "用户界面语言:"
    )
    
    static let preference_tab_performance = Localize(
        eng: "Performance",
        chs: "性能"
    )
    
    static let preference_tab_performance_box_memory_limit = Localize(
        eng: "System Memory Limit",
        chs: "系统内存限制"
    )
    
    static let preference_tab_performance_box_memory_limit_prompt = Localize(
        eng: "When system memory usage of this application exceeds the peak you selected above, ongoing task will pause for a short while to free up memory and then resume.",
        chs: "当内存使用超过你选择的上限时，正在执行的任务会暂停一会儿以便释放内存，然后继续执行任务。"
    )
    
    static let preference_tab_performance_box_pagination = Localize(
        eng: "Pagination",
        chs: "分页"
    )
    
    static let preference_tab_performance_box_pagination_prompt_left = Localize(
        eng: "When amount of items larger than",
        chs: "用网格浏览照片时，照片总数大于"
    )
    
    static let preference_tab_performance_box_pagination_prompt_right = Localize(
        eng: ", items will be paginated in collection view.",
        chs: "时，会分页展示照片"
    )
    
    static let preference_tab_performance_selected_memory = Localize(
        eng: "Selected %s GB as Peak",
        chs: "选择了限制内存峰值 %s GB"
    )
    
    static let preference_tab_performance_selected_memory_unlimited = Localize(
        eng: "Selected Unlimited",
        chs: "选择了内存不设上限"
    )
    
    static let preference_tab_performance_slide_unlimited = Localize(
        eng: "0 (Unlimited)",
        chs: "0 (不设上限)"
    )
    
    static let preference_tab_performance_pagination_unlimited = Localize(
        eng: "Unlimited",
        chs: "不设上限"
    )
    
    static let preference_tab_database = Localize(
        eng: "Database",
        chs: "数据库"
    )
    
    static let preference_tab_database_box_local_sqlite = Localize(
        eng: "Local Database (SQLite)",
        chs: "本地数据库 (SQLite)"
    )
    
    static let preference_tab_database_box_local_postgres = Localize(
        eng: "Local Database (PostgreSQL)",
        chs: "本地数据库 (PostgreSQL)"
    )
    
    static let preference_tab_database_box_remote_postgres = Localize(
        eng: "Network Shared Database (PostgreSQL)",
        chs: "局域网的数据库 (PostgreSQL)"
    )
    
    static let preference_tab_database_sqlite_location = Localize(
        eng: "Database File Location",
        chs: "数据库文件位置:"
    )
    
    static let preference_tab_database_postgre_server = Localize(
        eng: "Server:",
        chs: "服务器:"
    )
    
    static let preference_tab_database_postgre_port = Localize(
        eng: "Port:",
        chs: "端口:"
    )
    
    static let preference_tab_database_postgre_user = Localize(
        eng: "Username:",
        chs: "用户名:"
    )
    
    static let preference_tab_database_postgre_password = Localize(
        eng: "Password:",
        chs: "密码:"
    )
    
    static let preference_tab_database_postgre_no_password = Localize(
        eng: "No Password",
        chs: "不需要密码"
    )
    
    static let preference_tab_database_postgre_schema = Localize(
        eng: "Schema:",
        chs: "结构集:"
    )
    
    static let preference_tab_database_postgre_database = Localize(
        eng: "Database:",
        chs: "库名:"
    )
    
    static let preference_tab_database_test_connect = Localize(
        eng: "Test Schema",
        chs: "测试连接"
    )
    
    static let preference_tab_database_backup_now = Localize(
        eng: "Backup Now",
        chs: "立即备份"
    )
    
    static let preference_tab_database_browse = Localize(
        eng: "Browse...",
        chs: "选择 ..."
    )
    
    static let preference_tab_database_goto = Localize(
        eng: "Goto",
        chs: "打开"
    )
    
    static let preference_tab_backup = Localize(
        eng: "Backup",
        chs: "备份"
    )
    
    static let preference_tab_backup_box_backup = Localize(
        eng: "Backup",
        chs: "数据库备份"
    )
    
    static let preference_tab_backup_box_data_clone = Localize(
        eng: "Data Clone",
        chs: "复制结构和数据"
    )
    
    static let preference_tab_backup_box_backup_location = Localize(
        eng: "Location: ",
        chs: "备份文件夹: "
    )
    
    static let preference_tab_backup_from = Localize(
        eng: "FROM",
        chs: "从"
    )
    
    static let preference_tab_backup_to = Localize(
        eng: "TO",
        chs: "到"
    )
    
    static let preference_tab_backup_delete_original_data = Localize(
        eng: "Delete all original data",
        chs: "复制前删除目标现有数据"
    )
    
    static let preference_tab_backup_clone_now = Localize(
        eng: "Clone Now",
        chs: "立即复制"
    )
    
    static let preference_tab_backup_create_db = Localize(
        eng: "Create DB",
        chs: "新建数据库"
    )
    
    static let preference_tab_backup_to_database = Localize(
        eng: "To database:",
        chs: "目标数据库名:"
    )
    
    static let preference_tab_backup_pg_cmdline = Localize(
        eng: "PostgreSQL command path:",
        chs: "PostgreSQL 命令所在目录路径:"
    )
    
    static let preference_tab_backup_calc_disk_space = Localize(
        eng: "Calculate Disk Space",
        chs: "计算磁盘剩余空间"
    )
    
    static let preference_tab_backup_local_sqlite = Localize(
        eng: "Local SQLite",
        chs: "本地 SQLite"
    )
    
    static let preference_tab_backup_local_postgresql = Localize(
        eng: "Local PostgreSQL",
        chs: "本地 PostgreSQL"
    )
    
    static let preference_tab_backup_remote_postgresql = Localize(
        eng: "Remote PostgreSQL",
        chs: "局域网的 PostgreSQL"
    )
    
    static let preference_tab_backup_restore_from_backup = Localize(
        eng: "Restore from backup",
        chs: "从备份文件恢复:"
    )
    
    static let preference_tab_backup_delete_backup = Localize(
        eng: "Delete",
        chs: "删除备份"
    )
    
    static let preference_tab_backup_reload_backup = Localize(
        eng: "Reload",
        chs: "刷新列表"
    )
    
    static let preference_tab_backup_installed_by_homebrew = Localize(
        eng: "Installed by Homebrew",
        chs: "已由 Homebrew 安装"
    )
    
    static let preference_tab_backup_installed_by_postgresapp = Localize(
        eng: "Installed PostgresApp",
        chs: "已由 PostgresApp 安装"
    )
    
    static let preference_tab_backup_installed_error = Localize(
        eng: "ERROR: Unable to find PostgreSQL from either Homebrew or PostgresApp. Please install first.",
        chs: "出错了: 找不到 PostgreSQL 命令，无论在 Homebrew 还是在 PostgresApp 的安装位置。请先安装一个。"
    )
    
    static let preference_tab_backup_installed_by_homebrew_error = Localize(
        eng: "ERROR: Unable to find PostgreSQL from Homebrew %s",
        chs: "出错了: 找不到 PostgreSQL 命令，在 Homebrew 安装位置 %s"
    )
    
    static let preference_tab_backup_installed_by_postgresapp_error = Localize(
        eng: "ERROR: Unable to find PostgreSQL from PostgresApp %s",
        chs: "出错了: 找不到 PostgreSQL 命令，在 PostgresApp 安装位置 %s"
    )
    
    static let preference_tab_backup_created_database = Localize(
        eng: "Created.",
        chs: "已创建."
    )
    
    static let preference_tab_backup_not_exist_database = Localize(
        eng: "Not Exist.",
        chs: "数据库不存在."
    )
    
    static let preference_tab_backup_empty_database = Localize(
        eng: "Empty DB.",
        chs: "空白数据库."
    )
    
    static let preference_tab_backup_non_empty_database = Localize(
        eng: "Non-Empty DB.",
        chs: "不是空白数据库."
    )
    
    static let preference_tab_backup_create_database_failed = Localize(
        eng: "Failed createdb.",
        chs: "创建数据库失败."
    )
    
    static let preference_tab_backup_restoring_archive_to_local_postgres = Localize(
        eng: "Restoring archive [%s] to local postgres database [%s] ...",
        chs: "正在从备份 [%s] 恢复到本地的 PostgreSQL 数据库 [%s] ..."
    )
    
    static let preference_tab_backup_restoring_archive_to_remote_postgres = Localize(
        eng: "Restoring archive [%s] to remote postgres database [%s] ...",
        chs: "正在从备份 [%s] 恢复到局域网的的 PostgreSQL 数据库 [%s] ..."
    )
    
    static let preference_tab_backup_restore_archive_completed = Localize(
        eng: "Restore archive [%s] to [%s] completed.",
        chs: "已完成从备份 [%s] 恢复到数据库 [%s]."
    )
    
    static let preference_tab_data_clone_from_sqlite_to_local_postgres = Localize(
        eng: "Clone from SQLite to local postgres database ...",
        chs: "正在从本地 SQLite 复制到本地 PostgreSQL 数据库 ..."
    )
    
    static let preference_tab_data_clone_from_sqlite_to_remote_postgres = Localize(
        eng: "Clone from SQLite to remote postgres database ...",
        chs: "正在从本地 SQLite 复制到局域网的 PostgreSQL 数据库 ..."
    )
    
    static let preference_tab_data_clone_from_local_postgres_to_local_postgres = Localize(
        eng: "Clone from local postgres to local postgres database ...",
        chs: "正在从本地 PostgreSQL 复制到本地 PostgreSQL 数据库 ..."
    )
    
    static let preference_tab_data_clone_from_local_postgres_to_remote_postgres = Localize(
        eng: "Clone from local postgres to remote postgres database ...",
        chs: "正在从本地 PostgreSQL 复制到局域网的 PostgreSQL 数据库 ..."
    )
    
    static let preference_tab_data_clone_from_remote_postgres_to_local_postgres = Localize(
        eng: "Clone from remote postgres to local postgres database ...",
        chs: "正在从局域网的 PostgreSQL 复制到本地 PostgreSQL 数据库 ..."
    )
    
    static let preference_tab_data_clone_from_remote_postgres_to_remote_postgres = Localize(
        eng: "Clone from remote postgres to remote postgres database ...",
        chs: "正在从局域网的 PostgreSQL 复制到局域网的 PostgreSQL 数据库 ..."
    )
    
    static let preference_tab_data_clone_completed = Localize(
        eng: "Database clone completed.",
        chs: "数据库复制完成."
    )
    
    static let preference_tab_data_clone_from_local_postgres_completed = Localize(
        eng: "Clone from local postgres to [%s] completed.",
        chs: "从本地 PostgreSQL 数据库 [%s] 复制完成."
    )
    
    static let preference_tab_data_clone_from_remote_postgres_completed = Localize(
        eng: "Clone from remote postgres to [%s] completed.",
        chs: "从局域网的 PostgreSQL 数据库 [%s] 复制完成."
    )
    
    static let preference_tab_missing_error = Localize(
        eng: "ERROR: Missing %s",
        chs: "出错了: 找不到 %s"
    )
    
    static let preference_tab_backup_used_space = Localize(
        eng: "Used: %s GB , Free: %s",
        chs: "使用了: %s GB , 空闲: %s"
    )
    
    static let preference_tab_backup_no_schema = Localize(
        eng: "No schema",
        chs: "没有结构集"
    )
    
    static let preference_tab_data_clone_one_row_should_be_selected = Localize(
        eng: "One row should be selected in archive table",
        chs: "至少从备份列表选择一行"
    )
    
    static let preference_tab_data_clone_unable_to_locate_psql_command = Localize(
        eng: "Unable to locate psql command in macOS, restore aborted.",
        chs: "找不到 psql 命令，无法恢复数据库。"
    )
    
    static let preference_tab_data_clone_empty_database_name = Localize(
        eng: "Error: empty.",
        chs: "出错了: 没有库名"
    )
    
    static let preference_tab_data_clone_check_target_database_exist_empty = Localize(
        eng: "Please check if target database exists and empty first",
        chs: "出错了: 请检查目标数据库是否存在并已清空。"
    )
    
    static let preference_tab_creating_backup = Localize(
        eng: "Creating backup ...",
        chs: "正在备份数据库 ..."
    )
    
    static let preference_tab_backup_created = Localize(
        eng: "Created %s",
        chs: "备份了数据库 %s"
    )
    
    static let preference_tab_backup_failed = Localize(
        eng: "Backup failed: %s",
        chs: "备份了出错了: %s"
    )
    
    static let preference_tab_mobile = Localize(
        eng: "Mobile Device",
        chs: "移动设备"
    )
    
    static let preference_tab_mobile_box_android = Localize(
        eng: "Android Device",
        chs: "安卓设备"
    )
    
    static let preference_tab_mobile_box_ios = Localize(
        eng: "iOS Device",
        chs: "苹果设备"
    )
    
    static let preference_tab_mobile_box_android_path = Localize(
        eng: "Default Path for Image Upload",
        chs: "照片上传到设备上的这个文件夹"
    )
    
    static let preference_tab_mobile_box_android_prompt = Localize(
        eng: "If you do not want to upload image(s) back to their original location of original phone, images would be uploaded to this path.",
        chs: "如果你不希望将照片上传到安卓设备上它们原本的文件夹路径（ImageDocker从那里将照片下载到本地磁盘），照片会被上传到安卓设备上的这个替代文件夹路径。"
    )
    
    static let preference_tab_mobile_box_ios_mount_point = Localize(
        eng: "Mount Point",
        chs: "挂载点的本地磁盘路径"
    )
    
    static let preference_tab_mobile_box_ios_browse = Localize(
        eng: "Browse",
        chs: "选择..."
    )
    
    static let preference_tab_mobile_box_ios_locate = Localize(
        eng: "Locate",
        chs: "打开文件夹"
    )
    
    static let preference_tab_face_recognition = Localize(
        eng: "Face Recognition",
        chs: "人脸识别"
    )
    
    static let preference_tab_face_recognition_api = Localize(
        eng: "Face Recognition API",
        chs: "人脸识别 API"
    )
    
    static let preference_tab_geo_location_api = Localize(
        eng: "Geo Location API",
        chs: "地理位置 API"
    )
    
    static let preference_tab_geo_location_api_box_baidu = Localize(
        eng: "Baidu Map",
        chs: "百度地图"
    )
    
    static let preference_tab_geo_location_api_prompt = Localize(
        eng: "You need to register account for getting the keys above: ",
        chs: "你需要到这个网站注册账户并取得上述密钥: "
    )
    
    static let preference_tab_geo_location_api_box_google = Localize(
        eng: "Google Map",
        chs: "谷歌地图"
    )
    
    
    
    static let database_backup_dialog_title = Localize(
        eng: "Database and Backup",
        chs: "数据库配置和备份"
    )
}
