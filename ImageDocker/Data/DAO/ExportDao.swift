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
        return self.impl.getOrCreateExportProfile(id: id, name: name, directory: directory, repositoryPath: repositoryPath, specifyPeople: specifyPeople, specifyEvent: specifyEvent, specifyRepository: specifyRepository, people: people, events: events, duplicateStrategy: duplicateStrategy, fileNaming: fileNaming, subFolder: subFolder, patchImageDescription: patchImageDescription, patchDateTime: patchDateTime, patchGeolocation: patchGeolocation)
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
        return self.impl.updateExportProfile(id: id, name: name, directory: directory, duplicateStrategy: duplicateStrategy, specifyPeople: specifyPeople, specifyEvent: specifyEvent, specifyRepository: specifyRepository, people: people, events: events, repositoryPath: repositoryPath)
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
}
