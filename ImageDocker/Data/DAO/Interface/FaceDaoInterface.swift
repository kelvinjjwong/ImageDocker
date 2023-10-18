//
//  FaceDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol FaceDaoInterface {
    
    func getFamily(id:String) -> Family?
    
    func getFamilies() -> [Family]
    
    func getFamilies(peopleId:String) -> [String]
    
    func saveFamilyMember(peopleId:String, familyId:String) -> ExecuteState
    
    func deleteFamilyMember(peopleId:String, familyId:String) -> ExecuteState
    
    func saveFamily(familyId:String?, name:String, type:String, owner:String) -> String?
    
    func deleteFamily(id:String) -> ExecuteState
    
    func getFamilyMembers() -> [FamilyMember]
    
    // MARK: - RELATIONSHIP
    
    func getRelationship(primary:String, secondary:String) -> (String, String)
    
    func getRelationships(peopleId:String) -> [[String:String]]
    
    func saveRelationship(primary:String, secondary:String, callName:String) -> ExecuteState
    
    func getRelationships() -> [PeopleRelationship]
    
    // MARK: - PEOPLE
    
    func getPeople() -> [People]
    
    func getCoreMembers() -> [People]
    
    func getPeople(inFamilyQuotedSeparated:String, exclude:Bool) -> [People]
    
    func getPeople(except:String) -> [People]
    
    func getPerson(id: String) -> People?
    
    func getPerson(name: String) -> People?
    
    func savePersonName(id:String, name:String, shortName:String) -> ExecuteState
    
    func updatePersonIconImage(id:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> Bool
    
    func deletePerson(id:String) -> ExecuteState
    
    func updatePersonIsCoreMember(id:String, isCoreMember:Bool) -> ExecuteState
    
    func updatePersonCoreMemberColor(id:String, hexColor:String) -> ExecuteState
    
    func getRepositoryOwnerColors() -> [Int:String]
}
