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
        return ExportDao(ExportDaoPostgresCK())
    }
    
    // MARK: - PROFILE CRUD
    
    func getOrCreateExportProfile(id:String,
                                  name:String,
                                  targetVolume:String,
                                  directory: String,
                                  repositoryPath: String,
                                  specifyRepository: Bool,
                                  duplicateStrategy: String,
                                  fileNaming: String,
                                  subFolder: String,
                                  patchImageDescription:Bool,
                                  patchDateTime:Bool,
                                  patchGeolocation:Bool,
                                  specifyFamily:Bool,
                                  family:String,
                                  eventCategories:String,
                                  specifyEventCategory:Bool
                                  ) -> ExportProfile{
        return self.impl.getOrCreateExportProfile(id: id,
                                                  name: name,
                                                  targetVolume: targetVolume,
                                                  directory: directory,
                                                  repositoryPath: repositoryPath,
                                                  specifyRepository: specifyRepository,
                                                  duplicateStrategy: duplicateStrategy,
                                                  fileNaming: fileNaming,
                                                  subFolder: subFolder,
                                                  patchImageDescription: patchImageDescription,
                                                  patchDateTime: patchDateTime,
                                                  patchGeolocation: patchGeolocation,
                                                  specifyFamily: specifyFamily,
                                                  family: family,
                                                  eventCategories: eventCategories,
                                                  specifyEventCategory: specifyEventCategory)
    }
    
    func updateExportProfile(id:String,
                             name:String,
                             targetVolume:String,
                             directory: String,
                             duplicateStrategy: String,
                             specifyRepository: Bool,
                             specifyFamily: Bool,
                             repositoryPath: String,
                             family: String,
                             patchImageDescription:Bool,
                             patchDateTime:Bool,
                             patchGeolocation:Bool,
                             fileNaming: String,
                             subFolder: String,
                             eventCategories:String,
                             specifyEventCategory: Bool, style:String) -> ExecuteState{
        return self.impl.updateExportProfile(id: id,
                                             name: name,
                                             targetVolume: targetVolume,
                                             directory: directory,
                                             duplicateStrategy: duplicateStrategy,
                                             specifyRepository: specifyRepository,
                                             specifyFamily: specifyFamily,
                                             repositoryPath: repositoryPath,
                                             family: family,
                                             patchImageDescription: patchImageDescription,
                                             patchDateTime: patchDateTime,
                                             patchGeolocation: patchGeolocation,
                                             fileNaming: fileNaming,
                                             subFolder: subFolder,
                                             eventCategories: eventCategories,
                                             specifyEventCategory: specifyEventCategory,
                                             style: style)
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
    
    func getImagesForExport(profile:ExportProfile, pageSize:Int? = nil, pageNumber:Int? = nil, years:[String]) -> [Image] {
        return self.impl.getImagesForExport(profile: profile, pageSize: pageSize, pageNumber: pageNumber, years: years)
    }
    
    func countImagesForExport(profile:ExportProfile, years:[String]) -> Int {
        return self.impl.countImagesForExport(profile: profile, years: years)
    }
    
    func getExportedImages(profileId:String) -> [(String, String, String)] {
        return self.impl.getExportedImages(profileId: profileId)
    }
    
    func getExportedImages(profileId:String, years:[String]) -> [(String, String, String, Date)] {
        return self.impl.getExportedImages(profileId: profileId, years: years)
    }
    
    func getLatestExportTime(profileId:String, years:[String]) -> Date? {
        return self.impl.getLatestExportTime(profileId: profileId, years: years)
    }
    
    func getSQLForImageExport(profile:ExportProfile, years:[String]) -> String {
        return self.impl.getSQLForImageExport(profile: profile, years: years)
    }
    
    func getExportedImagesButNowHidden(profileId:String) -> [(String, String, String)] { // imageId, subFolder, filename
        return self.impl.getExportedImagesButNowHidden(profileId: profileId)
    }
    
    // MARK: - EXPORT RECORD LOG
    
    func deleteExportLogNotRelateToImageId(profileId:String) -> ExecuteState {
        return self.impl.deleteExportLogNotRelateToImageId(profileId:profileId)
    }
    
    func countExportedImages(profile:ExportProfile, years:[String]) -> Int {
        return self.impl.countExportedImages(profile: profile, years: years)
    }
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState {
        return self.impl.storeImageOriginalMD5(path: path, md5: md5)
    }
    
    func storeImageOriginalMD5(id:String, md5:String) -> ExecuteState {
        return self.impl.storeImageOriginalMD5(id: id, md5: md5)
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
    
    func getTargetVolumes() -> [String] {
        return self.impl.getTargetVolumes()
    }
    
    func deleteProfileEvents(profileId:String) -> ExecuteState {
        return self.impl.deleteProfileEvents(profileId: profileId)
    }
    
    func saveProfileEvent(profileId:String, eventOwner:String, eventNodeType:String, eventId:String, eventName:String, exclude:Bool) -> ExecuteState {
        return self.impl.saveProfileEvent(profileId: profileId, eventOwner: eventOwner, eventNodeType: eventNodeType, eventId: eventId, eventName: eventName, exclude: exclude)
    }
    
    func saveProfileEvents(profileId:String, selectedEventNodes:[TreeNodeData], exclude:Bool, owner:String) -> ExecuteState {
        return self.impl.saveProfileEvents(profileId: profileId, selectedEventNodes: selectedEventNodes, exclude: exclude, owner: owner)
    }
    
    func loadProfileEvents(profileId:String) -> [ExportProfileEvent] {
        return self.impl.loadProfileEvents(profileId: profileId)
    }
}
