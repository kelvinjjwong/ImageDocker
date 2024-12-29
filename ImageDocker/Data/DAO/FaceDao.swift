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
        return FaceDao(FaceDaoPostgresCK())
    }
    
    func getFamily(id:String) -> Family? {
        return self.impl.getFamily(id: id)
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
    
    func saveFamily(familyId:String?=nil, name:String, type:String, owner:String) -> String? {
        return self.impl.saveFamily(familyId: familyId, name: name, type: type, owner:owner)
    }
    
    func deleteFamily(id:String) -> ExecuteState {
        return self.impl.deleteFamily(id: id)
    }
    
    func getFamilyMembers() -> [FamilyMember] {
        return self.impl.getFamilyMembers()
    }
    
    // MARK: - PEOPLE
    
    func getPeople() -> [People] {
        return self.impl.getPeople()
    }
    
    func getCoreMembers() -> [People] {
        return self.impl.getCoreMembers()
    }
    
    func getPeople(inFamilyQuotedSeparated:String, exclude:Bool = false) -> [People] {
        return self.impl.getPeople(inFamilyQuotedSeparated: inFamilyQuotedSeparated, exclude: exclude)
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
    
    func getPerson(nickname: String) -> People? {
        return self.impl.getPerson(nickname: nickname)
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
    
    func updatePersonIsCoreMember(id:String, isCoreMember:Bool) -> ExecuteState {
        return self.impl.updatePersonIsCoreMember(id: id, isCoreMember: isCoreMember)
    }
    
    func updatePersonCoreMemberColor(id:String, hexColor:String) -> ExecuteState {
        return self.impl.updatePersonCoreMemberColor(id: id, hexColor: hexColor)
    }
    
    func getRepositoryOwnerColors() -> [Int:String] {
        return self.impl.getRepositoryOwnerColors()
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
}
