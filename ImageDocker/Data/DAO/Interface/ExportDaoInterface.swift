//
//  ExportDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol ExportDaoInterface {
    
    // MARK: - PROFILE CRUD
    
    func getOrCreateExportProfile(id:String,
                                  name:String,
                                  targetVolume: String,
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
                                  ) -> ExportProfile
    
    func updateExportProfile(id:String,
                             name:String,
                             targetVolume: String,
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
                             specifyEventCategory:Bool, style:String) -> ExecuteState
    
    func enableExportProfile(id:String) -> ExecuteState
    
    func disableExportProfile(id:String) -> ExecuteState
    
    func updateExportProfileLastExportTime(id:String) -> ExecuteState
    
    func getLastExportTime(profile:ExportProfile) -> Date?
    
    func getExportedFilename(imageId:String, profileId:String) -> (String?, String?)
    
    func getExportProfile(id:String) -> ExportProfile?
    
    func getExportProfile(name:String) -> ExportProfile?
    
    func getAllExportProfiles() -> [ExportProfile]
    
    func deleteExportProfile(id:String) -> ExecuteState
    
    // MARK: - SEARCH FOR IMAGES
    
    func getImagesForExport(profile:ExportProfile, pageSize:Int?, pageNumber:Int?, years:[String]) -> [Image]
    
    func countImagesForExport(profile:ExportProfile, years:[String]) -> Int
    
    func getExportedImages(profileId:String) -> [(String, String, String)]
    
    func getExportedImages(profileId:String, years:[String]) -> [(String, String, String, Date)]
    
    func getSQLForImageExport(profile:ExportProfile, years:[String]) -> String
    
    func getExportedImagesButNowHidden(profileId:String) -> [(String, String, String)]
    
    func getLatestExportTime(profileId:String, years:[String]) -> Date?
    
    // MARK: - EXPORT RECORD LOG
    
    func deleteExportLogNotRelateToImageId(profileId:String) -> ExecuteState 
    
    func countExportedImages(profile:ExportProfile, years:[String]) -> Int
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState
    
    func storeImageOriginalMD5(id:String, md5:String) -> ExecuteState
    
    func storeImageExportSuccess(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, exportedMD5: String) -> ExecuteState
    
    func storeImageExportFail(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, failMessage:String) -> ExecuteState
    
    func deleteExportLog(imageId:String, profileId:String) -> ExecuteState
    
    func getTargetVolumes() -> [String]
    
    func deleteProfileEvents(profileId:String) -> ExecuteState
    
    func saveProfileEvent(profileId:String, eventOwner:String, eventNodeType:String, eventId:String, eventName:String, exclude:Bool) -> ExecuteState
    
    func saveProfileEvents(profileId:String, selectedEventNodes:[TreeNodeData], exclude:Bool, owner:String) -> ExecuteState
    
    func loadProfileEvents(profileId:String) -> [ExportProfileEvent]
}
