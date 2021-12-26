//
//  SearchHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/5/10.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

struct SearchCondition {
    
    static let logger = ConsoleLogger(category: "SearchCondition")
    
    var years:[Int]
    var months:[Int]
    var days:[Int]
    var peopleIds:[String]
    var events:[String]
    var places:[String]
    var notes:[String]
    var cameras:[String]
    var folders:[String]
    var filenames:[String]
    var any:[String]
    var includeHidden:Bool
    
    func isEmpty() -> Bool {
        return years.isEmpty
            && months.isEmpty
            && days.isEmpty
            && peopleIds.isEmpty
            && events.isEmpty
            && places.isEmpty
            && notes.isEmpty
            && cameras.isEmpty
            && folders.isEmpty
            && filenames.isEmpty
            && any.isEmpty
    }
    
    static func get(from query:String, separator:String = " | ", includeHidden:Bool = false) -> SearchCondition {
        var years:[Int] = []
        var months:[Int] = []
        var days:[Int] = []
        var peopleIds:[String] = []
        var events:[String] = []
        var places:[String] = []
        var notes:[String] = []
        var cameras:[String] = []
        var folders:[String] = []
        var filenames:[String] = []
        var any:[String] = []
        let conditions = query.components(separatedBy: "||")
        for condition in conditions {
            if condition == "" {continue}
            var keyword = ""
            var type = ""
            let part = condition.components(separatedBy: separator)
            if part.count == 1 {
                any.append(condition)
            }else if part.count == 2 {
                keyword = part[0].replacingOccurrences(of: "'", with: "''")
                                 .replacingOccurrences(of: "--", with: "")
                                 .trimmingCharacters(in: .whitespacesAndNewlines)
                type = part[1].replacingOccurrences(of: "'", with: "''")
                              .trimmingCharacters(in: .whitespacesAndNewlines)
            }else{
                SearchCondition.logger.log("Unrecognized search condition \"\(condition)\"")
                continue
            }
            
            if type == YEAR {
                if let i = Int(keyword), i >= 1950 && i < 10000 {
                    years.append(i)
                }else{
                    SearchCondition.logger.log("Unrecognized search condition \"\(condition)\"")
                    continue
                }
            }else if type == MONTH {
                if let i = Int(keyword), i >= 1 && i <= 12 {
                    months.append(i)
                }else{
                    SearchCondition.logger.log("Unrecognized search condition \"\(condition)\"")
                    continue
                }
            }else if type == DAY {
                if let i = Int(keyword), i >= 1 && i <= 31 {
                    days.append(i)
                }else{
                    SearchCondition.logger.log("Unrecognized search condition \"\(condition)\"")
                    continue
                }
            }else if type == PEOPLE {
                peopleIds.append(keyword)
            }else if type == EVENT {
                events.append(keyword)
            }else if type == PLACE {
                places.append(keyword)
            }else if type == NOTE {
                notes.append(keyword)
            }else if type == CAMERA {
                cameras.append(keyword)
            }else if type == FOLDER {
                folders.append(keyword)
            }else if type == FILENAME {
                filenames.append(keyword)
            }else if type == ANY {
                any.append(keyword)
            }else{
                SearchCondition.logger.log("Unrecognized search condition \"\(condition)\"")
                continue
            }
            
        }
        return SearchCondition(
                        years: years,
                        months: months,
                        days: days,
                        peopleIds: peopleIds,
                        events: events,
                        places: places,
                        notes: notes,
                        cameras: cameras,
                        folders: folders,
                        filenames: filenames,
                        any: any,
                        includeHidden: includeHidden)
    }
    
    // MARK: - Menu for completion string
    
    
    static func createTokenFieldCompletionMenu(for text:String, separator:String = " | ") -> [String] {
        if let number = Int(text) {
            if number >= 1950 && number <= 10000 {
                return [
                    "\(text)\(separator)\(SearchCondition.YEAR)",
                    "\(text)\(separator)\(SearchCondition.EVENT)",
                    "\(text)\(separator)\(SearchCondition.PLACE)",
                    "\(text)\(separator)\(SearchCondition.NOTE)",
                    "\(text)\(separator)\(SearchCondition.CAMERA)",
                    "\(text)\(separator)\(SearchCondition.FOLDER)",
                    "\(text)\(separator)\(SearchCondition.FILENAME)",
                    "\(text)\(separator)\(SearchCondition.ANY)"
                ]
            }else if number > 0 && number <= 12 {
                return [
                    "\(text)\(separator)\(SearchCondition.MONTH)",
                    "\(text)\(separator)\(SearchCondition.DAY)",
                    "\(text)\(separator)\(SearchCondition.EVENT)",
                    "\(text)\(separator)\(SearchCondition.PLACE)",
                    "\(text)\(separator)\(SearchCondition.NOTE)",
                    "\(text)\(separator)\(SearchCondition.CAMERA)",
                    "\(text)\(separator)\(SearchCondition.FOLDER)",
                    "\(text)\(separator)\(SearchCondition.FILENAME)",
                    "\(text)\(separator)\(SearchCondition.ANY)"
                ]
            }else if number > 0 && number <= 31 {
                return [
                    "\(text)\(separator)\(SearchCondition.DAY)",
                    "\(text)\(separator)\(SearchCondition.DAY)",
                    "\(text)\(separator)\(SearchCondition.EVENT)",
                    "\(text)\(separator)\(SearchCondition.PLACE)",
                    "\(text)\(separator)\(SearchCondition.NOTE)",
                    "\(text)\(separator)\(SearchCondition.CAMERA)",
                    "\(text)\(separator)\(SearchCondition.FOLDER)",
                    "\(text)\(separator)\(SearchCondition.FILENAME)",
                    "\(text)\(separator)\(SearchCondition.ANY)"
                ]
            }
        }
        return [
            "\(text)\(separator)\(SearchCondition.EVENT)",
            "\(text)\(separator)\(SearchCondition.PLACE)",
            "\(text)\(separator)\(SearchCondition.NOTE)",
            "\(text)\(separator)\(SearchCondition.CAMERA)",
            "\(text)\(separator)\(SearchCondition.FOLDER)",
            "\(text)\(separator)\(SearchCondition.FILENAME)",
            "\(text)\(separator)\(SearchCondition.ANY)"
        ]
    }
    
    
    // MARK: - Prompt text localized
    
    static var YEAR:String {
        get {
            return "Year"
        }
    }
    
    static var MONTH:String {
        get {
            return "Month"
        }
    }
    
    static var DAY:String {
        get {
            return "Day"
        }
    }
    
    static var PEOPLE:String {
        get {
            return "Person"
        }
    }
    
    static var EVENT:String {
        get{
            return "Event"
        }
    }
    
    static var PLACE:String {
        get{
            return "Place"
        }
    }
    
    static var NOTE:String {
        get{
            return "Note"
        }
    }
    
    static var CAMERA:String {
        get{
            return "Camera"
        }
    }
    
    static var FOLDER:String {
        get{
            return "Folder"
        }
    }
    
    static var FILENAME:String {
        get{
            return "Filename"
        }
    }
    
    static var ANY:String {
        get{
            return "Any"
        }
    }
}
