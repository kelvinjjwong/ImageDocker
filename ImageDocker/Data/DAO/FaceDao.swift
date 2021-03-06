//
//  FaceDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class FaceDao {
    
    private let impl:FaceDaoInterface
    
    init(_ impl:FaceDaoInterface){
        self.impl = impl
    }
    
    static var `default`:FaceDao {
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return FaceDao(FaceDaoGRDB())
        }else{
            return FaceDao(FaceDaoPostgresCK())
        }
    }
    
    func getFamilies() -> [Family] {
        return self.impl.getFamilies()
    }
    
    func getFamilies(peopleId:String) -> [String] {
        return self.impl.getFamilies(peopleId: peopleId)
    }
    
    func saveFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        return self.impl.saveFamilyMember(peopleId: peopleId, familyId: familyId)
    }
    
    func deleteFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        return self.impl.deleteFamilyMember(peopleId: peopleId, familyId: familyId)
    }
    
    func saveFamily(familyId:String?=nil, name:String, type:String) -> String? {
        return self.impl.saveFamily(familyId: familyId, name: name, type: type)
    }
    
    func deleteFamily(id:String) -> ExecuteState {
        return self.impl.deleteFamily(id: id)
    }
    
    // MARK: - RELATIONSHIP
    
    func getRelationship(primary:String, secondary:String) -> (String, String) {
        return self.impl.getRelationship(primary: primary, secondary: secondary)
    }
    
    func getRelationships(peopleId:String) -> [[String:String]] {
        return self.impl.getRelationships(peopleId: peopleId)
    }
    
    func saveRelationship(primary:String, secondary:String, callName:String) -> ExecuteState {
        return self.impl.saveRelationship(primary: primary, secondary: secondary, callName: callName)
    }
    
    func getRelationships() -> [PeopleRelationship] {
        return self.impl.getRelationships()
    }
    
    // MARK: - PEOPLE
    
    func getPeople() -> [People] {
        return self.impl.getPeople()
    }
    
    func getPeople(except:String) -> [People] {
        return self.impl.getPeople(except: except)
    }
    
    func getPerson(id: String) -> People? {
        return self.impl.getPerson(id: id)
    }
    
    func getPerson(name: String) -> People? {
        return self.impl.getPerson(name: name)
    }
    
    func savePersonName(id:String, name:String, shortName:String) -> ExecuteState {
        return self.impl.savePersonName(id: id, name: name, shortName: shortName)
    }
    
    func updatePersonIconImage(id:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> Bool{
        return self.impl.updatePersonIconImage(id: id, repositoryPath: repositoryPath, cropPath: cropPath, subPath: subPath, filename: filename)
    }
    
    func deletePerson(id:String) -> ExecuteState {
        return self.impl.deletePerson(id: id)
    }
    
    // MARK: - FACE
    
    func getFace(id: String) -> ImageFace? {
        return self.impl.getFace(id: id)
    }
    
    func getFaceCrops(imageId: String) -> [ImageFace] {
        return self.impl.getFaceCrops(imageId: imageId)
    }
    
    func findFaceCrop(imageId: String, x:String, y:String, width:String, height:String) -> ImageFace? {
        return self.impl.findFaceCrop(imageId: imageId, x: x, y: y, width: width, height: height)
    }
    
    func getYearsOfFaceCrops(peopleId:String) -> [String]{
        return self.impl.getYearsOfFaceCrops(peopleId: peopleId)
    }
    
    func getMonthsOfFaceCrops(peopleId:String, imageYear:String) -> [String]{
        return self.impl.getMonthsOfFaceCrops(peopleId: peopleId, imageYear: imageYear)
    }
    
    func getFaceCrops(peopleId:String, year:Int? = nil, month:Int? = nil, sample:Bool? = nil, icon:Bool? = nil, tag:Bool? = nil, locked:Bool? = nil) -> [ImageFace]{
        return self.impl.getFaceCrops(peopleId: peopleId, year: year, month: month, sample: sample, icon: icon, tag: tag, locked: locked)
    }
    
    func saveFaceCrop(_ face:ImageFace) -> ExecuteState {
        return self.impl.saveFaceCrop(face)
    }
    
    func updateFaceIconFlag(id:String, peopleId:String) -> ExecuteState {
        return self.impl.updateFaceIconFlag(id: id, peopleId: peopleId)
    }
    
    func removeFaceIcon(peopleId:String) -> ExecuteState {
        return self.impl.removeFaceIcon(peopleId: peopleId)
    }
    
    func updateFaceSampleFlag(id:String, flag:Bool) -> ExecuteState {
        return self.impl.updateFaceSampleFlag(id: id, flag: flag)
    }
    
    func updateFaceTagFlag(id:String, flag:Bool) -> ExecuteState {
        return self.impl.updateFaceTagFlag(id: id, flag: flag)
    }
    
    func updateFaceLockFlag(id:String, flag:Bool) -> ExecuteState {
        return self.impl.updateFaceLockFlag(id: id, flag: flag)
    }
    
    func updateFaceCropPaths(old:String, new:String) -> ExecuteState {
        return self.impl.updateFaceCropPaths(old: old, new: new)
    }
}
