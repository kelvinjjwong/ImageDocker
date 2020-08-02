//
//  ExportDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class ExportDao {
    
    private let impl:ExportDaoInterface
    
    init(_ impl:ExportDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ExportDao {
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return ExportDao(ExportDaoGRDB())
        }else{
            return ExportDao(ExportDaoPostgresCK())
        }
    }
    
    // MARK: - PROFILE CRUD
    
    func getOrCreateExportProfile(id:String,
                                  name:String,
                                  directory: String,
                                  repositoryPath: String,
                                  specifyPeople: Bool,
                                  specifyEvent: Bool,
                                  specifyRepository: Bool,
                                  people: String,
                                  events: String,
                                  duplicateStrategy: String,
                                  fileNaming: String,
                                  subFolder: String,
                                  patchImageDescription:Bool,
                                  patchDateTime:Bool,
                                  patchGeolocation:Bool,
                                  specifyFamily:Bool,
                                  family:String
                                  ) -> ExportProfile{
        return self.impl.getOrCreateExportProfile(id: id, name: name, directory: directory, repositoryPath: repositoryPath, specifyPeople: specifyPeople, specifyEvent: specifyEvent, specifyRepository: specifyRepository, people: people, events: events, duplicateStrategy: duplicateStrategy, fileNaming: fileNaming, subFolder: subFolder, patchImageDescription: patchImageDescription, patchDateTime: patchDateTime, patchGeolocation: patchGeolocation, specifyFamily: specifyFamily, family: family)
    }
    
    func updateExportProfile(id:String,
                             name:String,
                             directory: String,
                             duplicateStrategy: String,
                             specifyPeople: Bool,
                             specifyEvent: Bool,
                             specifyRepository: Bool,
                             specifyFamily: Bool,
                             people: String,
                             events: String,
                             repositoryPath: String,
                             family: String,
                             patchImageDescription:Bool,
                             patchDateTime:Bool,
                             patchGeolocation:Bool,
                             fileNaming: String,
                             subFolder: String) -> ExecuteState{
        return self.impl.updateExportProfile(id: id, name: name, directory: directory, duplicateStrategy: duplicateStrategy, specifyPeople: specifyPeople, specifyEvent: specifyEvent, specifyRepository: specifyRepository, specifyFamily: specifyFamily, people: people, events: events, repositoryPath: repositoryPath, family: family, patchImageDescription: patchImageDescription, patchDateTime: patchDateTime, patchGeolocation: patchGeolocation, fileNaming: fileNaming, subFolder: subFolder)
    }
    
    func enableExportProfile(id:String) -> ExecuteState{
        return self.impl.enableExportProfile(id: id)
    }
    
    func disableExportProfile(id:String) -> ExecuteState{
        return self.impl.disableExportProfile(id: id)
    }
    
    func updateExportProfileLastExportTime(id:String) -> ExecuteState{
        return self.impl.updateExportProfileLastExportTime(id: id)
    }
    
    func getExportProfile(id:String) -> ExportProfile? {
        return self.impl.getExportProfile(id: id)
    }
    
    func getAllExportProfiles() -> [ExportProfile] {
        return self.impl.getAllExportProfiles()
    }
    
    func deleteExportProfile(id:String) -> ExecuteState{
        return self.impl.deleteExportProfile(id: id)
    }
    
    // MARK: - SEARCH FOR IMAGES
    
    func getAllExportedImages(includeHidden:Bool = true) -> [Image] {
        return self.impl.getAllExportedImages(includeHidden: includeHidden)
    }
    
    func getAllExportedPhotoFilenames(includeHidden:Bool = true) -> Set<String> {
        return self.impl.getAllExportedPhotoFilenames(includeHidden: includeHidden)
    }
    
    func getAllPhotoFilesForExporting(after date:Date, limit:Int? = nil) -> [Image] {
        return self.impl.getAllPhotoFilesForExporting(after: date, limit: limit)
    }
    
    func getAllPhotoFilesMarkedExported() -> [Image] {
        return self.impl.getAllPhotoFilesMarkedExported()
    }
    
    func countAllPhotoFilesForExporting(after date:Date) -> Int {
        return self.impl.countAllPhotoFilesForExporting(after: date)
    }
    
    // MARK: - EXPORT RECORD LOG
    
    func cleanImageExportTime(path:String) -> ExecuteState {
        return self.impl.cleanImageExportTime(path: path)
    }
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState {
        return self.impl.storeImageOriginalMD5(path: path, md5: md5)
    }
    
    func storeImageExportedMD5(path:String, md5:String) -> ExecuteState {
        return self.impl.storeImageExportedMD5(path: path, md5: md5)
    }
    
    func storeImageExportSuccess(path:String, date:Date, exportToPath:String, exportedFilename:String, exportedMD5:String, exportedLongDescription:String) -> ExecuteState {
        return self.impl.storeImageExportSuccess(path: path, date: date, exportToPath: exportToPath, exportedFilename: exportedFilename, exportedMD5: exportedMD5, exportedLongDescription: exportedLongDescription)
    }
    
    func storeImageExportedTime(path:String, date:Date) -> ExecuteState {
        return self.impl.storeImageExportedTime(path: path, date: date)
    }
    
    func storeImageExportFail(path:String, date:Date, message:String) -> ExecuteState {
        return self.impl.storeImageExportFail(path: path, date: date, message: message)
    }
    
    func cleanImageExportPath(path:String) -> ExecuteState {
        return self.impl.cleanImageExportPath(path: path)
    }
}
