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
    
    func getLastExportTime(profile:ExportProfile) -> Date? {
        return self.impl.getLastExportTime(profile: profile)
    }
    
    func getExportedFilename(imageId:String, profileId:String) -> (String?, String?) {
        return self.impl.getExportedFilename(imageId: imageId, profileId: profileId)
    }
    
    func getExportProfile(id:String) -> ExportProfile? {
        return self.impl.getExportProfile(id: id)
    }
    
    func getExportProfile(name:String) -> ExportProfile? {
        return self.impl.getExportProfile(name: name)
    }
    
    func getAllExportProfiles() -> [ExportProfile] {
        return self.impl.getAllExportProfiles()
    }
    
    func deleteExportProfile(id:String) -> ExecuteState{
        return self.impl.deleteExportProfile(id: id)
    }
    
    // MARK: - SEARCH FOR IMAGES
    
    func getImagesForExport(profile:ExportProfile, limit:Int? = nil) -> [Image] {
        return self.impl.getImagesForExport(profile: profile, limit: limit)
    }
    
    func countImagesForExport(profile:ExportProfile) -> Int {
        return self.impl.countImagesForExport(profile: profile)
    }
    
    func getExportedImages(profileId:String) -> [(String, String, String)] {
        return self.impl.getExportedImages(profileId: profileId)
    }
    
    // MARK: - EXPORT RECORD LOG
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState {
        return self.impl.storeImageOriginalMD5(path: path, md5: md5)
    }
    
    func storeImageExportSuccess(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, exportedMD5: String) -> ExecuteState {
        return self.impl.storeImageExportSuccess(imageId: imageId, profileId: profileId, repositoryPath: repositoryPath, subfolder: subfolder, filename: filename, exportedMD5: exportedMD5)
    }
    
    func storeImageExportFail(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, failMessage:String) -> ExecuteState {
        return self.impl.storeImageExportFail(imageId: imageId, profileId: profileId, repositoryPath: repositoryPath, subfolder: subfolder, filename: filename, failMessage: failMessage)
    }
    
    func deleteExportLog(imageId:String, profileId:String) -> ExecuteState {
        return self.impl.deleteExportLog(imageId: imageId, profileId: profileId)
    }
}
