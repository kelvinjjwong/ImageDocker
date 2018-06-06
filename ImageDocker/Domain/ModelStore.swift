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
