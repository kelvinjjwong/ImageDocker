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
    
    func getExportProfile(id:String) -> ExportProfile?
    
    func getAllExportProfiles() -> [ExportProfile]
    
    func deleteExportProfile(id:String) -> ExecuteState
    
    // MARK: - SEARCH FOR IMAGES
    
    func getAllExportedImages(includeHidden:Bool) -> [Image]
    
    func getAllPhotoFilesForExporting(after date:Date, limit:Int?) -> [Image]
    
    func countAllPhotoFilesForExporting(after date:Date) -> Int
    
    // MARK: - EXPORT RECORD LOG
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState
    
    func storeImageExportedMD5(path:String, md5:String) -> ExecuteState
    
    func storeImageExportSuccess(path:String, date:Date, exportToPath:String, exportedFilename:String, exportedMD5:String, exportedLongDescription:String) -> ExecuteState
    
    func storeImageExportedTime(path:String, date:Date) -> ExecuteState
    
    func storeImageExportFail(path:String, date:Date, message:String) -> ExecuteState
    
    func cleanImageExportPath(path:String) -> ExecuteState
}
