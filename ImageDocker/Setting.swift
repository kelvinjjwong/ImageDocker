//
//  Setting.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/7.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

fileprivate var logger = LoggerFactory.get(category: "Setting")

struct Setting {
    
    static let UI = UserInterfaceSetting()
    static let logging = LoggingSetting()
    static let database = DatabaseSetting()
    static let performance = PerformanceSetting()
    static let mobileDeviceTransfer = MobileDeviceTransferSetting()
    static let externalApi = ExternalAPISetting()
    static let localEnvironment = LocalEnvironmentSetting()
    static let tools = ToolsSetting()
}

class ToolsSetting {
    
    fileprivate let setting_tools_path = "toolsPathKey"
    
    func toolsPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: setting_tools_path) else {return AppDelegate.current.toolsPath()}
        return txt
    }
    
    func saveToolsPath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: setting_tools_path)
    }
}

class LoggingSetting {
    
    // MARK: LOG
    
    fileprivate let logPathKey = "LogPathKey"
    
    
    
    func loggingDirectory() -> URL {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        let url = appSupportURL.appendingPathComponent("ImageDocker").appendingPathComponent("log")
        
        if !url.path.isDirectoryExists() {
            let (created, error) = url.path.mkdirs()
            if !created {
                logger.log(.error, "ERROR: Unable to create logging directory - \(error)")
                print("ERROR: Unable to create logging directory - \(error)")
            }
        }
        
        return url
    }
    
    func loggingFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
        let datePart = dateFormatter.string(from: Date())
        return "\(datePart).log"
    }
    
    
    func logPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: logPathKey) else {return loggingDirectory().path }
        return txt
    }
    
    fileprivate var _logFileFullPath = ""
    
    func logFileFullPath() -> String {
        if self._logFileFullPath == "" {
            self._logFileFullPath = "\(logPath())/\(loggingFilename())"
        }
        return self._logFileFullPath
    }
    
    func saveLogPath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: logPathKey)
    }
}

struct DatabaseSetting {
    
    let logger = LoggerFactory.get(category: "Setting", subCategory: "Database")
    
    fileprivate let databasePathKey = "DatabasePathKey"
    
    // MARK: SQLITE
    
    let predefinedLocalDBFilePath = AppDelegate.current.applicationDocumentsDirectory.path
    
    func databasePath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: databasePathKey) else {
            return predefinedLocalDBFilePath
        }
        if txt.isDirectoryExists() {
            return txt
        }else{
            return predefinedLocalDBFilePath
        }
    }
    
    func databasePath(filename: String) -> String {
        let url = URL(fileURLWithPath: databasePath()).appendingPathComponent(filename)
        return url.path
    }
    
    func saveDatabasePath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: databasePathKey)
    }
    
    // MARK: DATABASE
    
    fileprivate let databaseJsonKey = "DatabaseJsonKey"
    
    func databaseJson() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: databaseJsonKey) ?? ""
    }
    
    func saveDatabaseJson(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: databaseJsonKey)
    }
    
    func selectedDatabaseProfile() -> DatabaseProfile? {
        let json = databaseJson()
        let profiles = self.databaseProfilesFromJSON(json)
        if let selectedProfile = profiles.first(where: { p in
            return p.selected
        }) {
            return selectedProfile
        }
        return nil
    }
    
    func databaseProfilesFromJSON(_ jsonString:String) -> [DatabaseProfile]{
        let jsonDecoder = JSONDecoder()
        do{
            return try jsonDecoder.decode([DatabaseProfile].self, from: jsonString.data(using: .utf8)!)
        }catch{
            logger.log(.error, "[databaseProfilesFromJSON] \(error)")
            print(error)
            return []
        }
    }
    
    func checkSchemaVersion(profile:DatabaseProfile) -> String {
        final class Version : DatabaseRecord {
            var ver:Int? = nil
            public init() {}
        }
        do {
            if let version = try Version.fetchOne(Database(profile: profile), sql: """
SELECT max(NULLIF(regexp_replace(ver, '\\D','','g'), '')::int) AS ver from version_migrations
""") {
                if let ver = version.ver {
                    return "v\(ver)"
                }else{
                    return ""
                }
            }else{
                return ""
            }
        }catch{
            self.logger.log(.error, error)
            return "error_\(error)"
        }
    }
}

struct SQLiteDatabaseSetting {
    fileprivate let databasePathKey = "DatabasePathKey"
    
    // MARK: SQLITE
    
    let predefinedLocalDBFilePath = AppDelegate.current.applicationDocumentsDirectory.path
    
    func databasePath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: databasePathKey) else {
            return predefinedLocalDBFilePath
        }
        if txt.isDirectoryExists() {
            return txt
        }else{
            return predefinedLocalDBFilePath
        }
    }
    
    func databasePath(filename: String) -> String {
        let url = URL(fileURLWithPath: databasePath()).appendingPathComponent(filename)
        return url.path
    }
    
    func saveDatabasePath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: databasePathKey)
    }
    
}

struct PostgresDatabaseSetting {
    var hostKey:String, portKey:String, userKey:String, passwordKey:String, noPasswordKey:String, schemaKey:String, databaseKey:String
    
    // MARK: POSTGRES
    
    func server() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: hostKey) else {return "127.0.0.1"}
        return txt
    }
    
    
    func port() -> Int {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: portKey) else {return 5432}
        if let value = Int(txt) {
            return value
        }else{
            return 5432
        }
    }
    
    
    func username() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: userKey) else {return ""}
        return txt
    }
    
    
    func password() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: passwordKey) else {return ""}
        return txt
    }
    
    
    func schema() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: schemaKey) else {return "public"}
        return txt
    }
    
    
    func database() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: databaseKey) else {return ""}
        return txt
    }
    
    
    func noPassword() -> Bool {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: noPasswordKey) else {return true}
        if txt == "true"  {
            return true
        }else{
            return false
        }
    }
    
    func saveHost(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: hostKey)
    }
    
    func savePort(_ value:String) {
        let defaults = UserDefaults.standard
        if let _ = Int(value) {
            defaults.set(value, forKey: portKey)
        }else{
            defaults.set("5432", forKey: portKey)
        }
    }
    
    func saveUsername(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: userKey)
    }
    
    func savePassword(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: passwordKey)
    }
    
    func saveSchema(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: schemaKey)
    }
    
    func saveDatabase(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: databaseKey)
    }
    
    func saveNoPassword(_ value:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(value ? "true" : "false", forKey: noPasswordKey)
    }
    
}

struct UserInterfaceSetting {
    
    fileprivate let languageKey = "LanguageKey"
    
    // MARK: LANGUAGE
    
    func language() -> String {
        let defaults = UserDefaults.standard
        let value = defaults.string(forKey: languageKey) ?? "eng"
        return value
    }
    
    func saveLanguage(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey:languageKey)
    }
    
}

struct PerformanceSetting {
    
    fileprivate let memoryPeakKey = "memoryPeakKey"
    fileprivate let amountForPaginationKey = "amountForPaginationKey"
    
    // MARK: PERFORMANCE
    
    func amountForPagination() -> Int {
        let defaults = UserDefaults.standard
        let value = defaults.integer(forKey: amountForPaginationKey)
        return value
    }
    
    func peakMemory() -> Int {
        
        let totalRam = ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024
        let max = Int(totalRam)
        let mid = Int(totalRam / 2)
        let defaults = UserDefaults.standard
        let value = defaults.integer(forKey: memoryPeakKey)
        if value > max {
            return mid
        }
        return value
    }
    
    func saveAmountForPagination(_ value:String) {
        var paginationAmount = 0
        if value != Words.preference_tab_performance_pagination_unlimited.word() {
            paginationAmount = Int(value) ?? 0
        }
        let defaults = UserDefaults.standard
        defaults.set(paginationAmount, forKey: amountForPaginationKey)
    }
    
    func savePeakMemory(_ value:Int) {
        let defaults = UserDefaults.standard
        defaults.set(Int(value), forKey: memoryPeakKey)
    }
    
}

struct MobileDeviceTransferSetting {
    
    fileprivate let exportToAndroidPathKey = "ExportToAndroidPath"
    
    func exportToAndroidDirectory() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: exportToAndroidPathKey) else {return ""}
        return txt
    }
    
    func saveExportToAndroidDirectory(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: exportToAndroidPathKey)
    }
    
}

struct LocalEnvironmentSetting {
    
    // MARK: LOCAL DISK
    fileprivate let setting_localdisk_mount_points = "localDiskMountPointsKey"
    
    func localDiskMountPoints() -> [String] {
        var list:[String] = []
        let defaults = UserDefaults.standard
        let txt = defaults.string(forKey: setting_localdisk_mount_points) ?? "[]"
        
        for jsonObject in txt.toJSONArray() {
            list.append(jsonObject.rawString() ?? "")
        }
        return list
    }
    
    func saveLocalDiskMountPoints(_ values:[String]) {
        let defaults = UserDefaults.standard
        defaults.set(values.toJSONString(), forKey: setting_localdisk_mount_points)
    }
    
    // MARK: MOBILE DEVICE
    fileprivate let setting_android_adb_path = "adbPathKey"
    fileprivate let setting_ios_mount_point = "IOSMountPointKey"
    fileprivate let setting_ios_ifuse_path = "ifuseKey"
    fileprivate let setting_ios_ideviceid_path = "ideviceidKey"
    fileprivate let setting_ios_ideviceinfo_path = "ideviceinfoKey"
    
    
    // MARK: ANDROID
    
    func adbPath() -> String {
        var adbInBundle = ""
        if let bundle = Bundle.main.url(forResource: "Mobile", withExtension: nil) {
            adbInBundle = bundle.appendingPathComponent("adb").path
        }
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: setting_android_adb_path) else {return adbInBundle}
        return txt
    }
    
    func saveAdbPath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: setting_android_adb_path)
    }
    
    // MARK: IPHONE
    
    func iosDeviceMountPoint() -> String {
        let defaults = UserDefaults.standard
        let txt = defaults.string(forKey: setting_ios_mount_point) ?? "/MacStorage/mount/iPhone/"
        if txt.isDirectoryExists() {
            return txt
        }else{
            return ""
        }
    }
    
    func saveIOSMountPoint(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: setting_ios_mount_point)
    }
    
    func ideviceidPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: setting_ios_ideviceid_path) else {return ""}
        return txt
    }
    
    func saveIdeviceIdPath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: setting_ios_ideviceid_path)
    }
    
    func ideviceinfoPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: setting_ios_ideviceinfo_path) else {return ""}
        return txt
    }
    
    func saveIdeviceInfoPath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: setting_ios_ideviceinfo_path)
    }
    
    func ifusePath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: setting_ios_ifuse_path) else {return ""}
        return txt
    }
    
    func saveIfusePath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: setting_ios_ifuse_path)
    }
    
    // MARK: EXIFTOOL
    fileprivate let setting_exiftool_path = "exiftoolPathKey"
    
    func exiftoolPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: setting_exiftool_path) else {return ""}
        return txt
    }
    
    func saveExifToolPath(_ value:String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: setting_exiftool_path)
    }
}

struct ExternalAPISetting {
    
    
    // MARK: GEOLOCATION API
    fileprivate let baiduAKKey = "BaiduAKKey"
    fileprivate let baiduSKKey = "BaiduSKKey"
    fileprivate let googleAKKey = "GoogleAPIKey"
    
    func baiduAK() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: baiduAKKey) else {return ""}
        return txt
    }
    
    func baiduSK() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: baiduSKKey) else {return ""}
        return txt
    }
    
    func googleAPIKey() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: googleAKKey) else {return ""}
        return txt
    }
    
    func saveBaiduAK(_ value:String) {
        let defaults = UserDefaults.standard
        
        defaults.set(value, forKey:baiduAKKey)
    }
    
    func saveBaiduSK(_ value:String) {
        let defaults = UserDefaults.standard
        
        defaults.set(value, forKey:baiduSKKey)
    }
    
    func saveGoogleAK(_ value:String) {
        let defaults = UserDefaults.standard
        
        defaults.set(value, forKey:googleAKKey)
    }
}
