//
//  LoggerSetting.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/28.
//  Copyright © 2026 nonamecat. All rights reserved.
//
import Cocoa
import LoggerFactory

public protocol LogSettingFinder {
    
    func shouldLog(logtype: LogType, category:String, subCategory:String, writerId:String) -> Bool
}

public class LoggerSetting2 : LogSettingFinder {
    
    public static let `default` = LoggerSetting2()
    
    private let dtFormatter = ISO8601DateFormatter()
    
    var profiles:[LoggerProfile] = []
    
    public func loadSettings() {
        let defaults = UserDefaults.standard
        let json_string = defaults.string(forKey: "LOGGER_SETTINGS") ?? ""
        print("👀 \(self.dtFormatter.string(from: Date())) 👀👀👀 load logger profiles 👀👀👀 ")
        print(json_string)
        print("👀 \(self.dtFormatter.string(from: Date())) 👀👀👀")
        let profiles = self.loggerProfilesFromJSON(json_string)
        print("👀 \(self.dtFormatter.string(from: Date())) 👀👀👀 extracted \(profiles.count) logger profiles 👀👀👀 ")
        for profile in profiles {
            self.addSetting(profile: profile)
        }
        print("👀 \(self.dtFormatter.string(from: Date())) 👀👀👀")
        
    }
    
    public func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(self.loggerProfilesToJSON(), forKey: "LOGGER_SETTINGS")
        print("👀 \(self.dtFormatter.string(from: Date())) 👀👀👀 saved logger profiles 👀👀👀 ")
    }
    
    public func loggerProfilesFromJSON(_ jsonString:String) -> [LoggerProfile]{
        let jsonDecoder = JSONDecoder()
        do{
            return try jsonDecoder.decode([LoggerProfile].self, from: jsonString.data(using: .utf8)!)
        }catch{
            print("🧨 \(self.dtFormatter.string(from: Date())) [loggerProfilesFromJSON] \(error)")
            return []
        }
    }
    
    public func loggerProfilesToJSON() -> String {
        let array = self.profiles.map { p in
            return p
        }
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(array)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            return json ?? "{}"
        }catch{
            print("🧨 \(self.dtFormatter.string(from: Date())) [loggerProfilesToJSON] \(error)")
            return "{}"
        }
    }
    
    public func addSetting(profile:LoggerProfile) {
        if let logtype = LogType.init(rawValue: profile.logtype) {
            if profile.writerId != "" {
                self.addSetting(logtype: logtype, category: profile.category, subCategory: profile.subCategory, writerId: profile.writerId)
            }
        }
    }
    
    public func addSetting(logtype: LogType, category:String, subCategory:String, writerId:String) {
        if self.profiles.isEmpty {
            self.loadSettings()
        }
        var exist = false
        for profile in profiles {
            if profile.logtype == logtype.rawValue && profile.category == category && profile.subCategory == subCategory && profile.writerId == writerId {
                exist = true
            }
        }
        if !exist {
            var profile = LoggerProfile()
            profile.logtype = logtype.rawValue
            profile.category = category
            profile.subCategory = subCategory
            profile.writerId = writerId
            profiles.append(profile)
            
            self.saveSettings()
        }
    }
    
    public func shouldLog(logtype: LogType, category:String, subCategory:String, writerId:String) -> Bool {
        for profile in profiles {
            if profile.logtype == logtype.rawValue && profile.category == category && profile.subCategory == subCategory && profile.writerId == writerId {
                return true
            }
            if profile.logtype == logtype.rawValue && profile.category == category && profile.subCategory == "" && profile.writerId == writerId {
                return true
            }
            if profile.logtype == logtype.rawValue && profile.category == "" && profile.subCategory == "" && profile.writerId == writerId {
                return true
            }
        }
        return false
    }
}



public class LoggerProfile : Codable {
    
    private static let dtFormatter = ISO8601DateFormatter()
    
    public var logtype = ""
    public var category = ""
    public var subCategory = ""
    public var writerId = ""
    
    public init() {}
    
    public func id() -> String {
        return "\(logtype):\(category):\(subCategory):\(writerId)"
    }
    
    public func toJSON() -> String {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            print("👀 \(LoggerProfile.dtFormatter.string(from: Date())) [toJSON] \(json ?? "__EMPTY__")")
            return json ?? "{}"
        }catch{
            print("🧨 \(LoggerProfile.dtFormatter.string(from: Date())) [toJSON] \(error)")
            return "{}"
        }
    }
    
    public static func fromJSON(_ jsonString:String) -> LoggerProfile? {
        let jsonDecoder = JSONDecoder()
        do{
            return try jsonDecoder.decode(LoggerProfile.self, from: jsonString.data(using: .utf8)!)
        }catch{
            print("👀 \(LoggerProfile.dtFormatter.string(from: Date())) [fromJSON] \(jsonString)")
            print("🧨 \(LoggerProfile.dtFormatter.string(from: Date())) [fromJSON] \(error)")
            return nil
        }
    }
}
