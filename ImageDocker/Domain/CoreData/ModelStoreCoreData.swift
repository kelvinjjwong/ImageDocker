//
//  ModelStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/21.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import CoreData


/*
class ModelStoreCoreData {
    
    static func save() {
        //print("saving model store")
        let moc = AppDelegate.current.managedObjectContext
        moc.commitEditing()
        if moc.hasChanges {
            do {
                try moc.save()
            } catch {
                print(error)
                //NSApplication.shared.presentError(nserror)
            }
        }
        
    }
    
    static var _duplicates:Duplicates? = nil
    
    static func reloadDuplicatePhotos(in moc : NSManagedObjectContext? = nil) {
        print("\(Date()) Loading duplicate photos from db")
        let duplicates:Duplicates = Duplicates()
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append("photoTakenYear" as AnyObject)
        expressionDescriptions.append("photoTakenMonth" as AnyObject)
        expressionDescriptions.append("photoTakenDay" as AnyObject)
        expressionDescriptions.append("photoTakenDate" as AnyObject)
        expressionDescriptions.append("place" as AnyObject)
        
        let keypathExp = NSExpression(forKeyPath: "path") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "photoCount"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        expressionDescriptions.append(expressionDescription)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoFile")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["photoTakenDate", "place", "photoTakenDay", "photoTakenMonth", "photoTakenYear"]
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = expressionDescriptions
        
        var results:[[String:AnyObject]]?
        
        // Perform the fetch. This is using Swfit 2, so we need a do/try/catch
        do {
            results = try moc.fetch(request) as? [[String:AnyObject]]
            //print(results)
        } catch _ {
            // If it fails, ensure the array is nil
            results = nil
        }
        
        var dupDates:[NSDate] = []
        if results != nil {
            for row in results! {
                let count:Int = row["photoCount"] as! Int
                if count == 1 {
                    continue
                }
                if row["photoTakenDate"] == nil {
                    continue
                }
                let dup:Duplicate = Duplicate()
                dup.year = row["photoTakenYear"] as! Int
                dup.month = row["photoTakenMonth"] as! Int
                dup.day = row["photoTakenDay"] as! Int
                dup.date = row["photoTakenDate"] as! Date
                dup.place = row["place"] as! String? ?? ""
                //dup.event = row["event"] as! String? ?? ""
                duplicates.duplicates.append(dup)
                
                let monthString = dup.month < 10 ? "0\(dup.month)" : "\(dup.month)"
                let dayString = dup.day < 10 ? "0\(dup.day)" : "\(dup.day)"
                let category:String = "\(dup.year)年\(monthString)月\(dayString)日"
                
                if duplicates.categories.index(where: {$0 == category}) == nil {
                    duplicates.categories.append(category)
                }
                
                dupDates.append(dup.date as NSDate)
            }
        }
        
        var firstPhotoInPlaceAndDate:[String:String] = [:]
        var dupPhotos:Set<String> = []
        print("\(Date()) Marking duplicate tag to photo files")
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "photoTakenDate in %@", dupDates)
        if let photosInSameDate = try? moc.fetch(req) {
            for photo in photosInSameDate {
                if photo.photoTakenYear == 0 {
                    continue
                }
                let key = "\(photo.place ?? "")_\(photo.photoTakenYear)_\(photo.photoTakenMonth)_\(photo.photoTakenDay)"
                if let first = firstPhotoInPlaceAndDate[key] {
                    // duplicates
                    dupPhotos.insert(first)
                    dupPhotos.insert(photo.path ?? "")
                }else{
                    firstPhotoInPlaceAndDate[key] = photo.path ?? ""
                }
            }
        }
        duplicates.paths = dupPhotos.sorted()
        /*
        for dup in duplicates.duplicates {
            if dup.year == 0 {
                continue
            }
            let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
            req.predicate = NSPredicate(format: "photoTakenDate == %@ && place == %@", dup.date as NSDate, dup.place)
            if let photos = try? moc.fetch(req) {
                for photo in photos {
                    duplicates.paths.append(photo.path ?? "")
                }
            }
        }
 */
        print("\(Date()) Marking duplicate tag to photo files: DONE")
        
        _duplicates = duplicates
        print("\(Date()) Loading duplicate photos from db: DONE")
    }
    
    static func getDuplicatePhotos() -> Duplicates {
        if _duplicates == nil {
            reloadDuplicatePhotos()
        }
        return _duplicates!
    }
    
    
    
    static func getAllContainerPaths(in moc : NSManagedObjectContext? = nil) -> [[String:AnyObject]]? {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append("containerPath" as AnyObject)
        
        let keypathExp = NSExpression(forKeyPath: "path") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "photoCount"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        expressionDescriptions.append(expressionDescription)
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoFile")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["containerPath"]
        request.resultType = .dictionaryResultType
        request.sortDescriptors = [
            NSSortDescriptor(key: "containerPath", ascending: true)
        ]
        request.propertiesToFetch = expressionDescriptions
        
        
        var results:[[String:AnyObject]]?
        
        // Perform the fetch. This is using Swfit 2, so we need a do/try/catch
        do {
            results = try moc.fetch(request) as? [[String:AnyObject]]
            //print(results)
        } catch _ {
            // If it fails, ensure the array is nil
            results = nil
        }
        
        return results
        
    }
    
    static func getImageSources() -> [String:Bool]{
        return listPhotoFileField(field: "imageSource")
    }
    
    static func getCameraModel() -> [String:Bool] {
        return listPhotoFile2Fields(field1: "cameraMaker", field2: "cameraModel")
    }
    
    static func listPhotoFileField(field:String, in moc : NSManagedObjectContext? = nil) -> [String:Bool] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append(field as AnyObject)
        
        let keypathExp = NSExpression(forKeyPath: "path") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "photoCount"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        expressionDescriptions.append(expressionDescription)
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoFile")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = [field]
        request.resultType = .dictionaryResultType
        request.sortDescriptors = [
            NSSortDescriptor(key: field, ascending: true)
        ]
        request.propertiesToFetch = expressionDescriptions
        
        var results:[String:Bool] = [:]
        var records:[[String:AnyObject]]?
        
        // Perform the fetch. This is using Swfit 2, so we need a do/try/catch
        do {
            records = try moc.fetch(request) as? [[String:AnyObject]]
            if records != nil {
                for record in records! {
                    if let name = record[field] as? String {
                        results[name] = false
                    }
                }
            }
            //print(results)
        } catch{
            // If it fails, ensure the array is nil
            print(error)
        }
        
        return results
        
    }
    
    static func listPhotoFile2Fields(field1:String, field2:String, in moc : NSManagedObjectContext? = nil) -> [String:Bool] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append(field1 as AnyObject)
        expressionDescriptions.append(field2 as AnyObject)
        
        let keypathExp = NSExpression(forKeyPath: "path") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "photoCount"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        expressionDescriptions.append(expressionDescription)
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoFile")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = [field1, field2]
        request.resultType = .dictionaryResultType
        request.sortDescriptors = [
            NSSortDescriptor(key: field1, ascending: true),
            NSSortDescriptor(key: field2, ascending: true)
        ]
        request.propertiesToFetch = expressionDescriptions
        
        var results:[String:Bool] = [:]
        var records:[[String:AnyObject]]?
        
        // Perform the fetch. This is using Swfit 2, so we need a do/try/catch
        do {
            records = try moc.fetch(request) as? [[String:AnyObject]]
            if records != nil {
                for record in records! {
                    let name1 = record[field1] as? String ?? ""
                    let name2 = record[field2] as? String ?? ""
                    if name1 != "" && name2 != "" {
                        results["\(name1),\(name2)"] = false
                    }
                }
            }
            //print(results)
        } catch{
            // If it fails, ensure the array is nil
            print(error)
        }
        
        return results
        
    }
    
    static func getAllDates(groupByPlace:Bool = false, imageSource:[String]? = nil, cameraModel:[String]? = nil, in moc : NSManagedObjectContext? = nil) -> [[String:AnyObject]]? {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        var expressionDescriptions = [AnyObject]()
        if groupByPlace {
            expressionDescriptions.append("place" as AnyObject)
        }
        expressionDescriptions.append("photoTakenYear" as AnyObject)
        expressionDescriptions.append("photoTakenMonth" as AnyObject)
        expressionDescriptions.append("photoTakenDay" as AnyObject)
        
        let keypathExp = NSExpression(forKeyPath: "path") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "photoCount"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        expressionDescriptions.append(expressionDescription)
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoFile")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["photoTakenDay", "photoTakenMonth", "photoTakenYear"]
        if groupByPlace {
            request.propertiesToGroupBy?.insert("place", at: 0)
        }
        request.resultType = .dictionaryResultType
        request.sortDescriptors = [
            NSSortDescriptor(key: "photoTakenYear", ascending: false),
            NSSortDescriptor(key: "photoTakenMonth", ascending: false),
            NSSortDescriptor(key: "photoTakenDay", ascending: false)
        ]
        if groupByPlace {
            request.sortDescriptors?.insert(NSSortDescriptor(key: "place", ascending: true), at: 0)
        }
        if imageSource != nil && (imageSource?.count)! > 0 && (cameraModel == nil || cameraModel?.count == 0 ) {
            request.predicate = NSPredicate(format: "imageSource in %@", imageSource!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && (imageSource == nil || imageSource?.count == 0 ) {
            request.predicate = NSPredicate(format: "cameraModel in %@", cameraModel!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && imageSource != nil && (imageSource?.count)! > 0 {
            request.predicate = NSPredicate(format: "cameraModel in %@ && imageSource in %@", cameraModel!, imageSource!)
        }
        request.propertiesToFetch = expressionDescriptions
        
        
        var results:[[String:AnyObject]]?
        
        // Perform the fetch. This is using Swfit 2, so we need a do/try/catch
        do {
            results = try moc.fetch(request) as? [[String:AnyObject]]
            //print(results)
        } catch _ {
            // If it fails, ensure the array is nil
            results = nil
        }
        
        return results
        
    }
    
    
    
    static func getAllEvents(imageSource:[String]? = nil, cameraModel:[String]? = nil, in moc : NSManagedObjectContext? = nil) -> [[String:AnyObject]]? {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append("event" as AnyObject)
        expressionDescriptions.append("photoTakenYear" as AnyObject)
        expressionDescriptions.append("photoTakenMonth" as AnyObject)
        expressionDescriptions.append("photoTakenDay" as AnyObject)
        expressionDescriptions.append("place" as AnyObject)
        
        let keypathExp = NSExpression(forKeyPath: "path") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "photoCount"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        expressionDescriptions.append(expressionDescription)
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoFile")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["event","photoTakenDay", "photoTakenMonth", "photoTakenYear", "place"]
        request.resultType = .dictionaryResultType
        request.sortDescriptors = [
            NSSortDescriptor(key: "event", ascending: false),
            NSSortDescriptor(key: "photoTakenYear", ascending: false),
            NSSortDescriptor(key: "photoTakenMonth", ascending: false),
            NSSortDescriptor(key: "photoTakenDay", ascending: false),
            NSSortDescriptor(key: "place", ascending: true)
        ]
        
        if imageSource != nil && (imageSource?.count)! > 0 && (cameraModel == nil || cameraModel?.count == 0 ) {
            request.predicate = NSPredicate(format: "imageSource in %@", imageSource!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && (imageSource == nil || imageSource?.count == 0 ) {
            request.predicate = NSPredicate(format: "cameraModel in %@", cameraModel!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && imageSource != nil && (imageSource?.count)! > 0 {
            request.predicate = NSPredicate(format: "cameraModel in %@ && imageSource in %@", cameraModel!, imageSource!)
        }
        
        request.propertiesToFetch = expressionDescriptions
        
        
        var results:[[String:AnyObject]]?
        
        // Perform the fetch. This is using Swfit 2, so we need a do/try/catch
        do {
            results = try moc.fetch(request) as? [[String:AnyObject]]
            //print(results)
        } catch _ {
            // If it fails, ensure the array is nil
            results = nil
        }
        
        return results
        
    }
    
    static func deletePhoto(atPath path:String, in moc : NSManagedObjectContext? = nil){
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "path == %@", path)
        req.fetchLimit = 1
        let photo = try! moc.fetch(req)
        if photo.count > 0 {
            moc.delete(photo[0])
        }
    }
    
    static func getAllContainers(in moc : NSManagedObjectContext? = nil) -> [ContainerFolder] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<ContainerFolder>(entityName: "ContainerFolder")
        req.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]
        return try! moc.fetch(req)
        
    }
    
    static func getRepositories(in moc : NSManagedObjectContext? = nil) -> [ContainerFolder] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<ContainerFolder>(entityName: "ContainerFolder")
        req.predicate = NSPredicate(format: "parentFolder == '' ")
        req.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]
        return try! moc.fetch(req)
        
    }
    
    static func getPhotoFilesWithoutExif(limit:Int? = nil, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "updateExifDate == nil || photoTakenYear == 0")
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        if limit != nil {
            req.fetchLimit = limit!
        }
        return try! moc.fetch(req)
    }
    
    static func getPhotoFilesWithoutLocation(in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "updateLocationDate == nil")
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getAllPhotoFiles(includeHidden:Bool = true, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        if !includeHidden {
            req.predicate = NSPredicate(format: "hidden == nil || hidden == false")
        }
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getAllPhotoFilesForExporting(after date:Date, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "(hidden == nil || hidden == false) && (updateDateTimeDate > %@ || updateExifDate > %@ || updateLocationDate > %@ || updateEventDate > %@ || exportTime == nil)", date as NSDate, date as NSDate, date as NSDate, date as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getAllPhotoFilesMarkedExported(in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "(hidden == nil || hidden == false) && exportTime != nil")
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getPhotoFiles(parentPath:String, includeHidden:Bool = true,  in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        
        var otherPredicate:String = ""
        if !includeHidden {
            otherPredicate = " && (hidden == nil || hidden == false)"
        }
        req.predicate = NSPredicate(format: "containerPath == %@ \(otherPredicate)", parentPath)
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getPhotoFiles(year:Int, month:Int, day:Int, place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        
        var otherPredicate:String = ""
        if !includeHidden {
            otherPredicate = " && (hidden == nil || hidden == false)"
        }
        
        var basePredicate:NSPredicate? = nil
        
        if place == nil {
            if year == 0 && month == 0 && day == 0 {
                basePredicate = NSPredicate(format: "photoTakenYear == 0 && photoTakenMonth == 0 && photoTakenDay == 0 \(otherPredicate)")
            }else{
                if year == 0 {
                    // no condition
                } else if month == 0 {
                    basePredicate = NSPredicate(format: "photoTakenYear == %@ \(otherPredicate)", NSNumber(value: year))
                } else if day == 0 {
                    basePredicate = NSPredicate(format: "photoTakenYear == %@ && photoTakenMonth == %@ \(otherPredicate)", NSNumber(value: year), NSNumber(value: month))
                } else {
                    basePredicate = NSPredicate(format: "photoTakenYear == %@ && photoTakenMonth == %@ && photoTakenDay == %@ \(otherPredicate)", NSNumber(value: year), NSNumber(value: month), NSNumber(value: day))
                }
            }
        } else {
            if year == 0 && month == 0 && day == 0 {
                basePredicate = NSPredicate(format: "photoTakenYear == 0 && photoTakenMonth == 0 && photoTakenDay == 0 && place == %@ \(otherPredicate)", place!)
            }else{
                if year == 0 {
                    basePredicate = NSPredicate(format: "place == %@ \(otherPredicate)", place!)
                } else if month == 0 {
                    basePredicate = NSPredicate(format: "place == %@ && photoTakenYear == %@ \(otherPredicate)", place!, NSNumber(value: year))
                } else if day == 0 {
                    basePredicate = NSPredicate(format: "place == %@ && photoTakenYear == %@ && photoTakenMonth == %@ \(otherPredicate)", place!, NSNumber(value: year), NSNumber(value: month))
                } else {
                    basePredicate = NSPredicate(format: "place == %@ && photoTakenYear == %@ && photoTakenMonth == %@ && photoTakenDay == %@ \(otherPredicate)", place!, NSNumber(value: year), NSNumber(value: month), NSNumber(value: day))
                }
            }
            
        }
        
        var filterPredicate:NSPredicate? = nil
        
        if imageSource != nil && (imageSource?.count)! > 0 && (cameraModel == nil || cameraModel?.count == 0 ) {
            filterPredicate = NSPredicate(format: "imageSource in %@", imageSource!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && (imageSource == nil || imageSource?.count == 0 ) {
            filterPredicate = NSPredicate(format: "cameraModel in %@", cameraModel!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && imageSource != nil && (imageSource?.count)! > 0 {
            filterPredicate = NSPredicate(format: "cameraModel in %@ && imageSource in %@", cameraModel!, imageSource!)
        }
        
        if filterPredicate == nil {
            req.predicate = basePredicate!
        }else{
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate!, filterPredicate!])
        }
        
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    
    
    static func getPhotoFiles(year:Int, month:Int, day:Int, event:String, place:String, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        
        var otherPredicate:String = ""
        if !includeHidden {
            otherPredicate = " && (hidden == nil || hidden == false)"
        }
        
        var basePredicate:NSPredicate? = nil
        
        if year == 0 {
            basePredicate = NSPredicate(format: "event == %@ \(otherPredicate)", event)
        } else if day == 0 {
            basePredicate = NSPredicate(format: "event == %@ && photoTakenYear == %@ && photoTakenMonth == %@ \(otherPredicate)", event, NSNumber(value: year), NSNumber(value: month))
        } else {
            basePredicate = NSPredicate(format: "event == %@ && photoTakenYear == %@ && photoTakenMonth == %@ && photoTakenDay == %@ && place == %@ \(otherPredicate)", event, NSNumber(value: year), NSNumber(value: month), NSNumber(value: day), place)
        }
        
        var filterPredicate:NSPredicate? = nil
        
        if imageSource != nil && (imageSource?.count)! > 0 && (cameraModel == nil || cameraModel?.count == 0 ) {
            filterPredicate = NSPredicate(format: "imageSource in %@", imageSource!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && (imageSource == nil || imageSource?.count == 0 ) {
            filterPredicate = NSPredicate(format: "cameraModel in %@", cameraModel!)
        }
        if cameraModel != nil && (cameraModel?.count)! > 0 && imageSource != nil && (imageSource?.count)! > 0 {
            filterPredicate = NSPredicate(format: "cameraModel in %@ && imageSource in %@", cameraModel!, imageSource!)
        }
        
        if filterPredicate == nil {
            req.predicate = basePredicate!
        }else{
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate!, filterPredicate!])
        }
        
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getContainers(rootPath:String, in moc : NSManagedObjectContext? = nil) -> [ContainerFolder] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<ContainerFolder>(entityName: "ContainerFolder")
        req.predicate = NSPredicate(format: "path beginswith[c] %@", rootPath)
        return try! moc.fetch(req)
    }
    
    static func getPhotoFiles(rootPath:String, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "path beginswith[c] %@", rootPath)
        return try! moc.fetch(req)
    }
    
    static func getPhotoFiles(after date:Date, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "updateLocationDate >= %@", date as NSDate)
        return try! moc.fetch(req)
    }
    
    static func getOrCreateContainer(name:String, path:String, parentPath:String = "", in moc : NSManagedObjectContext? = nil) -> ContainerFolder {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<ContainerFolder>(entityName: "ContainerFolder")
        req.predicate = NSPredicate(format: "path == %@", path)
        req.fetchLimit = 1
        let exist = try! moc.fetch(req).first
        
        if exist != nil {
            //print("exist container: \(path)")
            return exist!
        }else{
            let container = ContainerFolder(context: moc)
            //let container = NSEntityDescription.insertNewObject(forEntityName: "ContainerFolder", into: moc) as! ContainerFolder
            //save()
            container.name = name
            container.path = path
            container.parentFolder = parentPath
            
            //print("create new container: \(path)")
            save()
            
            return container
        }
    }
    
    static func getOrCreatePhoto(filename:String, path:String, parentPath:String, in moc : NSManagedObjectContext? = nil) -> PhotoFile{
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        fetch.predicate = NSPredicate(format: "path == %@", path)
        fetch.fetchLimit = 1
        var exist:PhotoFile? = nil
        do {
            try exist = moc.fetch(fetch).first
        }catch{
            print(error)
        }
        
        if exist != nil {
            //print("exist photo: \(path)")
            return exist!
        }else{
            let file = PhotoFile(context: moc)
            //let file = NSEntityDescription.insertNewObject(forEntityName: "PhotoFile", into: moc) as! PhotoFile
            //save()
            file.filename = filename
            file.path = path
            file.containerPath = parentPath
            
            //print("create new file: \(path)")
            save()
            
            return file
        }
    }
    
    
    
    static func getEvents(byName names:String? = nil, in moc : NSManagedObjectContext? = nil) -> [PhotoEvent] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoEvent>(entityName: "PhotoEvent")
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            var conditions:[String] = []
            for _ in keys {
                let condition:String = "name CONTAINS[cd] %@"
                conditions.append(condition)
            }
            let format:String = conditions.joined(separator: " || ")
            req.predicate = NSPredicate(format: format, argumentArray: keys)
        }
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try! moc.fetch(req)
    }
    
    
    
    static func getPlaces(byName names:String? = nil, in moc : NSManagedObjectContext? = nil) -> [PhotoPlace] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoPlace>(entityName: "PhotoPlace")
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            var conditions:[String] = []
            for _ in keys {
                let condition:String = "name CONTAINS[cd] %@"
                conditions.append(condition)
            }
            let format:String = conditions.joined(separator: " || ")
            //print(format)
            //for key in keys {
            //    print(key)
            //}
            req.predicate = NSPredicate(format: format, argumentArray: keys)
        }
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getOrCreatePlace(name:String, location:Location, in moc : NSManagedObjectContext? = nil) -> PhotoPlace{
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoPlace>(entityName: "PhotoPlace")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        fetch.fetchLimit = 1
        let exist = try! moc.fetch(fetch).first
        
        if exist != nil {
            //print("exist place")
            return exist!
        }else{
            //print("create place")
            let place = PhotoPlace(context: moc)
            //let place = NSEntityDescription.insertNewObject(forEntityName: "PhotoPlace", into: moc) as! PhotoPlace
            //save()
            place.name = name
            place.latitude = location.coordinate?.latitude.description ?? ""
            place.longitude = location.coordinate?.longitude.description ?? ""
            place.latitudeBD = location.coordinateBD?.latitude.description ?? ""
            place.longitudeBD = location.coordinateBD?.longitude.description ?? ""
            place.country = location.country
            place.province = location.province
            place.city = location.city
            place.businessCircle = location.businessCircle
            place.district = location.district
            place.street = location.street
            place.address = location.address
            place.addressDescription = location.addressDescription
            save()
            
            return place
        }
    }
    
    
    
    static func getPlace(name:String, in moc : NSManagedObjectContext? = nil) -> PhotoPlace? {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoPlace>(entityName: "PhotoPlace")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        fetch.fetchLimit = 1
        let exist = try! moc.fetch(fetch).first
        
        if exist != nil {
            return exist!
        }else{
            return nil
        }
    }
    
    static func renamePlace(oldName:String, newName:String, in moc : NSManagedObjectContext? = nil){
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoPlace>(entityName: "PhotoPlace")
        fetch.predicate = NSPredicate(format: "name == %@", oldName)
        fetch.fetchLimit = 1
        let place = try! moc.fetch(fetch).first
        
        if place != nil {
            place?.name = newName
        }
    }
    
    static func updatePlace(name:String, location:Location, in moc : NSManagedObjectContext? = nil){
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoPlace>(entityName: "PhotoPlace")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        fetch.fetchLimit = 1
        let place = try! moc.fetch(fetch).first
        
        if place != nil {
            place!.latitude = location.coordinate?.latitude.description ?? ""
            place!.longitude = location.coordinate?.longitude.description ?? ""
            place!.latitudeBD = location.coordinateBD?.latitude.description ?? ""
            place!.longitudeBD = location.coordinateBD?.longitude.description ?? ""
            place!.country = location.country
            place!.province = location.province
            place!.city = location.city
            place!.businessCircle = location.businessCircle
            place!.district = location.district
            place!.street = location.street
            place!.address = location.address
            place!.addressDescription = location.addressDescription
        }
    }
    
    static func deletePlace(name:String, in moc : NSManagedObjectContext? = nil){
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoPlace>(entityName: "PhotoPlace")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        fetch.fetchLimit = 1
        let exist = try! moc.fetch(fetch).first
        
        if exist != nil {
            /*
            let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
            req.predicate = NSPredicate(format: "event == %@", name)
            let photos = try! moc.fetch(req)
            
            if photos.count > 0 {
                for photo in photos {
                    photo.event = ""
                }
            }
            */
            moc.delete(exist!)
        }
    }
    
    static func getOrCreateEvent(name:String, in moc : NSManagedObjectContext? = nil) -> PhotoEvent{
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoEvent>(entityName: "PhotoEvent")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        fetch.fetchLimit = 1
        let exist = try! moc.fetch(fetch).first

        if exist != nil {
            //print("exist event")
            return exist!
        }else{
            //print("create event")
            let event = PhotoEvent(context: moc)
            //let event = NSEntityDescription.insertNewObject(forEntityName: "PhotoEvent", into: moc) as! PhotoEvent
            //save()
            event.name = name
            save()
            
            return event
        }
    }
    
    static func deleteEvent(name:String, in moc : NSManagedObjectContext? = nil){
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetch = NSFetchRequest<PhotoEvent>(entityName: "PhotoEvent")
        fetch.predicate = NSPredicate(format: "name == %@", name)
        fetch.fetchLimit = 1
        let exist = try! moc.fetch(fetch).first
        
        if exist != nil {
        
            let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
            req.predicate = NSPredicate(format: "event == %@", name)
            let photos = try! moc.fetch(req)
            
            if photos.count > 0 {
                for photo in photos {
                    photo.event = ""
                }
            }
        
            moc.delete(exist!)
        }
    }
    
    static func renameEvent(oldName:String, newName:String, in moc : NSManagedObjectContext? = nil){
        print("RENAME EVENT \(oldName) to \(newName)")
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let fetchForNewName = NSFetchRequest<PhotoEvent>(entityName: "PhotoEvent")
        fetchForNewName.predicate = NSPredicate(format: "name == %@", newName)
        fetchForNewName.fetchLimit = 1
        let existNewName = try! moc.fetch(fetchForNewName).first
        let existNew:Bool = existNewName != nil && ((existNewName!.name ?? "") == newName)
        print(existNew)
        
        let fetch = NSFetchRequest<PhotoEvent>(entityName: "PhotoEvent")
        fetch.predicate = NSPredicate(format: "name == %@", oldName)
        fetch.fetchLimit = 1
        let exist = try! moc.fetch(fetch).first
        if let existOldName = exist {
            print(existOldName)
            if !existNew {
                print("does not exist new name, change old name to new name")
                existOldName.name = newName
            }else{
                print("exist new name, delete old name")
                moc.delete(existOldName)
            }
        }
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "event == %@", oldName)
        if let photos = try? moc.fetch(req) {
            for photo in photos {
                photo.event = newName
            }
        }
    }
    
}
 */
