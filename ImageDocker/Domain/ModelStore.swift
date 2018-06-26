//
//  ModelStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/21.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import CoreData

class Duplicate {
    
    var year:Int = 0
    var month:Int = 0
    var day:Int = 0
    var date:Date = Date()
    var place:String = ""
    var event:String = ""
    
}

class Duplicates {
    
    var duplicates:[Duplicate] = []
    var categories:[String] = []
    var paths:[String] = []
}

class ModelStore {
    
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
    
    static func getDuplicatePhotos(in moc : NSManagedObjectContext? = nil) -> Duplicates {
        let duplicates:Duplicates = Duplicates()
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        var expressionDescriptions = [AnyObject]()
        expressionDescriptions.append("photoTakenYear" as AnyObject)
        expressionDescriptions.append("photoTakenMonth" as AnyObject)
        expressionDescriptions.append("photoTakenDay" as AnyObject)
        expressionDescriptions.append("photoTakenDate" as AnyObject)
        expressionDescriptions.append("place" as AnyObject)
        expressionDescriptions.append("event" as AnyObject)
        
        let keypathExp = NSExpression(forKeyPath: "path") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "photoCount"
        expressionDescription.expression = expression
        expressionDescription.expressionResultType = .integer64AttributeType
        expressionDescriptions.append(expressionDescription)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoFile")
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = ["photoTakenDate", "event", "place", "photoTakenDay", "photoTakenMonth", "photoTakenYear"]
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
                dup.event = row["event"] as! String? ?? ""
                duplicates.duplicates.append(dup)
                
                let monthString = dup.month < 10 ? "0\(dup.month)" : "\(dup.month)"
                let dayString = dup.day < 10 ? "0\(dup.day)" : "\(dup.day)"
                let category:String = "\(dup.year)年\(monthString)月\(dayString)日"
                
                if duplicates.categories.index(where: {$0 == category}) == nil {
                    duplicates.categories.append(category)
                }
            }
        }
        
        for dup in duplicates.duplicates {
            if dup.year == 0 {
                continue
            }
            let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
            req.predicate = NSPredicate(format: "photoTakenDate == %@ && place == %@", dup.date as NSDate, dup.place)
            let photos = try! moc.fetch(req)
            for photo in photos {
                duplicates.paths.append(photo.path ?? "")
            }
        }
        
        return duplicates
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
    
    static func getAllDates(groupByPlace:Bool = false, in moc : NSManagedObjectContext? = nil) -> [[String:AnyObject]]? {
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
    
    
    
    static func getAllEvents(in moc : NSManagedObjectContext? = nil) -> [[String:AnyObject]]? {
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
        req.predicate = NSPredicate(format: "updateExifDate == nil")
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
    
    static func getPhotoFiles(parentPath:String, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        req.predicate = NSPredicate(format: "containerPath == %@", parentPath)
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    static func getPhotoFiles(year:Int, month:Int, day:Int, place:String?, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        if place == nil {
            if year == 0 && month == 0 && day == 0 {
                req.predicate = NSPredicate(format: "photoTakenYear == 0 && photoTakenMonth == 0 && photoTakenDay == 0")
            }else{
                if year == 0 {
                    // no condition
                } else if month == 0 {
                    req.predicate = NSPredicate(format: "photoTakenYear == %@", NSNumber(value: year))
                } else if day == 0 {
                    req.predicate = NSPredicate(format: "photoTakenYear == %@ && photoTakenMonth == %@", NSNumber(value: year), NSNumber(value: month))
                } else {
                    req.predicate = NSPredicate(format: "photoTakenYear == %@ && photoTakenMonth == %@ && photoTakenDay == %@", NSNumber(value: year), NSNumber(value: month), NSNumber(value: day))
                }
            }
        } else {
            if year == 0 && month == 0 && day == 0 {
                req.predicate = NSPredicate(format: "photoTakenYear == 0 && photoTakenMonth == 0 && photoTakenDay == 0 && place == %@", place!)
            }else{
                if year == 0 {
                    req.predicate = NSPredicate(format: "place == %@", place!)
                } else if month == 0 {
                    req.predicate = NSPredicate(format: "place == %@ && photoTakenYear == %@", place!, NSNumber(value: year))
                } else if day == 0 {
                    req.predicate = NSPredicate(format: "place == %@ && photoTakenYear == %@ && photoTakenMonth == %@", place!, NSNumber(value: year), NSNumber(value: month))
                } else {
                    req.predicate = NSPredicate(format: "place == %@ && photoTakenYear == %@ && photoTakenMonth == %@ && photoTakenDay == %@", place!, NSNumber(value: year), NSNumber(value: month), NSNumber(value: day))
                }
            }
            
        }
        req.sortDescriptors = [NSSortDescriptor(key: "photoTakenDate", ascending: true),
                               NSSortDescriptor(key: "filename", ascending: true)]
        return try! moc.fetch(req)
    }
    
    
    
    static func getPhotoFiles(year:Int, month:Int, day:Int, event:String, place:String, in moc : NSManagedObjectContext? = nil) -> [PhotoFile] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<PhotoFile>(entityName: "PhotoFile")
        if year == 0 {
            req.predicate = NSPredicate(format: "event == %@", event)
        } else if day == 0 {
            req.predicate = NSPredicate(format: "event == %@ && photoTakenYear == %@ && photoTakenMonth == %@", event, NSNumber(value: year), NSNumber(value: month))
        } else {
            req.predicate = NSPredicate(format: "event == %@ && photoTakenYear == %@ && photoTakenMonth == %@ && photoTakenDay == %@ && place == %@", event, NSNumber(value: year), NSNumber(value: month), NSNumber(value: day), place)
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
        
            let container = NSEntityDescription.insertNewObject(forEntityName: "ContainerFolder", into: moc) as! ContainerFolder
            container.name = name
            container.path = path
            container.parentFolder = parentPath
            
            //print("create new container: \(path)")
            
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
        
            let file = NSEntityDescription.insertNewObject(forEntityName: "PhotoFile", into: moc) as! PhotoFile
            file.filename = filename
            file.path = path
            file.containerPath = parentPath
            
            //print("create new file: \(path)")
            
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
            let place = NSEntityDescription.insertNewObject(forEntityName: "PhotoPlace", into: moc) as! PhotoPlace
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
            let event = NSEntityDescription.insertNewObject(forEntityName: "PhotoEvent", into: moc) as! PhotoEvent
            event.name = name
            
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
    
}
