//
//  ImageDBCloner.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/7/13.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

public final class ImageDBCloner {
    
    let logger = LoggerFactory.get(category: "ImageDBCloner")
    
    static let `default` = ImageDBCloner()
    
    public func fromLocalSQLiteToPostgreSQL(dropBeforeCreate:Bool, postgresDB: () -> PostgresDB, message: ((String) -> Void), onComplete: () -> Void) {
//        message("Re-initializing schema ...")
//        PostgresConnection.default.versionCheck(dropBeforeCreate: dropBeforeCreate, db: postgresDB())
//
//        final class Version : DatabaseRecord {
//            var ver:Int = 0
//            public init() {}
//        }
//
//        if let version = Version.fetchOne(postgresDB(), sql: "select substring(ver, '\\d+')::int versions from version_migrations order by versions desc") {
//            message("Remote DB schema version is v\(version.ver) now.")
//
//            var containers:[ImageContainer] = []
//            var images:[Image] = []
//            var places:[ImagePlace] = []
//            var events:[ImageEvent] = []
//            var devices:[ImageDevice] = []
//            var deviceFiles:[ImageDeviceFile] = []
//            var devicePaths:[ImageDevicePath] = []
//            var people:[People] = []
//            var relationships:[PeopleRelationship] = []
//            var imagePeople:[ImagePeople] = []
//            var imageFaces:[ImageFace] = []
//            var exportProfiles:[ExportProfile] = []
//            var families:[Family] = []
//            var familyMembers:[FamilyMember] = []
//            var familyJoints:[FamilyJoint] = []
//            do {
//                let db = try SQLiteConnectionGRDB.default.sharedDBPool()
//                try db.read { localdb in
//                    message("Loading repositories data from local database...")
//                    containers = try ImageContainer.fetchAll(localdb)
//
//                    message("Loading images data from local database...")
//                    images = try Image.fetchAll(localdb)
//
//                    message("Loading places data from local database...")
//                    places = try ImagePlace.fetchAll(localdb)
//
//                    message("Loading events data from local database...")
//                    events = try ImageEvent.fetchAll(localdb)
//
//                    message("Loading devices data from local database...")
//                    devices = try ImageDevice.fetchAll(localdb)
//                    deviceFiles = try ImageDeviceFile.fetchAll(localdb)
//                    devicePaths = try ImageDevicePath.fetchAll(localdb)
//
//                    message("Loading face data from local database...")
//                    people = try People.fetchAll(localdb)
//                    relationships = try PeopleRelationship.fetchAll(localdb)
//                    imagePeople = try ImagePeople.fetchAll(localdb)
//                    imageFaces = try ImageFace.fetchAll(localdb)
//                    families = try Family.fetchAll(localdb)
//                    familyMembers = try FamilyMember.fetchAll(localdb)
//                    familyJoints = try FamilyJoint.fetchAll(localdb)
//
//                    message("Loading profile data from local database...")
//                    exportProfiles = try ExportProfile.fetchAll(localdb)
//                }
//
//                message("Loaded all data from local database...")
//            }catch{
//                message("DB ERROR: \(error.localizedDescription)")
//                self.logger.log(error)
//                onComplete()
//                return
//            }
//
//            let remotedb = postgresDB()
//            var count = 0
//            var i = 0
//            count = containers.count
//            message("Cloning repositories data to remote database...")
//            for record in containers {
//                record.save(remotedb)
//                i += 1
//                message("Cloning repositories data to remote database... \(i) / \(count)")
//            }
//
//            count = images.count
//            i = 0
//            message("Cloning images data to remote database...")
//            for record in images {
//                record.save(remotedb)
//                i += 1
//                message("Cloning images data to remote database... \(i) / \(count)")
//            }
//
//            count = places.count
//            i = 0
//            message("Cloning places data to remote database...")
//            for record in places {
//                record.save(remotedb)
//                i += 1
//                message("Cloning places data to remote database... \(i) / \(count)")
//            }
//            count = events.count
//            i = 0
//            message("Cloning events data to remote database...")
//            for record in events {
//                record.save(remotedb)
//                i += 1
//                message("Cloning events data to remote database... \(i) / \(count)")
//            }
//            count = devices.count + deviceFiles.count + devicePaths.count
//            i = 0
//            message("Cloning devices data to remote database...")
//            for record in devices {
//                record.save(remotedb)
//                i += 1
//                message("Cloning devices data to remote database... \(i) / \(count)")
//            }
//            for record in deviceFiles {
//                record.save(remotedb)
//                i += 1
//                message("Cloning devices data to remote database... \(i) / \(count)")
//            }
//            for record in devicePaths {
//                record.save(remotedb)
//                i += 1
//                message("Cloning devices data to remote database... \(i) / \(count)")
//            }
//            count = people.count + relationships.count + imagePeople.count + imageFaces.count + families.count + familyMembers.count + familyJoints.count
//            i = 0
//            message("Cloning faces data to remote database...")
//            for record in people {
//                record.save(remotedb)
//                i += 1
//                message("Cloning faces data to remote database... \(i) / \(count)")
//            }
//            for record in relationships {
//                record.save(remotedb)
//                i += 1
//                message("Cloning faces data to remote database... \(i) / \(count)")
//            }
//            for record in imagePeople {
//                record.save(remotedb)
//                i += 1
//                message("Cloning faces data to remote database... \(i) / \(count)")
//            }
//            for record in imageFaces {
//                record.save(remotedb)
//                i += 1
//                message("Cloning faces data to remote database... \(i) / \(count)")
//            }
//            for record in families {
//                record.save(remotedb)
//                i += 1
//                message("Cloning faces data to remote database... \(i) / \(count)")
//            }
//            for record in familyMembers {
//                record.save(remotedb)
//                i += 1
//                message("Cloning faces data to remote database... \(i) / \(count)")
//            }
//            for record in familyJoints {
//                record.save(remotedb)
//                i += 1
//                message("Cloning faces data to remote database... \(i) / \(count)")
//            }
//            count = exportProfiles.count
//            i = 0
//            message("Cloning export profiles data to remote database...")
//            for record in exportProfiles {
//                record.save(remotedb)
//                i += 1
//                message("Cloning export profiles data to remote database... \(i) / \(count)")
//            }
//            message("Cloned all data to remote database.")
//            onComplete()
//            return
//        }else{
//            message("Something wrong happened. Please check console output.")
//            onComplete()
//            return
//        }
    }
}
