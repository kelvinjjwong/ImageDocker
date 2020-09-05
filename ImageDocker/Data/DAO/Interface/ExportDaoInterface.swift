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
                                  ) -> ExportProfile
    
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
                             subFolder: String) -> ExecuteState
    
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
    
    func getImagesForExport(profile:ExportProfile, pageSize:Int?, pageNumber:Int?) -> [Image]
    
    func countImagesForExport(profile:ExportProfile) -> Int
    
    func getExportedImages(profileId:String) -> [(String, String, String)]
    
    func getSQLForImageExport(profile:ExportProfile) -> String
    
    // MARK: - EXPORT RECORD LOG
    
    func countExportedImages(profile:ExportProfile) -> Int
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState
    
    func storeImageExportSuccess(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, exportedMD5: String) -> ExecuteState
    
    func storeImageExportFail(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, failMessage:String) -> ExecuteState
    
    func deleteExportLog(imageId:String, profileId:String) -> ExecuteState
}
