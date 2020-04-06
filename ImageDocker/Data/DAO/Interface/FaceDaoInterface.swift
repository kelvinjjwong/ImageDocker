//
//  FaceDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol FaceDaoInterface {
    
    func getFamilies() -> [Family]
    
    func getFamilies(peopleId:String) -> [String]
    
    func saveFamilyMember(peopleId:String, familyId:String) -> ExecuteState
    
    func deleteFamilyMember(peopleId:String, familyId:String) -> ExecuteState
    
    func saveFamily(familyId:String?, name:String, type:String) -> String?
    
    func deleteFamily(id:String) -> ExecuteState
    
    // MARK: - RELATIONSHIP
    
    func getRelationship(primary:String, secondary:String) -> (String, String)
    
    func getRelationships(peopleId:String) -> [[String:String]]
    
    func saveRelationship(primary:String, secondary:String, callName:String) -> ExecuteState
    
    func getRelationships() -> [PeopleRelationship]
    
    // MARK: - PEOPLE
    
    func getPeople() -> [People]
    
    func getPeople(except:String) -> [People]
    
    func getPerson(id: String) -> People?
    
    func savePersonName(id:String, name:String, shortName:String) -> ExecuteState
    
    func updatePersonIconImage(id:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> Bool
    
    func deletePerson(id:String) -> ExecuteState
    
    // MARK: - FACE
    
    func getFace(id: String) -> ImageFace?
    
    func getFaceCrops(imageId: String) -> [ImageFace]
    
    func findFaceCrop(imageId: String, x:String, y:String, width:String, height:String) -> ImageFace?
    
    func getYearsOfFaceCrops(peopleId:String) -> [String]
    
    func getMonthsOfFaceCrops(peopleId:String, imageYear:String) -> [String]
    
    func getFaceCrops(peopleId:String, year:Int?, month:Int?, sample:Bool?, icon:Bool?, tag:Bool?, locked:Bool?) -> [ImageFace]
    
    func saveFaceCrop(_ face:ImageFace) -> ExecuteState
    
    func updateFaceIconFlag(id:String, peopleId:String) -> ExecuteState
    
    func removeFaceIcon(peopleId:String) -> ExecuteState
    
    func updateFaceSampleFlag(id:String, flag:Bool) -> ExecuteState
    
    func updateFaceTagFlag(id:String, flag:Bool) -> ExecuteState
    
    func updateFaceLockFlag(id:String, flag:Bool) -> ExecuteState
    
    func updateFaceCropPaths(old:String, new:String) -> ExecuteState
}
