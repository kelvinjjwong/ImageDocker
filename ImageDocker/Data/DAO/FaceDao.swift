//
//  FaceDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class FaceDao {
    
    func getFamilies() -> [Family] {
        return ModelStore.default.getFamilies()
    }
    
    func getFamilies(peopleId:String) -> [String] {
        return ModelStore.default.getFamilies(peopleId: peopleId)
    }
    
    func saveFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        return ModelStore.default.saveFamilyMember(peopleId: peopleId, familyId: familyId)
    }
    
    func deleteFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        return ModelStore.default.deleteFamilyMember(peopleId: peopleId, familyId: familyId)
    }
    
    func saveFamily(familyId:String?=nil, name:String, type:String) -> String? {
        return ModelStore.default.saveFamily(familyId: familyId, name: name, type: type)
    }
    
    func deleteFamily(id:String) -> ExecuteState {
        return ModelStore.default.deleteFamily(id: id)
    }
    
    // MARK: - RELATIONSHIP
    
    func getRelationship(primary:String, secondary:String) -> (String, String) {
        return ModelStore.default.getRelationship(primary: primary, secondary: secondary)
    }
    
    func getRelationships(peopleId:String) -> [[String:String]] {
        return ModelStore.default.getRelationships(peopleId: peopleId)
    }
    
    func saveRelationship(primary:String, secondary:String, callName:String) -> ExecuteState {
        return ModelStore.default.saveRelationship(primary: primary, secondary: secondary, callName: callName)
    }
    
    func getRelationships() -> [PeopleRelationship] {
        return ModelStore.default.getRelationships()
    }
    
    // MARK: - PEOPLE
    
    func getPeople() -> [People] {
        return ModelStore.default.getPeople()
    }
    
    func getPeople(except:String) -> [People] {
        return ModelStore.default.getPeople(except: except)
    }
    
    func getPerson(id: String) -> People? {
        return ModelStore.default.getPerson(id: id)
    }
    
    func savePersonName(id:String, name:String, shortName:String) -> ExecuteState {
        return ModelStore.default.savePersonName(id: id, name: name, shortName: shortName)
    }
    
    func updatePersonIconImage(id:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> Bool{
        return ModelStore.default.updatePersonIconImage(id: id, repositoryPath: repositoryPath, cropPath: cropPath, subPath: subPath, filename: filename)
    }
    
    func deletePerson(id:String) -> ExecuteState {
        return ModelStore.default.deletePerson(id: id)
    }
    
    // MARK: - FACE
    
    func getFace(id: String) -> ImageFace? {
        return ModelStore.default.getFace(id: id)
    }
    
    func getFaceCrops(imageId: String) -> [ImageFace] {
        return ModelStore.default.getFaceCrops(imageId: imageId)
    }
    
    func findFaceCrop(imageId: String, x:String, y:String, width:String, height:String) -> ImageFace? {
        return ModelStore.default.findFaceCrop(imageId: imageId, x: x, y: y, width: width, height: height)
    }
    
    func getYearsOfFaceCrops(peopleId:String) -> [String]{
        return ModelStore.default.getYearsOfFaceCrops(peopleId: peopleId)
    }
    
    func getMonthsOfFaceCrops(peopleId:String, imageYear:String) -> [String]{
        return ModelStore.default.getMonthsOfFaceCrops(peopleId: peopleId, imageYear: imageYear)
    }
    
    func getFaceCrops(peopleId:String, year:Int? = nil, month:Int? = nil, sample:Bool? = nil, icon:Bool? = nil, tag:Bool? = nil, locked:Bool? = nil) -> [ImageFace]{
        return ModelStore.default.getFaceCrops(peopleId: peopleId, year: year, month: month, sample: sample, icon: icon, tag: tag, locked: locked)
    }
    
    func saveFaceCrop(_ face:ImageFace) -> ExecuteState {
        return ModelStore.default.saveFaceCrop(face)
    }
    
    func updateFaceIconFlag(id:String, peopleId:String) -> ExecuteState {
        return ModelStore.default.updateFaceIconFlag(id: id, peopleId: peopleId)
    }
    
    func removeFaceIcon(peopleId:String) -> ExecuteState {
        return ModelStore.default.removeFaceIcon(peopleId: peopleId)
    }
    
    func updateFaceSampleFlag(id:String, flag:Bool) -> ExecuteState {
        return ModelStore.default.updateFaceSampleFlag(id: id, flag: flag)
    }
    
    func updateFaceTagFlag(id:String, flag:Bool) -> ExecuteState {
        return ModelStore.default.updateFaceTagFlag(id: id, flag: flag)
    }
    
    func updateFaceLockFlag(id:String, flag:Bool) -> ExecuteState {
        return ModelStore.default.updateFaceLockFlag(id: id, flag: flag)
    }
    
    func updateFaceCropPaths(old:String, new:String) -> ExecuteState {
        return ModelStore.default.updateFaceCropPaths(old: old, new: new)
    }
}
