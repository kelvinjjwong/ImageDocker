//
//  ModelStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/21.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import CoreData

class ModelStore {
    
    static func save() {
        //print("saving model store")
        let moc = AppDelegate.current.managedObjectContext
        moc.commitEditing()
        if moc.hasChanges {
            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                print(nserror)
                //NSApplication.shared.presentError(nserror)
            }
        }
        
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
    
    static func getAllContainers(in moc : NSManagedObjectContext? = nil) -> [ContainerFolder] {
        let moc = moc ?? AppDelegate.current.managedObjectContext
        
        let req = NSFetchRequest<ContainerFolder>(entityName: "ContainerFolder")
        req.sortDescriptors = [NSSortDescriptor(key: "path", ascending: true)]
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
            if year == 0 {
                // no condition
            } else if month == 0 {
                req.predicate = NSPredicate(format: "photoTakenYear == %@", NSNumber(value: year))
            } else if day == 0 {
                req.predicate = NSPredicate(format: "photoTakenYear == %@ && photoTakenMonth == %@", NSNumber(value: year), NSNumber(value: month))
            } else {
                req.predicate = NSPredicate(format: "photoTakenYear == %@ && photoTakenMonth == %@ && photoTakenDay == %@", NSNumber(value: year), NSNumber(value: month), NSNumber(value: day))
            }
        } else {
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
        let exist = try! moc.fetch(fetch).first
        
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
}
