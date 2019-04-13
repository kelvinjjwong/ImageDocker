//
//  ModelStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/7/14.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB


class ModelStore {
    
    fileprivate let dbfile = PreferencesController.databasePath(filename: "ImageDocker.sqlite")
    
    static let `default` = ModelStore()
    
    init(){
        self.checkDatabase()
        self.versionCheck()
    }
    
    // MARK: SHARED DATABASE INSTANCE
    
    private static var _sharedDBPool:DatabaseWriter?
    
    static func sharedDBPool() -> DatabaseWriter{
        if _sharedDBPool == nil {
            do {
                //var config = Configuration()
                //config.trace = { print($0) }     // Prints all SQL statements
                
                _sharedDBPool = try DatabasePool(path: ModelStore.default.dbfile
                                                //, configuration: config
                                                )
            }catch{
                print(error) //SQLite error 5: database is locked
            }
            
        }
        return _sharedDBPool!
    }
    
    // MARK: COMMONS
    
    fileprivate func inArray(field:String, array:[Any]?, where whereStmt:inout String, args sqlArgs:inout [Any]){
        if let array = array {
            if array.count > 0 {
                let marks = repeatElement("?", count: array.count).joined(separator: ",")
                whereStmt = "AND \(field) in (\(marks))"
                sqlArgs.append(contentsOf: array)
            }
        }
    }
    
    fileprivate func likeArray(field:String, array:[Any]?, wildcardPrefix:Bool = true, wildcardSuffix:Bool = true) -> String{
        if let array = array {
            if array.count > 0 {
                var stmts:[String] = []
                let p = wildcardPrefix ? "'%" : "'"
                let s = wildcardSuffix ? "%'" : "'"
                for value in array {
                    if "\(value)" == "" {
                        stmts.append("\(field) is null")
                        stmts.append("\(field) = ''")
                    }
                    stmts.append("\(field) LIKE \(p)\(value)\(s)")
                }
                return stmts.joined(separator: " OR ")
            }
        }
        return ""
    }
    
    // MARK: Duplicates
    
    var _duplicates:Duplicates? = nil
    
    func reloadDuplicatePhotos() {
        print("\(Date()) Loading duplicate photos from db")
        
        let duplicates:Duplicates = Duplicates()
        var dupDates:Set<Date> = []
        do {
            let db = ModelStore.sharedDBPool()
            // try DatabaseQueue(path: dbfile)
            try db.read { db in
                let cursor = try Row.fetchCursor(db,
"""
SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,photoCount FROM
(
    SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,count(path) as photoCount FROM
    (
        SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,path FROM IMAGE
        WHERE photoTakenDate LIKE '%.000'
        UNION
        SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate || '.000' ,place,path FROM IMAGE
        WHERE photoTakenDate IS NOT NULL AND photoTakenDate NOT LIKE '%.000'
    )
    GROUP BY photoTakenDate, place, photoTakenDay, photoTakenMonth, photoTakenYear
) WHERE photoCount > 1 ORDER BY photoTakenDate
"""
                )
                
                while let row = try cursor.next() {
                    
                    //let dup:Duplicate = Duplicate()
                    let year = row["photoTakenYear"] as Int
                    let month = row["photoTakenMonth"]  as Int
                    let day = row["photoTakenDay"]  as Int
                    let date = row["photoTakenDate"] as Date
                    //let place = row["place"] as! String? ?? ""
                    //dup.event = row["event"] as! String? ?? ""
                    //duplicates.duplicates.append(dup)
                    
                    let monthString = month < 10 ? "0\(month)" : "\(month)"
                    let dayString = day < 10 ? "0\(day)" : "\(day)"
                    let category:String = "\(year)年\(monthString)月\(dayString)日"
                    
                    duplicates.categories.insert(category)
                    
                    duplicates.years.insert(year)
                    duplicates.yearMonths.insert(year * 1000 + month)
                    duplicates.yearMonthDays.insert(year * 100000 + month * 100 + day)
                    
                    //print("duplicated date: \(date)")
                    dupDates.insert(date)
                }
            }
        }catch{
            print(error)
        }
        
        var firstPhotoInPlaceAndDate:[String:String] = [:]
        print("\(Date()) Marking duplicate tag to photo files")
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                print("duplicated date count: \(dupDates.count)")
                let marks = repeatElement("?", count: dupDates.count).joined(separator: ",")
                let sql = "SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,path FROM Image WHERE photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND photoTakenDate in (\(marks))"
                //print(sql)
                let photosInSameDate = try Row.fetchCursor(db, sql, arguments:StatementArguments(dupDates))
                
                while let photo = try photosInSameDate.next() {
                    if let date = photo["photoTakenDate"] as Date? {
                        let year = Calendar.current.component(.year, from: date)
                        let month = Calendar.current.component(.month, from: date)
                        let day = Calendar.current.component(.day, from: date)
                        let hour = Calendar.current.component(.hour, from: date)
                        let minute = Calendar.current.component(.minute, from: date)
                        let second = Calendar.current.component(.second, from: date)
                        let key = "\(photo["place"] ?? "")_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)"
                        //print("duplicated record: \(key)")
                        let path = photo["path"] as String? ?? ""
                        if let first = firstPhotoInPlaceAndDate[key] {
                            // duplicates
                            duplicates.paths.insert(first)
                            duplicates.paths.insert(path)
                        }else{
                            firstPhotoInPlaceAndDate[key] = path
                        }
                        
                        // bi-direction mapping
                        duplicates.pathToKey[path] = key
                        if let _ = duplicates.keyToPath[key] {
                            duplicates.keyToPath[key]?.append(path)
                        }else{
                            duplicates.keyToPath[key] = [path]
                        }
                    }
                }
            }
//            for key in duplicates.keyToPath.keys {
//                print("-------")
//                print("duplicated key: \(key)")
//                for p in duplicates.keyToPath[key]! {
//                    print("duplicated path: \(p)")
//                }
//            }
        }catch{
            print(error)
        }
        print("\(Date()) Marking duplicate tag to photo files: DONE")
        
        _duplicates = duplicates
        print("\(Date()) Loading duplicate photos from db: DONE")
    }
    
    func getDuplicatePhotos() -> Duplicates {
        if _duplicates == nil {
            reloadDuplicatePhotos()
        }
        return _duplicates!
    }
    
    
//
//    func getAllContainerPaths() -> [Row] {
//        var rows:[Row] = []
//        do {
//            let db = ModelStore.sharedDBPool()
//            try db.read { db in
//                rows = try Row.fetchAll(db, "SELECT containerPath, count(path) as photoCount FROM Image GROUP BY containerPath")
//            }
//        }catch{
//            print(error)
//        }
//
//        return rows
//
//    }
    
    // MARK: Options
    
    func getImageSources() -> [String:Bool]{
        var results:[String:Bool] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT imageSource FROM Image")
                for row in rows {
                    let src = row["imageSource"] as String?
                    if let src = src, src != "" {
                        results[src] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    func getCameraModel() -> [String:Bool] {
        var results:[String:Bool] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT cameraMaker,cameraModel FROM Image")
                for row in rows {
                    let name1:String = row["cameraMaker"] ?? ""
                    let name2:String = row["cameraModel"] ?? ""
                    if name1 != "" && name2 != "" {
                        results["\(name1),\(name2)"] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    // MARK: CONTAINERS
    
    func getAllContainers() -> [ImageContainer] {
        var containers:[ImageContainer] = []
        
        do {
            let dbPool = ModelStore.sharedDBPool()
            try dbPool.read { db in
                containers = try ImageContainer.order(Column("path").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return containers
    }
    
    func deleteContainer(path: String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("DELETE FROM ImageContainer WHERE path LIKE '\(path)/%'")
                try db.execute("DELETE FROM Image WHERE path LIKE '\(path)/%'")
            }
        }catch{
            print(error)
        }
    }
    
    func getContainers(rootPath:String) -> [ImageContainer] {
        var result:[ImageContainer] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(Column("path").like("\(rootPath.withStash())%")).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getContainer(path:String) -> ImageContainer? {
        var result:ImageContainer?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "path=?", arguments: StatementArguments([path])).fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllContainerPaths(rootPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if let root = rootPath {
                    let cursor = try ImageContainer.filter(Column("path").like("\(root)%")).order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }else{
                    let cursor = try ImageContainer.order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllContainerPaths(repositoryPath:String? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if let repoPath = repositoryPath {
                    let cursor = try ImageContainer.filter(sql: "repositoryPath = ?", arguments: [repoPath]).order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }else{
                    let cursor = try ImageContainer.order(sql: "path").fetchCursor(db)
                    while let container = try cursor.next() {
                        result.insert(container.path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func updateImageContainerParentFolder(path:String, parentFolder:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set parentFolder = ? where path = ?", arguments: [parentFolder, path])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageContainerHideByParent(path:String, hideByParent:Bool){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hideByParent = \(hideByParent ? 1 : 0) where path = ?", arguments: [path])
            }
        }catch{
            print(error)
        }
    }
    
    func getOrCreateContainer(name:String,
                              path:String,
                              parentPath parentFolder:String = "",
                              repositoryPath:String,
                              homePath:String,
                              storagePath:String,
                              facePath:String,
                              cropPath:String,
                              subPath:String,
                              manyChildren:Bool = false,
                              hideByParent:Bool = false,
                              sharedDB:DatabaseWriter? = nil) -> ImageContainer {
        var container:ImageContainer?
        do {
            let db = try sharedDB ?? DatabaseQueue(path: dbfile)
            try db.read { db in
                container = try ImageContainer.fetchOne(db, key: path)
            }
            if container == nil {
                let queue = try sharedDB ?? DatabaseQueue(path: dbfile)
                try queue.write { db in
                    container = ImageContainer(name: name,
                                               parentFolder: parentFolder,
                                               path: path,
                                               imageCount: 0,
                                               repositoryPath: repositoryPath,
                                               homePath: homePath,
                                               storagePath: storagePath,
                                               facePath: facePath,
                                               cropPath: cropPath,
                                               subPath: subPath,
                                               parentPath: parentFolder.replacingFirstOccurrence(of: repositoryPath.withStash(), with: ""),
                                               hiddenByRepository: false,
                                               hiddenByContainer: false,
                                               deviceId: "",
                                               manyChildren: manyChildren,
                                               hideByParent: hideByParent
                                              )
                    try container?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return container!
    }
    
    func getRepositories() -> [ImageContainer] {
        var result:[ImageContainer] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "parentFolder=''").order(Column("path").asc).fetchAll(db)
                print(result.count)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getRepository(repositoryPath:String) -> ImageContainer? {
        var result:ImageContainer? = nil
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageContainer.filter(sql: "repositoryPath = ? and parentFolder=''", arguments: [repositoryPath]).fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func saveImageContainer(container:ImageContainer){
        var container = container
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try container.save(db)
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                //print("UPDATE CONTAINER old path = \(oldPath) with new path = \(newPath)")
                try db.execute("update ImageContainer set path = ?, repositoryPath = ?, parentFolder = ?, subPath = ? where path = ?", arguments: [newPath, repositoryPath, parentFolder, subPath, oldPath])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) {
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set path = ?, repositoryPath = ? where path = ?", arguments: [newPath, repositoryPath, oldPath])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageContainerToggleManyChildren(path:String, state:Bool) {
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set manyChildren = \(state ? 1 : 0) where path = ?", arguments: [path])
                try db.execute("update ImageContainer set hideByParent = \(state ? 1 : 0) where path like ?", arguments: ["\(path.withStash())%"])
            }
        }catch{
            print(error)
        }
    }
    
    func hideContainer(path:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByContainer = 1 where path = ?", arguments: [path])
                try db.execute("update ImageContainer set hiddenByContainer = 1 where path like ?", arguments: ["\(path.withStash())%"])
                try db.execute("update Image set hiddenByContainer = 1 where path like ?", arguments:["\(path.withStash())%"])
            }
        }catch{
            print(error)
        }
    }
    
    func showContainer(path:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByContainer = 0 where path = ?", arguments: [path])
                try db.execute("update Image set hiddenByContainer = 0 where path like ?", arguments:["\(path.withStash())%"])
            }
        }catch{
            print(error)
        }
    }
    
    func hideRepository(repositoryRoot:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByRepository = 1 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update ImageContainer set hiddenByRepository = 1 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
                try db.execute("update Image set hiddenByRepository = 1 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update Image set hiddenByRepository = 1 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
            }
        }catch{
            print(error)
        }
    }
    
    func showRepository(repositoryRoot:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update ImageContainer set hiddenByRepository = 0 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update ImageContainer set hiddenByRepository = 0 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
                try db.execute("update Image set hiddenByRepository = 0 where path like ?", arguments: ["\(repositoryRoot.withStash())%"])
                try db.execute("update Image set hiddenByRepository = 0 where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
            }
        }catch{
            print(error)
        }
    }
    
    func deleteRepository(repositoryRoot:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("delete from ImageContainer where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
                try db.execute("delete from Image where repositoryPath = ?", arguments: ["\(repositoryRoot.withStash())"])
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: IMAGES
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil, sharedDB:DatabaseWriter? = nil) -> Image{
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
            if image == nil {
                let queue = try sharedDB ?? DatabaseQueue(path: dbfile)
                try queue.write { db in
                    image = Image.new(filename: filename, path: path, parentFolder: parentPath, repositoryPath: repositoryPath ?? "")
                    try image?.save(db)
                }
                
            }
        }catch{
            print(error)
        }
        return image!
    }
    
    func getImage(path:String) -> Image?{
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
        }catch{
            print(error)
        }
        return image
    }
    
    func getImage(id:String) -> Image? {
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.filter(sql: "id='\(id)'").fetchOne(db)
            }
        }catch{
            print(error)
        }
        return image
    }
    
    func saveImage(image: Image, sharedDB:DatabaseWriter? = nil){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                var image = image
                try image.save(db)
                //print("saved image")
            }
        }catch{
            print(error)
        }
    }
    
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) {
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set path = ?, repositoryPath = ?, subPath = ?, containerPath = ?, id = ? where path = ?", arguments: [newPath, repositoryPath, subPath, containerPath, id, oldPath])
            }
        }catch{
            print(error)
        }
    }
    
    
    
    func deletePhoto(atPath path:String, updateFlag:Bool = true){
        if updateFlag {
            do {
                let db = ModelStore.sharedDBPool()
                let _ = try db.write { db in
                    try db.execute("update Image set delFlag = ?", arguments: [true])
                }
            }catch{
                print(error)
            }
        }else{
            do {
                let db = ModelStore.sharedDBPool()
                let _ = try db.write { db in
                    try Image.deleteOne(db, key: path)
                }
            }catch{
                print(error)
            }
        }
    }
    
    // MARK: IMAGES GET BY TREE
    
    func getAllDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getAllPlacesAndDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT country, province, city, place, photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (
        SELECT country, province, city, place, photoTakenYear, photoTakenMonth, photoTakenDay, path, imageSource,cameraModel from Image WHERE assignCountry is null and assignProvince is null and assignCity is null
        UNION
        SELECT assignCountry as country, assignProvince as province, assignCity as city, assignPlace as place, photoTakenYear, photoTakenMonth, photoTakenDay, path, imageSource,cameraModel from Image WHERE assignCountry is not null and assignProvince is not null and assignCity is not null
        )
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere)
        GROUP BY country,province,city,place,photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY country,province,city,place,photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: IMAGES GET BY COLLECTION
    
    // sql by date & place
    fileprivate func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        print("\(year) | \(month) | \(day) | ignoreDate:\(ignoreDate) | \(country) | \(province) | \(city)")
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=0"
        }
        var placeWhere = ""
        if (place == nil || place == ""){
            if country != "" {
                placeWhere += " AND (country = '\(country)' OR assignCountry = '\(country)')"
            }
            if province != "" {
                placeWhere += " AND (province = '\(province)' OR assignProvince = '\(province)')"
            }
            if city != "" {
                placeWhere += " AND (city = '\(city)' OR assignCity = '\(city)')"
            }
        }else {
            placeWhere = "AND (place = '\(place ?? "")' OR assignPlace = '\(place ?? "")') "
        }
        
        
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 && month == 0 && day == 0 {
            if ignoreDate {
                stmtWithoutHiddenWhere = "1=1 \(placeWhere)"
            }else{
                stmtWithoutHiddenWhere = "( (photoTakenYear = 0 and photoTakenMonth = 0 and photoTakenDay = 0) OR (photoTakenYear is null and photoTakenMonth is null and photoTakenDay is null) ) \(placeWhere)"
            }
        }else{
            if year == 0 {
                // no condition
            } else if month == 0 {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) \(placeWhere) \(hiddenWhere)"
            } else if day == 0 {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) and photoTakenMonth = \(month) \(placeWhere)"
            } else {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) and photoTakenMonth = \(month) and photoTakenDay = \(day) \(placeWhere)"
            }
        }
        
        var sqlArgs:[Any] = []
        
        self.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        self.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=1"
        
        print(stmt)
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // count by date & place
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (stmt, _, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by date & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (_, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // get by date & place
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                hiddenCount = try Image.filter(sql: stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
                if pageNumber > 0 && pageSize > 0 {
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .limit(pageSize, offset: pageSize * (pageNumber - 1))
                        .fetchAll(db)
                }else{
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        return result
    }
    
    // sql by date & event & place
    fileprivate func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        print("\(year) | \(month) | \(day) | event:\(event) | \(country) | \(province) | \(city)")
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=0"
        }
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 {
            stmtWithoutHiddenWhere = "event = '\(event)' \(hiddenWhere)"
        } else if day == 0 {
            stmtWithoutHiddenWhere = "event = '\(event)' and photoTakenYear = \(year) and photoTakenMonth = \(month) \(hiddenWhere)"
        } else {
            stmtWithoutHiddenWhere = "event = '\(event)' and photoTakenYear = \(year) and photoTakenMonth = \(month) and photoTakenDay = \(day) \(hiddenWhere)"
        }
        
        var sqlArgs:[Any] = []
        
        self.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        self.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=1"
        
        print(stmt)
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // count by date & event & place
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (stmt, _, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by date & event & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (_, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // get by date & event & place
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                hiddenCount = try Image.filter(sql: stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
                if pageNumber > 0 && pageSize > 0 {
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .limit(pageSize, offset: pageSize * (pageNumber - 1))
                        .fetchAll(db)
                }else{
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        return result
    }
    
    // MARK: IMAGES GET BY CONDITIONS
    
    func getYears(event:String? = nil) -> [Int] {
        var condition = ""
        var args:[String] = []
        if let ev = event {
            condition = " where event=? "
            args.append(ev)
        }
        let sql = "select distinct photoTakenYear from image \(condition) order by photoTakenYear desc"
        
        var result:[Int] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql, arguments:StatementArguments(args))
                for row in rows {
                    let year = row["photoTakenYear"] as Int? ?? 0
                    result.append(year)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getDatesByYear(year:Int, event:String? = nil) -> [String:[String]] {
        var sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? order by photoTakenMonth,photoTakenDay"
        var args:[Any] = [year]
        
        if let ev = event, ev != "" {
            sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? and event=? order by photoTakenMonth,photoTakenDay"
            args.append(ev)
        }
        
        //print(sql)
        var result:[String:[String]] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql, arguments:StatementArguments(args))
                for row in rows {
                    let month = row["photoTakenMonth"] as Int? ?? 0
                    let day = row["photoTakenDay"] as Int? ?? 0
                    if result["\(month)"] == nil {
                       result["\(month)"] = []
                    }
                    result["\(month)"]?.append("\(day)")
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getImagesByDate(year:Int, month:Int, day:Int, event:String? = nil) -> [Image]{
        var sql = "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day)"
        if let ev = event, ev != "" {
            sql = "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day) and event='\(ev)'"
        }
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: sql).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    
    func getImagesByDate(photoTakenDate:Date, event:String? = nil) -> [Image]{
        let year = Calendar.current.component(.year, from: photoTakenDate)
        let month = Calendar.current.component(.month, from: photoTakenDate)
        let day = Calendar.current.component(.day, from: photoTakenDate)
        return getImagesByDate(year: year, month: month, day: day, event: event)
    }
    
    func getImagesByHour(photoTakenDate:Date) -> [Image]{
        let year = Calendar.current.component(.year, from: photoTakenDate)
        let month = Calendar.current.component(.month, from: photoTakenDate)
        let day = Calendar.current.component(.day, from: photoTakenDate)
        let hour = Calendar.current.component(.hour, from: photoTakenDate)
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day) and photoTakenHour=\(hour)").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllPhotoPaths(includeHidden:Bool = true, sharedDB:DatabaseWriter? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if includeHidden {
                    let cursor = try Image.order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        result.insert(photo.path)
                    }
                }else{
                    let cursor = try Image.filter(sql: "hidden = 0").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        result.insert(photo.path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllExportedImages(includeHidden:Bool = true, sharedDB:DatabaseWriter? = nil) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if includeHidden {
                    result = try Image.filter(sql: "exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
                }else{
                    result = try Image.filter(sql: "hidden = 0 and exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllExportedPhotoFilenames(includeHidden:Bool = true, sharedDB:DatabaseWriter? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if includeHidden {
                    let cursor = try Image.filter(sql: "exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        let path = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                        result.insert(path)
                    }
                }else{
                    let cursor = try Image.filter(sql: "hidden = 0 and exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        let path = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                        result.insert(path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFiles(parentPath:String, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) -> [Image] {
        var otherPredicate:String = ""
        if !includeHidden {
            otherPredicate = " AND (hidden is null || hidden = 0)"
        }
        
        var condition = "containerPath = ?"
        var key:[String] = [parentPath]
        if subdirectories {
            condition = "(containerPath = ? or containerPath like ?)"
            key.append("\(parentPath.withStash())%")
        }
        
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if pageSize > 0 && pageNumber > 0 {
                    result = try Image.filter(sql: "\(condition) \(otherPredicate)", arguments: StatementArguments(key)).order([Column("photoTakenDate").asc, Column("path").asc]).limit(pageSize, offset: pageSize * (pageNumber - 1)).fetchAll(db)
                }else{
                    result = try Image.filter(sql: "\(condition) \(otherPredicate)", arguments: StatementArguments(key)).order([Column("photoTakenDate").asc, Column("path").asc]).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getImages(repositoryPath:String) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath = ?", arguments:[repositoryPath]).order(sql: "path asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFiles(rootPath:String) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath)%")).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFilesWithoutSubPath(rootPath:String) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath)%")).filter(Column("subPath") == "").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFilesWithoutExif(limit:Int? = nil) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND (updateExifDate is null OR photoTakenYear is null OR photoTakenYear = 0 OR (latitude <> '0.0' AND latitudeBD = '0.0') OR (latitudeBD <> '0.0' AND COUNTRY = ''))").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
                // TODO: OR updateLocationDate is null
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFilesWithoutLocation() -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND updateLocationDate is null").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFiles(after date:Date) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "updateLocationDate >= ?", arguments: StatementArguments([date])).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: IMAGES DUPLICATES
    
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]] {
        var result:[String:[Image]] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                let keyword = "\(repositoryRoot.withStash())%"
                let otherKeyword = "\(theOtherRepositoryRoot.withStash())%"
                let cursor = try Image.filter(sql: "(path like ? or path like ?) and duplicatesKey is not null and duplicatesKey != '' ", arguments:[keyword, otherKeyword]).order(sql: "duplicatesKey asc, path asc").fetchCursor(db)
                
                while let image = try cursor.next() {
                    if let key = image.duplicatesKey, key != "" {
                        //print("found \(key) - \(image.path)")
                        if let _ = result[key] {
                            result[key]?.append(image)
                        }else{
                            result[key] = [image]
                        }
                    }
                }
            }
            
            
        }catch{
            print(error)
        }
        return result
    }
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image?{
        var result:Image? = nil
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "hidden=0 and duplicatesKey='\(duplicatesKey)'").fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image?{
        var result:Image? = nil
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "duplicatesKey='\(duplicatesKey)'").order(Column("path").asc).fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set duplicatesKey = ?, hidden = ? where path = ?", arguments: [duplicatesKey, hide, path])
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: IMAGES COUNT
    
    func countImageWithoutFace(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 and id not in (select distinct imageid from imageface)", arguments:[root]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 and scanedFace<>1 and id not in (select distinct imageid from imageface)", arguments:[root]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getImagesWithoutFace(repositoryRoot:String, includeScanned:Bool = false) -> [Image] {
        var result:[Image] = []
        let root = repositoryRoot.withStash()
        let scannedCondition = includeScanned ? "" : " and scanedFace=0"
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 \(scannedCondition) and id not in (select distinct imageid from imageface)", arguments:[root]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by path~
    func countPhotoFiles(rootPath:String) -> Int {
        var result:Int = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath)%")).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "repositoryPath='' and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageWithoutSubPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "subPath='' and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageWithoutId(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "id is null and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "repositoryPath = ? and path not like ?", arguments: [root, keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImages(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countHiddenImages(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "path like ? and hidden = 1", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try ImageContainer.filter(sql: "repositoryPath = '' and path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try ImageContainer.filter(sql: "subPath = '' and path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: IMAGES - UPDATES
    
    func updateImageRawBase(oldRawPath:String, newRawPath:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set originPath = ? where originPath = ?", arguments: [newRawPath, oldRawPath])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageRawBase(repositoryPath:String, rawPath:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set originPath = ? where repositoryPath = ?", arguments: [rawPath, repositoryPath])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageRawBase(pathStartsWith path:String, rawPath:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set originPath = ? where path like ?", arguments: [rawPath, "\(path.withStash())%"])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set repositoryPath = ? where path like ?", arguments: [repositoryPath, "\(path.withStash())%"])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set repositoryPath = ? where repositoryPath = ?", arguments: [newRepository, oldRepositoryPath])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImagePath(repositoryPath:String){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set path = repositoryPath || subPath where repositoryPath = ? and subPath <> ''", arguments: [repositoryPath])
            }
        }catch{
            print(error)
        }
    }
    
    func updateImageDates(path:String, date:Date, fields:Set<String>){
        var arguments:[Any] = []
        var values:[String] = []
        for field in fields {
            if field == "DateTimeOriginal" {
                values.append("exifDateTimeOriginal = ?")
                arguments.append(date)
                continue
            }
            if field == "CreateDate" {
                values.append("exifCreateDate = ?")
                arguments.append(date)
                continue
            }
            if field == "ModifyDate" {
                values.append("exifModifyDate = ?")
                arguments.append(date)
                continue
            }
            if field == "FileCreateDate" {
                values.append("filesysCreateDate = ?")
                arguments.append(date)
                continue
            }
        }
        values.append("photoTakenDate = ?, photoTakenYear = ?, photoTakenMonth = ?, photoTakenDay = ?")
        arguments.append(date)
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        arguments.append(year)
        arguments.append(month)
        arguments.append(day)
        arguments.append(path)
        let valueSets = values.joined(separator: ",")
        
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set \(valueSets) WHERE path=?", arguments: StatementArguments(arguments))
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: IMAGES - EXPORT
    
    func countAllPhotoFilesForExporting(after date:Date) -> Int {
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND (updateDateTimeDate > ? OR updateExifDate > ? OR updateLocationDate > ? OR updateEventDate > ? OR exportTime is null)", arguments:StatementArguments([date, date, date, date])).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllPhotoFilesForExporting(after date:Date, limit:Int? = nil) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                var query = Image.filter(sql: "hidden != 1 AND photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND (updateDateTimeDate > ? OR updateExifDate > ? OR updateLocationDate > ? OR updateEventDate > ? OR exportTime is null)", arguments:StatementArguments([date, date, date, date]))
                    .order([Column("photoTakenDate").asc, Column("filename").asc])
                if let lim = limit {
                    query = query.limit(lim)
                }
                result = try query.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllPhotoFilesMarkedExported() -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter("hidden != 1 AND exportTime is not null)").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func cleanImageExportTime(path:String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = null WHERE path='\(path)'")
            }
        }catch{
            print(error)
        }
    }
    
    func storeImageOriginalMD5(path:String, md5:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set originalMD5 = ? WHERE path=?", arguments: StatementArguments([md5, path]))
            }
        }catch{
            print(error)
        }
    }
    
    func storeImageExportedMD5(path:String, md5:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportedMD5 = ? WHERE path=?", arguments: StatementArguments([md5, path]))
            }
        }catch{
            print(error)
        }
    }
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if let brief = shortDescription, let detailed = longDescription {
                    try db.execute("UPDATE Image set shortDescription = ?, longDescription = ? WHERE path=?", arguments: StatementArguments([brief, detailed, path]))
                }else if let brief = shortDescription {
                    try db.execute("UPDATE Image set shortDescription = ? WHERE path=?", arguments: StatementArguments([brief, path]))
                }else if let detailed = longDescription {
                    try db.execute("UPDATE Image set longDescription = ? WHERE path=?", arguments: StatementArguments([detailed, path]))
                }
            }
        }catch{
            print(error)
        }
    }
    
    func storeImageExportSuccess(path:String, date:Date, exportToPath:String, exportedFilename:String, exportedMD5:String, exportedLongDescription:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = ?, exportToPath = ?, exportAsFilename = ?, exportedMD5 = ?, exportedLongDescription = ?, exportState = 'OK', exportFailMessage = '' WHERE path=?", arguments: StatementArguments([date, exportToPath, exportedFilename, exportedMD5, exportedLongDescription, path]))
            }
        }catch{
            print(error)
        }
    }
    
    func storeImageExportedTime(path:String, date:Date){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = ? WHERE path=?", arguments: StatementArguments([date, path]))
            }
        }catch{
            print(error)
        }
    }
    
    func storeImageExportFail(path:String, date:Date, message:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = ?, exportState = 'FAIL', exportFailMessage = ? WHERE path=?", arguments: StatementArguments([date, message, path]))
            }
        }catch{
            print(error)
        }
    }
    
    func cleanImageExportPath(path:String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportToPath = null, exportAsFilename = null, exportTime = null, exportState = null, exportFailMessage = '', exportedMD5 = null, WHERE path=?", arguments: StatementArguments([path]))
            }
        }catch{
            print(error)
        }
        
    }
    
    // MARK: PLACES
    
    
    func getAllPlaces() -> [ImagePlace] {
        var places:[ImagePlace] = []
        
        do {
            let dbPool = ModelStore.sharedDBPool()
            try dbPool.read { db in
                places = try ImagePlace.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return places
    }
    
    func getPlaces(byName names:String? = nil) -> [ImagePlace] {
        var result:[ImagePlace] = []
        var stmt = ""
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            stmt = self.likeArray(field: "name", array: keys)
        }
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if stmt != "" {
                    result = try ImagePlace.filter(stmt).order(Column("name").asc).fetchAll(db)
                }else{
                    result = try ImagePlace.order(Column("name").asc).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getOrCreatePlace(name:String, location:Location) -> ImagePlace{
        var place:ImagePlace?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                place = try ImagePlace.fetchOne(db, key: name)
            }
            if place == nil {
                try db.write { db in
                    place = ImagePlace(
                                       name: name,
                                       country:             location.country,
                                       province:            location.province,
                                       city:                location.city,
                                       district:            location.district,
                                       businessCircle:      location.businessCircle,
                                       street:              location.street,
                                       address:             location.address,
                                       addressDescription:  location.addressDescription,
                                       latitude:            location.coordinate?.latitude.description ?? "",
                                       latitudeBD:          location.coordinateBD?.latitude.description ?? "",
                                       longitude:           location.coordinate?.longitude.description ?? "",
                                       longitudeBD:         location.coordinateBD?.longitude.description ?? "" )
                    try place?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return place!
    }
    
    
    
    func getPlace(name:String) -> ImagePlace? {
        var place:ImagePlace?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                place = try ImagePlace.fetchOne(db, key: name)
            }
        }catch{
            print(error)
        }
        return place
    }
    
    func renamePlace(oldName:String, newName:String){
        print("trying to rename place from \(oldName) to \(newName)")
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if let _ = try ImagePlace.fetchOne(db, key: newName){ // already exists new name, just delete old one
                    //
                }else {
                    if var place = try ImagePlace.fetchOne(db, key: oldName) { // does not exist new name, create new name, and delete old one
                        place.name = newName
                        try place.save(db)
                    }
                }
                try db.execute("UPDATE Image SET assignPlace=? WHERE assignPlace=?", arguments: StatementArguments([newName, oldName]))
                try ImagePlace.deleteOne(db, key: oldName)  // delete old one at last
            }
        }catch{
            print(error)
        }
    }
    
    func updatePlace(name:String, location:Location){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if var place = try ImagePlace.fetchOne(db, key: name) {
                    place.country = location.country
                    place.province = location.province
                    place.city = location.city
                    place.businessCircle = location.businessCircle
                    place.district = location.district
                    place.street = location.street
                    place.address = location.address
                    place.addressDescription = location.addressDescription
                    place.latitude = location.coordinate?.latitude.description ?? ""
                    place.longitude = location.coordinate?.longitude.description ?? ""
                    place.latitudeBD = location.coordinateBD?.latitude.description ?? ""
                    place.longitudeBD = location.coordinateBD?.longitude.description ?? ""
                    try place.save(db)
                    try db.execute("UPDATE Image SET AssignCountry=?,AssignProvince=?,AssignCity=?,AssignBusinessCircle=?,AssignDistrict=?,AssignStreet=?,AssignAddress=?,AssignAddressDescription=?,Latitude=?,longitude=?,latitudeBD=?,longitudeBD=? WHERE AssignPlace=?",
                                   arguments: StatementArguments([
                                    location.country,
                                    location.province,
                                    location.city,
                                    location.businessCircle,
                                    location.district,
                                    location.street,
                                    location.address,
                                    location.addressDescription,
                                    location.coordinate?.latitude.description ?? "",
                                    location.coordinate?.longitude.description ?? "",
                                    location.coordinateBD?.latitude.description ?? "",
                                    location.coordinateBD?.longitude.description ?? "",
                                    name]))
                }
            }
        }catch{
            print(error)
        }
    }
    
    func deletePlace(name:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                let _ = try ImagePlace.deleteOne(db, key: name)
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: EVENTS
    
    func getAllEvents() -> [ImageEvent] {
        var events:[ImageEvent] = []
        
        do {
            let dbPool = ModelStore.sharedDBPool()
            try dbPool.read { db in
                events = try ImageEvent.order([Column("country").asc, Column("province").asc, Column("city").asc, Column("name").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return events
    }
    
    func getEvents(byName names:String? = nil) -> [ImageEvent] {
        var result:[ImageEvent] = []
        var stmt = ""
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            stmt = self.likeArray(field: "name", array: keys)
        }
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if stmt != "" {
                    result = try ImageEvent.filter(stmt).order(Column("name").asc).fetchAll(db)
                }else{
                    result = try ImageEvent.order(Column("name").asc).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getOrCreateEvent(name:String) -> ImageEvent{
        var event:ImageEvent?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                event = try ImageEvent.fetchOne(db, key: name)
            }
            if event == nil {
                try db.write { db in
                    event = ImageEvent(name: name)
                    try event?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return event!
    }
    
    func deleteEvent(name:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try ImageEvent.deleteOne(db, key: name)
                try db.execute("UPDATE Image SET event='' WHERE event=?", arguments: StatementArguments([name]))
            }
        }catch{
            print(error)
        }
    }
    
    func renameEvent(oldName:String, newName:String){
        print("RENAME EVENT \(oldName) to \(newName)")
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if let _ = try ImageEvent.fetchOne(db, key: newName){
                    try ImageEvent.deleteOne(db, key: oldName)
                }else {
                    if var event = try ImageEvent.fetchOne(db, key: oldName) {
                        event.name = newName
                        try event.save(db)
                    }
                }
                try db.execute("UPDATE Image SET AssignPlace=? WHERE AssignPlace=?", arguments: StatementArguments([oldName, newName]))
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: EVENTS - TREE
    
    func getAllEvents(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = "SELECT event, photoTakenYear, photoTakenMonth, photoTakenDay, place, count(path) as photoCount FROM Image WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY event, photoTakenYear,photoTakenMonth,photoTakenDay,place ORDER BY event DESC,photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC,place"
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: DEVICES
    
    func getDevices() -> [ImageDevice] {
        var result:[ImageDevice] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageDevice.order(Column("name").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getOrCreateDevice(device:PhoneDevice) -> ImageDevice{
        var dev:ImageDevice?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                dev = try ImageDevice.fetchOne(db, key: device.deviceId)
            }
            if dev == nil {
                try db.write { db in
                    dev = ImageDevice.new(
                        deviceId: device.deviceId,
                        type: device.type == .Android ? "Android" : "iPhone",
                        manufacture: device.manufacture,
                        model: device.model
                    )
                    try dev?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return dev!
    }
    
    func getDevice(deviceId:String) -> ImageDevice? {
        var dev:ImageDevice?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                dev = try ImageDevice.fetchOne(db, key: deviceId)
            }
        }catch{
            print(error)
        }
        return dev
    }
    
    func saveDevice(device:ImageDevice){
        var dev = device
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try dev.save(db)
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: DEVICE FILES
    
    func getImportedFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile? {
        var deviceFile:ImageDeviceFile?
        do {
            let key = "\(deviceId):\(file.path)"
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                deviceFile = try ImageDeviceFile.fetchOne(db, key: key)
            }
        }catch{
            print(error)
        }
        return deviceFile
    }
    
    func getOrCreateDeviceFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile{
        var deviceFile:ImageDeviceFile?
        do {
            let key = "\(deviceId):\(file.path)"
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                deviceFile = try ImageDeviceFile.fetchOne(db, key: key)
            }
            if deviceFile == nil {
                try db.write { db in
                    deviceFile = ImageDeviceFile.new(
                        fileId: key,
                        deviceId: deviceId,
                        path: file.path,
                        filename: file.filename,
                        fileDateTime: file.fileDateTime,
                        fileSize: file.fileSize
                    )
                    try deviceFile?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return deviceFile!
    }
    
    func saveDeviceFile(file:ImageDeviceFile){
        var f = file
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try f.save(db)
            }
        }catch{
            print(error)
        }
    }
    
    func deleteDeviceFiles(deviceId:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("delete from ImageDeviceFile where deviceId = ?", arguments: [deviceId])
            }
        }catch{
            print(error)
        }
    }
    
    func getDeviceFiles(deviceId:String) -> [ImageDeviceFile] {
        var result:[ImageDeviceFile] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageDeviceFile.filter(sql: "deviceId='\(deviceId)'").order(Column("importToPath").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: DEVICE PATHS
    
    func getDevicePath(deviceId:String, path:String) -> ImageDevicePath? {
        var devicePath:ImageDevicePath?
        do {
            let key = "\(deviceId):\(path)"
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                devicePath = try ImageDevicePath.fetchOne(db, key: key)
            }
            return devicePath
        }catch{
            print(error)
        }
        return nil
    }
    
    func saveDevicePath(file:ImageDevicePath){
        var f = file
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try f.save(db)
            }
        }catch{
            print(error)
        }
    }
    
    func deleteDevicePath(deviceId:String, path:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("delete from ImageDevicePath where deviceId = ? and path = ?", arguments: [deviceId, path])
            }
        }catch{
            print(error)
        }
    }
    
    func getDevicePaths(deviceId:String, deviceType:MobileType = .Android) -> [ImageDevicePath] {
        var result:[ImageDevicePath] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageDevicePath.filter(sql: "deviceId='\(deviceId)'").order(Column("path").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        if result.count == 0 {
            if deviceType == .Android {
                result = [
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/DCIM/Camera/", toSubFolder: "Camera"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/tencent/MicroMsg/Weixin/", toSubFolder: "WeChat"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/tencent/QQ_Images/", toSubFolder: "QQ"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/tencent/QQ_Video/", toSubFolder: "QQ"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/Snapseed/", toSubFolder: "Snapseed"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/Pictures/Instagram/", toSubFolder: "Instagram")
                ]
            }else {
                result = [
                    ImageDevicePath.include(deviceId: deviceId, path: "/DCIM/", toSubFolder: "Camera")
                ]
            }
            for devicePath in result {
                ModelStore.default.saveDevicePath(file: devicePath)
            }
        }
        return result
    }
    
    // MARK: FAMILY
    
    func getFamilies() -> [Family] {
        var result:[Family] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Family.order(sql: "name asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getFamilies(peopleId:String) -> [String] {
        var result:[String] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT familyId FROM FamilyMember WHERE peopleId='\(peopleId)'")
                for row in rows {
                    if let id = row["familyId"] as String? {
                        result.append(id)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func saveFamilyMember(peopleId:String, familyId:String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                let rows = try Row.fetchAll(db, "SELECT familyId,peopleId FROM FamilyMember WHERE familyId='\(familyId)' AND peopleId='\(peopleId)'")
                if rows.count == 0 {
                    try db.execute("INSERT INTO FamilyMember (familyId, peopleId) VALUES ('\(familyId)','\(peopleId)')")
                }
            }
        }catch{
            print(error)
        }
    }
    
    func deleteFamilyMember(peopleId:String, familyId:String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("DELETE FROM FamilyMember WHERE familyId='\(familyId)' AND peopleId='\(peopleId)'")
            }
        }catch{
            print(error)
        }
    }
    
    func saveFamily(familyId:String?=nil, name:String, type:String) -> String? {
        var recordId:String? = ""
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                var needInsert = false
                if let id = familyId {
                    let rows = try Row.fetchAll(db, "SELECT id FROM Family WHERE id='\(id)'")
                    if rows.count > 0 {
                        recordId = id
                        try db.execute("UPDATE Family SET name='\(name)',category='\(type)' WHERE id='\(id)'")
                    }else{
                        needInsert = true
                    }
                }else{
                    needInsert = true
                }
                if needInsert {
                    recordId = UUID().uuidString
                    try db.execute("INSERT INTO Family (id, name, category) VALUES ('\(recordId!)','\(name)','\(type)')")
                }
            }
        }catch{
            print(error)
            recordId = nil
        }
        return recordId
    }
    
    func deleteFamily(id:String){
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("DELETE FROM FamilyMember WHERE familyId='\(id)'")
                try db.execute("DELETE FROM FamilyJoint WHERE smallFamilyId='\(id)'")
                try db.execute("DELETE FROM FamilyJoint WHERE bigFamilyId='\(id)'")
                try db.execute("DELETE FROM Family WHERE id='\(id)'")
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: RELATIONSHIP
    
    func getRelationship(primary:String, secondary:String) -> (String, String) {
        var value1 = ""
        var value2 = ""
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows1 = try Row.fetchAll(db, "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(primary)' AND object='\(secondary)'")
                if rows1.count > 0, let callName = rows1[0]["callName"] {
                    value1 = "\(callName)"
                }
                
                let rows2 = try Row.fetchAll(db, "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(secondary)' AND object='\(primary)'")
                if rows2.count > 0, let callName = rows2[0]["callName"] {
                    value2 = "\(callName)"
                }
            }
        }catch{
            print(error)
        }
        return (value1, value2)
    }
    
    func getRelationships(peopleId:String) -> [[String:String]] {
        var result:[[String:String]] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(peopleId)' OR object='\(peopleId)'")
                for row in rows {
                    if let primary = row["subject"] as String?,
                        let secondary = row["object"] as String?,
                        let callName = row["callName"] as String? {
                        var dict:[String:String] = [:]
                        dict["primary"] = primary
                        dict["secondary"] = secondary
                        dict["callName"] = callName
                        result.append(dict)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func saveRelationship(primary:String, secondary:String, callName:String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                let rows = try Row.fetchAll(db, "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(primary)' AND object='\(secondary)'")
                if rows.count > 0 {
                    try db.execute("UPDATE PeopleRelationship SET callName='\(callName)' WHERE subject='\(primary)' AND object='\(secondary)'")
                }else{
                    try db.execute("INSERT INTO PeopleRelationship (subject, object, callName) VALUES ('\(primary)','\(secondary)','\(callName)')")
                }
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: PEOPLE
    
    func getPeople() -> [People] {
        var obj:[People] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                obj = try People.order(sql: "name asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return obj
    }
    
    func getPeople(except:String) -> [People] {
        var obj:[People] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                obj = try People.filter(sql: "id <> '\(except)'").order(sql: "name asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return obj
    }
    
    func getPerson(id: String) -> People? {
        var obj:People?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                obj = try People.fetchOne(db, key: id)
            }
            return obj
        }catch{
            print(error)
        }
        return nil
    }
    
    func savePersonName(id:String, name:String, shortName:String) {
        var person = People.new(id: id, name: name, shortName: shortName)
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try person.save(db)
            }
        }catch{
            print(error)
        }
    }
    
    func updatePersonIconImage(id:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> Bool{
        if let person = getPerson(id: id) {
            var ps = person
            ps.iconRepositoryPath = repositoryPath
            ps.iconCropPath = cropPath
            ps.iconSubPath = subPath
            ps.iconFilename = filename
            do {
                let db = ModelStore.sharedDBPool()
                try db.write { db in
                    try ps.save(db)
                }
                return true
            }catch{
                print(error)
                return false
            }
        }else{
            return false
        }
    }
    
    func deletePerson(id:String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("update ImageFace set peopleId = '', peopleAge = 0 where peopleId = ?", arguments: [id])
                try db.execute("delete from People where id = ?", arguments: [id])
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: FACE
    
    func getFace(id: String) -> ImageFace? {
        var obj:ImageFace?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                obj = try ImageFace.fetchOne(db, key: id)
            }
            return obj
        }catch{
            print(error)
        }
        return nil
    }
    
    func getFaceCrops(imageId: String) -> [ImageFace] {
        var result:[ImageFace] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageFace.filter(sql: "imageId='\(imageId)'").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func findFaceCrop(imageId: String, x:String, y:String, width:String, height:String) -> ImageFace? {
        var obj:ImageFace?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                obj = try ImageFace.filter(sql: "imageId='\(imageId)' and faceX='\(x)' and faceY='\(y)' and faceWidth='\(width)' and faceHeight='\(height)'").fetchOne(db)
            }
            return obj
        }catch{
            print(error)
        }
        return nil
    }
    
    func getYearsOfFaceCrops(peopleId:String) -> [String]{
        let condition = peopleId == "Unknown" || peopleId == "" ? "peopleId is null or peopleId='' or peopleId='Unknown'" : "peopleId='\(peopleId)'"
        var results:[String] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT imageYear FROM ImageFace WHERE \(condition)")
                for row in rows {
                    if let value = row["imageYear"] as Int? {
                        results.append("\(value)")
                    }
                }
            }
        }catch{
            print(error)
        }
        return results.sorted().reversed()
    }
    
    func getMonthsOfFaceCrops(peopleId:String, imageYear:String) -> [String]{
        let condition = peopleId == "Unknown" || peopleId == "" ? "(peopleId is null or peopleId='' or peopleId='Unknown')" : "peopleId='\(peopleId)'"
        var results:[String] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT imageMonth FROM ImageFace WHERE imageYear=\(imageYear) and \(condition)")
                for row in rows {
                    if let value = row["imageMonth"] as Int? {
                        results.append("\(value)")
                    }
                }
            }
        }catch{
            print(error)
        }
        return results.sorted().reversed()
    }
    
    func getFaceCrops(peopleId:String, year:Int? = nil, month:Int? = nil, sample:Bool? = nil, icon:Bool? = nil, tag:Bool? = nil, locked:Bool? = nil) -> [ImageFace]{
        var sql = ""
        if peopleId != "" && peopleId != "Unknown" {
            sql = "peopleId='\(peopleId)'"
        }else{
            sql = "(peopleId is null or peopleId='Unknown' or peopleId='')"
        }
        if let year = year {
            sql = "\(sql) and imageYear=\(year)"
        }
        if let month = month {
            sql = "\(sql) and imageMonth=\(month)"
        }
        if let sample = sample {
            sql = "\(sql) and sampleChoice=\(sample ? 1 : 0)"
        }
        if let icon = icon {
            sql = "\(sql) and iconChoice=\(icon ? 1 : 0)"
        }
        if let tag = tag {
            sql = "\(sql) and tagOnly=\(tag ? 1 : 0)"
        }
        if let locked = locked {
            sql = "\(sql) and locked=\(locked ? 1 : 0)"
        }
        var result:[ImageFace] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try ImageFace.filter(sql: sql).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func saveFaceCrop(_ face:ImageFace) {
        var f = face
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try f.save(db)
            }
        }catch{
            print(error)
        }
    }
    
    func updateFaceIconFlag(id:String, peopleId:String) {
        if let face = self.getFace(id: id) {
            do {
                let db = ModelStore.sharedDBPool()
                try db.write { db in
                    try db.execute("update ImageFace set iconChoice = 0 where peopleId = ? and iconChoice = 1", arguments: [peopleId])
                    try db.execute("update ImageFace set iconChoice = 1 where peopleId = ? and id = ?", arguments: [peopleId, id])
                    try db.execute("update People set iconRepositoryPath = ?, iconCropPath = ?, iconSubPath = ?, iconFilename = ? WHERE id = ?", arguments: [face.repositoryPath, face.cropPath, face.subPath, face.filename, peopleId]);
                }
            }catch{
                print(error)
            }
        }
    }
    
    func removeFaceIcon(peopleId:String) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("update ImageFace set iconChoice = 0 where peopleId = ? and iconChoice = 1", arguments: [peopleId])
                try db.execute("update People set iconRepositoryPath = '', iconCropPath = '', iconSubPath = '', iconFilename = '' WHERE id = ?", arguments: [peopleId]);
            }
        }catch{
            print(error)
        }
    }
    
    func updateFaceSampleFlag(id:String, flag:Bool) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("update ImageFace set sampleChoice = \(flag ? 1 : 0), sampleChangeDate = ? where id = ?", arguments: [Date(), id])
            }
        }catch{
            print(error)
        }
    }
    
    func updateFaceTagFlag(id:String, flag:Bool) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("update ImageFace set tagOnly = \(flag ? 1 : 0) where id = ?", arguments: [id])
            }
        }catch{
            print(error)
        }
    }
    
    func updateFaceLockFlag(id:String, flag:Bool) {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("update ImageFace set locked = \(flag ? 1 : 0) where id = ?", arguments: [id])
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: SCHEMA VERSION MIGRATION
    
    fileprivate func versionCheck(){
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1") { db in
            try db.create(table: "ImageEvent", body: { t in
                t.column("name", .text).primaryKey().unique().notNull()
                t.column("startDate", .datetime)
                t.column("startYear", .integer)
                t.column("startMonth", .integer)
                t.column("startDay", .integer)
                t.column("endDate", .datetime)
                t.column("endYear", .integer)
                t.column("endMonth", .integer)
                t.column("endDay", .integer)
            })
            
            try db.create(table: "ImagePlace", body: { t in
                t.column("name", .text).primaryKey().unique().notNull()
                t.column("latitude", .text)
                t.column("latitudeBD", .text)
                t.column("longitude", .text)
                t.column("longitudeBD", .text)
                t.column("country", .text).indexed()
                t.column("province", .text).indexed()
                t.column("city", .text).indexed()
                t.column("district", .text)
                t.column("businessCircle", .text)
                t.column("street", .text)
                t.column("address", .text)
                t.column("addressDescription", .text)
            })
            
            try db.create(table: "ImageContainer", body: { t in
                t.column("path", .text).primaryKey().unique().notNull()
                t.column("name", .text).indexed()
                t.column("parentFolder", .text).indexed()
                t.column("imageCount", .integer)
            })
            
            try db.create(table: "Image", body: { t in
                t.column("audioBits", .integer)
                t.column("audioChannels", .integer)
                t.column("audioRate", .integer)
                t.column("hidden", .boolean).defaults(to: false).indexed()
                t.column("imageHeight", .integer)
                t.column("imageWidth", .integer)
                t.column("photoTakenDay", .integer).defaults(to: 0).indexed()
                t.column("photoTakenMonth", .integer).defaults(to: 0).indexed()
                t.column("photoTakenYear", .integer).defaults(to: 0).indexed()
                t.column("photoTakenHour", .integer).defaults(to: 0).indexed()
                t.column("rotation", .integer)
                t.column("addDate", .datetime)
                t.column("assignDateTime", .datetime)
                t.column("exifCreateDate", .datetime)
                t.column("exifDateTimeOriginal", .datetime)
                t.column("exifModifyDate", .datetime)
                t.column("exportTime", .datetime)
                t.column("filenameDate", .datetime)
                t.column("filesysCreateDate", .datetime)
                t.column("photoTakenDate", .datetime).indexed()
                t.column("softwareModifiedTime", .datetime)
                t.column("trackCreateDate", .datetime)
                t.column("trackModifyDate", .datetime)
                t.column("updateDateTimeDate", .datetime).indexed()
                t.column("updateEventDate", .datetime).indexed()
                t.column("updateExifDate", .datetime).indexed()
                t.column("updateLocationDate", .datetime).indexed()
                t.column("updatePhotoTakenDate", .datetime).indexed()
                t.column("videoCreateDate", .datetime)
                t.column("videoFrameRate", .double)
                t.column("videoModifyDate", .datetime)
                t.column("address", .text)
                t.column("addressDescription", .text)
                t.column("aperture", .text)
                t.column("assignAddress", .text)
                t.column("assignAddressDescription", .text)
                t.column("assignBusinessCircle", .text)
                t.column("assignCity", .text)
                t.column("assignCountry", .text)
                t.column("assignDistrict", .text)
                t.column("assignLatitude", .text)
                t.column("assignLatitudeBD", .text)
                t.column("assignLongitude", .text)
                t.column("assignLongitudeBD", .text)
                t.column("assignPlace", .text).indexed()
                t.column("assignProvince", .text)
                t.column("assignStreet", .text)
                t.column("businessCircle", .text)
                t.column("cameraMaker", .text).indexed()
                t.column("cameraModel", .text).indexed()
                t.column("city", .text).indexed()
                t.column("containerPath", .text).indexed()
                t.column("country", .text).indexed()
                t.column("datetimeFromFilename", .text)
                t.column("district", .text)
                t.column("event", .text).indexed()
                t.column("exportAsFilename", .text)
                t.column("exportToPath", .text)
                t.column("exposureTime", .text)
                t.column("fileSize", .text)
                t.column("filename", .text).indexed()
                t.column("gpsDate", .text)
                t.column("hideForSourceFilename", .text).indexed()
                t.column("imageSource", .text).indexed()
                t.column("iso", .text)
                t.column("latitude", .text)
                t.column("latitudeBD", .text)
                t.column("longitude", .text)
                t.column("longitudeBD", .text)
                t.column("path", .text).primaryKey().unique().notNull()
                t.column("photoDescription", .text)
                t.column("place", .text).indexed()
                t.column("province", .text).indexed()
                t.column("softwareName", .text).indexed()
                t.column("street", .text)
                t.column("suggestPlace", .text)
                t.column("videoBitRate", .text)
                t.column("videoDuration", .text)
                t.column("videoFormat", .text)
            })
        }
        
        migrator.registerMigration("v2") { db in
            try db.create(table: "ImageDevice", body: { t in
                t.column("deviceId", .text).primaryKey().unique().notNull()
                t.column("type", .text)
                t.column("manufacture", .text)
                t.column("model", .text)
                t.column("name", .text)
                t.column("storagePath", .text)
            })
            
            try db.create(table: "ImageDeviceFile", body: { t in
                t.column("fileId", .text).primaryKey().unique().notNull() // deviceId:/path/filename.jpg
                t.column("deviceId", .text)
                t.column("filename", .text)
                t.column("path", .text)
                t.column("fileDateTime", .text)
                t.column("fileSize", .text)
                t.column("fileMD5", .text)
                t.column("importDate", .text)
                t.column("importToPath", .text)
                t.column("importAsFilename", .text)
            })
        }
        
        migrator.registerMigration("v3") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "shortDescription", .text)
                t.add(column: "longDescription", .text)
                t.add(column: "originalMD5", .text)
                t.add(column: "exportedMD5", .text)
                t.add(column: "exportedLongDescription", .text)
                t.add(column: "exportState", .text)
                t.add(column: "exportFailMessage", .text)
            })
            
            try db.alter(table: "ImageDevice", body: { t in
                t.add(column: "marketName", .text)
            })
        }
        
        migrator.registerMigration("v4") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "delFlag", .boolean)
            })
        }
        
        migrator.registerMigration("v5") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "duplicatesKey", .text)
            })
        }
        
        migrator.registerMigration("v6") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "repositoryPath", .text).notNull().defaults(to: "")
            })
            
            try db.alter(table: "ImageDevice", body: { t in
                t.add(column: "repositoryPath", .text)
            })
            try db.alter(table: "Image", body: { t in
                t.add(column: "originPath", .text)
                t.add(column: "facesPath", .text)
                t.add(column: "id", .text)
            })
            
            try db.create(table: "People", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("name", .text).notNull().indexed()
                t.column("shortName", .text).indexed()
            })
            try db.create(table: "PeopleRelationship", body: { t in
                t.column("subject", .text).notNull().indexed()
                t.column("object", .text).notNull().indexed()
                t.column("callName", .text).notNull()
            })
            try db.create(table: "Family", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("name", .text).notNull().indexed()
                t.column("category", .text).indexed()
            })
            try db.create(table: "FamilyMember", body: { t in
                t.column("familyId", .text).notNull().indexed()
                t.column("peopleId", .text).notNull().indexed()
            })
            try db.create(table: "FamilyJoint", body: { t in
                t.column("bigFamilyId", .text).notNull().indexed()
                t.column("smallFamilyId", .text).notNull().indexed()
            })
            try db.create(table: "ImagePeople", body: { t in
                t.column("imageId", .text).notNull().indexed()
                t.column("peopleId", .text).notNull().indexed()
                t.column("position", .text)
            })
        }
        
        migrator.registerMigration("v7") { db in
            try db.alter(table: "ImageDeviceFile", body: { t in
                t.add(column: "localFilePath", .text)
            })
        }
        
        migrator.registerMigration("v8") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "homePath", .text).notNull().defaults(to: "")
                t.add(column: "storagePath", .text).notNull().defaults(to: "")
                t.add(column: "facePath", .text).notNull().defaults(to: "")
                t.add(column: "cropPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v9") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "subPath", .text).notNull().defaults(to: "")
            })
            try db.alter(table: "Image", body: { t in
                t.add(column: "subPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v10") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "parentPath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v11") { db in
            try db.alter(table: "ImageDevice", body: { t in
                t.add(column: "homePath", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v12") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "hiddenByRepository", .boolean).defaults(to: false).indexed()
                t.add(column: "hiddenByContainer", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v13") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "repositoryPath", .text).defaults(to: "").indexed()
            })
        }
        
        migrator.registerMigration("v14") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "hiddenByRepository", .boolean).defaults(to: false).indexed()
                t.add(column: "hiddenByContainer", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v15") { db in
            try db.create(table: "ImageDevicePath", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("deviceId", .text).notNull().indexed()
                t.column("path", .text).notNull().indexed()
                t.column("toSubFolder", .text).notNull()
                t.column("exclude", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v16") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "deviceId", .text).defaults(to: "")
            })
        }
        
        migrator.registerMigration("v17") { db in
            try db.create(table: "ImageFace", body: { t in
                t.column("id", .text).primaryKey().unique().notNull()
                t.column("imageId", .text).notNull().indexed()
                t.column("imageDate", .datetime)
                t.column("imageYear", .integer).defaults(to: 0)
                t.column("imageMonth", .integer).defaults(to: 0)
                t.column("imageDay", .integer).defaults(to: 0)
                t.column("repositoryPath", .text).notNull().indexed()
                t.column("cropPath", .text).notNull()
                t.column("subPath", .text).notNull()
                t.column("filename", .text).notNull()
                t.column("peopleId", .text)
                t.column("peopleAge", .integer).defaults(to: 0).indexed()
                t.column("recognizeBy", .text)
                t.column("recognizeVersion", .text)
                t.column("recognizeDate", .datetime)
                t.column("sampleChoice", .boolean).defaults(to: false).indexed()
                t.column("faceX", .text).defaults(to: "")
                t.column("faceY", .text).defaults(to: "")
                t.column("faceWidth", .text).defaults(to: "")
                t.column("faceHeight", .text).defaults(to: "")
                t.column("frameX", .text).defaults(to: "")
                t.column("frameY", .text).defaults(to: "")
                t.column("frameWidth", .text).defaults(to: "")
                t.column("frameHeight", .text).defaults(to: "")
                t.column("iconChoice", .boolean).defaults(to: false).indexed()
                t.column("tagOnly", .boolean).defaults(to: false).indexed()
                t.column("remark", .text).defaults(to: "")
            })
            
            
            try db.alter(table: "People", body: { t in
                t.add(column: "iconRepositoryPath", .text).notNull().defaults(to: "")
                t.add(column: "iconCropPath", .text).notNull().defaults(to: "")
                t.add(column: "iconSubPath", .text).notNull().defaults(to: "")
                t.add(column: "iconFilename", .text).notNull().defaults(to: "")
            })
        }
        
        migrator.registerMigration("v18") { db in
            try db.alter(table: "ImageFace", body: { t in
                t.add(column: "sampleChangeDate", .date)
            })
        }
        
        migrator.registerMigration("v19") { db in
            try db.alter(table: "ImageFace", body: { t in
                t.add(column: "locked", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v20") { db in
            try db.alter(table: "Image", body: { t in
                t.add(column: "scanedFace", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v21") { db in
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "manyChildren", .boolean).defaults(to: false).indexed()
            })
        }
        
        migrator.registerMigration("v22") { db in
            try db.alter(table: "ImageDevicePath", body: { t in
                t.add(column: "manyChildren", .boolean).defaults(to: false).indexed()
            })
            try db.alter(table: "ImageContainer", body: { t in
                t.add(column: "hideByParent", .boolean).defaults(to: false).indexed()
            })
        }
        
        
        do {
            let dbQueue = try DatabaseQueue(path: dbfile)
            try migrator.migrate(dbQueue)
        }catch{
            print(error)
        }
    }
    
    // MARK: DATA MIGRATION FROM CORE DATA
    
    func checkDatabase() {
        let dbpath = URL(fileURLWithPath: dbfile).deletingLastPathComponent().path
        if !FileManager.default.fileExists(atPath: dbpath) {
            do {
                try FileManager.default.createDirectory(atPath: dbpath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Unable to create directory for database file")
                print(error)
            }
        }
    }
    
    func checkData(){
        
        do {
            let dbQueue = try DatabaseQueue(path: dbfile)
            var containerCount:Int = -1
            var eventCount:Int = -1
            var placeCount:Int = -1
            var imageCount:Int = -1
            var cdContainer:Bool = false
            var cdEvent:Bool = false
            var cdPlace:Bool = false
            var cdImage:Bool = false
            try dbQueue.read { db in
                cdContainer = try db.tableExists("ZCONTAINERFOLDER")
                cdEvent = try db.tableExists("ZPHOTOEVENT")
                cdPlace = try db.tableExists("ZPHOTOPLACE")
                cdImage = try db.tableExists("ZPHOTOFILE")
                if cdContainer {
                    containerCount = try ImageContainer.fetchCount(db)
                }
                if cdEvent {
                    eventCount = try ImageEvent.fetchCount(db)
                }
                if cdPlace {
                    placeCount = try ImagePlace.fetchCount(db)
                }
                if cdImage {
                    imageCount = try Image.fetchCount(db)
                }
            }
            
            if containerCount == 0 {
                self.cloneImageContainersFromCoreDate()
            }
            
            if eventCount == 0 {
                self.cloneImageEventsFromCoreDate()
            }
            
            if placeCount == 0 {
                self.cloneImagePlacesFromCoreDate()
            }
            
            if imageCount == 0 {
                self.cloneImagesFromCoreDate()
            }
            
            
        }catch{
            print(error)
        }
    }
    
    fileprivate func cloneImageContainersFromCoreDate(){
        do {
            let dbQueue = try DatabaseQueue(path: dbfile)
            try dbQueue.write { db in
                try db.execute("INSERT INTO ImageContainer (PATH, NAME, PARENTFOLDER, IMAGECOUNT) SELECT ZPATH, ZNAME, ZPARENTFOLDER, ZIMAGECOUNT FROM ZCONTAINERFOLDER")
            }
        }catch{
            print(error)
        }
    }
    
    fileprivate func cloneImageEventsFromCoreDate(){
        do {
            let dbQueue = try DatabaseQueue(path: dbfile)
            try dbQueue.write { db in
                try db.execute("""
INSERT INTO ImageEvent (NAME, STARTDATE, STARTYEAR, STARTMONTH, STARTDAY, ENDDATE,ENDYEAR, ENDMONTH, ENDDAY)
SELECT ZNAME, DATETIME(ZSTARTDATE + 978307200, 'unixepoch'), ZSTARTYEAR, ZSTARTMONTH, ZSTARTDAY,
DATETIME(ZENDDATE + 978307200, 'unixepoch'),ZENDYEAR, ZENDMONTH, ZENDDAY FROM ZPHOTOEVENT
""")
            }
        }catch{
            print(error)
        }
    }
    
    fileprivate func cloneImagePlacesFromCoreDate(){
        do {
            let dbQueue = try DatabaseQueue(path: dbfile)
            try dbQueue.write { db in
                try db.execute("INSERT INTO ImagePlace (NAME, LATITUDE, LATITUDEBD, LONGITUDE, LONGITUDEBD, COUNTRY, PROVINCE, CITY, DISTRICT, BUSINESSCIRCLE, STREET, ADDRESS, ADDRESSDESCRIPTION) SELECT ZNAME, ZLATITUDE, ZLATITUDEBD, ZLONGITUDE, ZLONGITUDEBD, ZCOUNTRY, ZPROVINCE, ZCITY, ZDISTRICT, ZBUSINESSCIRCLE, ZSTREET, ZADDRESS, ZADDRESSDESCRIPTION FROM ZPHOTOPLACE ORDER BY ZCOUNTRY,ZPROVINCE,ZCITY,ZNAME")
            }
        }catch{
            print(error)
        }
    }
    
    fileprivate func cloneImagesFromCoreDate(){
        do {
            let dbQueue = try DatabaseQueue(path: dbfile)
            try dbQueue.write { db in
                try db.execute("""
INSERT INTO Image (addDate, address, addressDescription, aperture, assignAddress, assignAddressDescription, assignBusinessCircle, assignCity, assignCountry, assignDateTime, assignDistrict, assignLatitude, assignLatitudeBD, assignLongitude, assignLongitudeBD, assignPlace, assignProvince, assignStreet, audioBits, audioChannels, audioRate, businessCircle, cameraMaker, cameraModel, city, containerPath, country, dateTimeFromFilename, district, event, exifCreateDate, exifDateTimeOriginal, exifModifyDate, exportAsFilename, exportTime, exportToPath, exposureTime, filename, filenameDate, fileSize, filesysCreateDate, gpsDate, hidden, hideForSourceFilename, imageHeight, imageSource, imageWidth, iso, latitude, latitudeBD, longitude, longitudeBD, path, photoDescription, photoTakenDate, photoTakenDay, photoTakenHour, photoTakenMonth, photoTakenYear, place, province, rotation, softwareModifiedTime, softwareName, street, suggestPlace, trackCreateDate, trackModifyDate, updateDateTimeDate, updateEventDate, updateExifDate, updateLocationDate, updatePhotoTakenDate, videoBitRate, videoCreateDate, videoDuration, videoFormat, videoFrameRate, videoModifyDate)
SELECT
DATETIME(zaddDate + 978307200, 'unixepoch'),
zaddress, zaddressDescription, zaperture, zassignAddress, zassignAddressDescription, zassignBusinessCircle, zassignCity, zassignCountry, zassignDateTime, zassignDistrict, zassignLatitude, zassignLatitudeBD, zassignLongitude, zassignLongitudeBD, zassignPlace, zassignProvince, zassignStreet, zaudioBits, zaudioChannels, zaudioRate, zbusinessCircle, zcameraMaker, zcameraModel, zcity, zcontainerPath, zcountry,zdateTimeFromFilename,zdistrict, zevent,
DATETIME(zexifCreateDate + 978307200, 'unixepoch'),
DATETIME(zexifDateTimeOriginal + 978307200, 'unixepoch'),
DATETIME(zexifModifyDate + 978307200, 'unixepoch'),
zexportAsFilename,
DATETIME(zexportTime + 978307200, 'unixepoch'),
zexportToPath, zexposureTime, zfilename,
DATETIME(zfilenameDate + 978307200, 'unixepoch'),
zfileSize,
DATETIME(zfilesysCreateDate + 978307200, 'unixepoch'),
zgpsDate,
IFNULL(zhidden,0),
zhideForSourceFilename, zimageHeight, zimageSource, zimageWidth, ziso, zlatitude, zlatitudeBD, zlongitude, zlongitudeBD, zpath, zphotoDescription,
DATETIME(zphotoTakenDate + 978307200, 'unixepoch'),
zphotoTakenDay, zphotoTakenHour, zphotoTakenMonth, zphotoTakenYear, zplace, zprovince, zrotation,
DATETIME(zsoftwareModifiedTime + 978307200, 'unixepoch'),
zsoftwareName, zstreet, zsuggestPlace,
DATETIME(ztrackCreateDate + 978307200, 'unixepoch'),
DATETIME(ztrackModifyDate + 978307200, 'unixepoch'),
DATETIME(zupdateDateTimeDate + 978307200, 'unixepoch'),
DATETIME(zupdateEventDate + 978307200, 'unixepoch'),
DATETIME(zupdateExifDate + 978307200, 'unixepoch'),
DATETIME(zupdateLocationDate + 978307200, 'unixepoch'),
DATETIME(zupdatePhotoTakenDate + 978307200, 'unixepoch'),
zvideoBitRate,
DATETIME(zvideoCreateDate + 978307200, 'unixepoch'),
zvideoDuration, zvideoFormat, zvideoFrameRate,
DATETIME(zvideoModifyDate + 978307200, 'unixepoch')
FROM ZPHOTOFILE order by zpath
""")
            }
        }catch{
            print(error)
        }
    }
}
