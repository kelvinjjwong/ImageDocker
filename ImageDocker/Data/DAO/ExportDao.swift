//
//  ExportDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class ExportDao {
    
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
                                  patchGeolocation:Bool
                                  ) -> ExportProfile{
        return ModelStore.default.getOrCreateExportProfile(id: id, name: name, directory: directory, repositoryPath: repositoryPath, specifyPeople: specifyPeople, specifyEvent: specifyEvent, specifyRepository: specifyRepository, people: people, events: events, duplicateStrategy: duplicateStrategy, fileNaming: fileNaming, subFolder: subFolder, patchImageDescription: patchImageDescription, patchDateTime: patchDateTime, patchGeolocation: patchGeolocation)
    }
    
    func updateExportProfile(id:String,
                             name:String,
                             directory: String,
                             duplicateStrategy: String,
                             specifyPeople: Bool,
                             specifyEvent: Bool,
                             specifyRepository: Bool,
                             people: String,
                             events: String,
                             repositoryPath: String) -> ExecuteState{
        return ModelStore.default.updateExportProfile(id: id, name: name, directory: directory, duplicateStrategy: duplicateStrategy, specifyPeople: specifyPeople, specifyEvent: specifyEvent, specifyRepository: specifyRepository, people: people, events: events, repositoryPath: repositoryPath)
    }
    
    func enableExportProfile(id:String) -> ExecuteState{
        return ModelStore.default.enableExportProfile(id: id)
    }
    
    func disableExportProfile(id:String) -> ExecuteState{
        return ModelStore.default.disableExportProfile(id: id)
    }
    
    func updateExportProfileLastExportTime(id:String) -> ExecuteState{
        return ModelStore.default.updateExportProfileLastExportTime(id: id)
    }
    
    func getExportProfile(id:String) -> ExportProfile? {
        return ModelStore.default.getExportProfile(id: id)
    }
    
    func getAllExportProfiles() -> [ExportProfile] {
        return ModelStore.default.getAllExportProfiles()
    }
    
    func deleteExportProfile(id:String) -> ExecuteState{
        return ModelStore.default.deleteExportProfile(id: id)
    }
}
