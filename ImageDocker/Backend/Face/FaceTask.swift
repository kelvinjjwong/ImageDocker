//
//  FaceTask.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/5/7.
//  Copyright © 2019 nonamecat. All rights reserved.
//

//import Foundation
//
import LoggerFactory
class FaceTask {

    let logger = LoggerFactory.get(category: "FaceTask")

    static let `default` = FaceTask()

    var peopleName:[String:String] = [:]
    var peopleIds:[String] = []

    func people(id:String, reload:Bool = false) -> String {
        if reload || peopleName.count == 0 {
            self.reloadPeople()
        }
        return peopleName[id] ?? ""

    }

    func peopleId(name:String, reload:Bool = false) -> String? {
        if reload || peopleIds.count == 0 {
            self.reloadPeople()
        }
        for names in peopleIds {
            if names.contains(name) {
                let parts = names.components(separatedBy: ",")
                return parts[0]
            }
        }
        return nil
    }

    func reloadPeople() {
        self.peopleName = [:]
        let people = FaceDao.default.getPeople()
        let relationships = FaceDao.default.getRelationships()
        var ids:[String:String] = [:]
        for person in people {
            peopleName[person.id] = person.shortName ?? person.name
            ids[person.id] = "\(person.shortName ?? person.name),\(person.name)"
        }
        for relationship in relationships {
            var names = ids[relationship.object] ?? ""
            if names != "" {
                names += ",\(relationship.callName)"
                ids[relationship.object] = names
            }
        }
        self.peopleIds = []
        for id in ids.keys {
            if let names = ids[id] {
                let value = "\(id),\(names)"
                self.peopleIds.append(value)
            }
        }
    }
//
//    func findFaces(image:Image) -> Bool {
//        if !FileManager.default.fileExists(atPath: image.path) {
//            self.logger.log(.trace, "ERROR: No file found at \(image.path)")
//            return false
//        }
//        if Naming.FileType.recognize(from: image.filename) != .photo  {
//            return false
//        }
//        if image.repositoryPath != "", let repository = RepositoryDao.default.getRepository(repositoryPath: image.repositoryPath) {
//            if repository.cropPath != "" {
//                // ensure base crop path exists
//                var isDir:ObjCBool = false
//                if FileManager.default.fileExists(atPath: repository.cropPath, isDirectory: &isDir) {
//                    if !isDir.boolValue {
//                        self.logger.log(.trace, "ERROR: Crop path of repository is not a directory: \(repository.cropPath)")
//                        return false
//                    }
//                }
//
//                // ensure image-filename-aware crop path exists
//                let cropPath = URL(fileURLWithPath: repository.cropPath).appendingPathComponent(image.subPath)
//                self.logger.log(.trace, "Trying to create directory: \(cropPath.path)")
//                //if FileManager.default.fileExists(atPath: repository.cropPath, isDirectory: &isDir), isDir.boolValue {
//                do {
//                    try FileManager.default.createDirectory(atPath: cropPath.path, withIntermediateDirectories: true, attributes: nil)
//                }catch{
//                    self.logger.log(error)
//                    self.logger.log(.trace, "ERROR: Cannot create directory for storing crops at path: \(cropPath.path)")
//                    return false
//                }
//                //}
//                if !FileManager.default.fileExists(atPath: cropPath.path, isDirectory: &isDir) {
//                    self.logger.log(.trace, "ERROR: Cannot create directory: \(cropPath.path)")
//                    return false
//                }
//
//                let img = image
//                if img.id == nil {
//                    img.id = UUID().uuidString
//                    let _ = ImageRecordDao.default.saveImage(image: img)
//                }
//                let imageId = img.id!
//
//                let url = URL(fileURLWithPath: image.path)
//
//                FaceDetection.default.findFace(from: url, into: cropPath, onCompleted: {faces in
//                    for face in faces {
//                        self.logger.log(.trace, "Found face: \(face.filename) at (\(face.x), \(face.y), \(face.width), \(face.height))")
//                        let exist = FaceDao.default.findFaceCrop(imageId: imageId,
//                                                                    x: face.x.databaseValue.description,
//                                                                    y: face.y.databaseValue.description,
//                                                                    width: face.width.databaseValue.description,
//                                                                    height: face.height.databaseValue.description)
//                        if exist == nil {
//                            let imageFace = ImageFace.new(imageId: imageId,
//                                                          repositoryPath: repository.repositoryPath.withStash(),
//                                                          cropPath: repository.cropPath,
//                                                          subPath: image.subPath,
//                                                          filename: face.filename,
//                                                          faceX: face.x.databaseValue.description,
//                                                          faceY: face.y.databaseValue.description,
//                                                          faceWidth: face.width.databaseValue.description,
//                                                          faceHeight: face.height.databaseValue.description,
//                                                          frameX: face.frameX.databaseValue.description,
//                                                          frameY: face.frameY.databaseValue.description,
//                                                          frameWidth: face.frameWidth.databaseValue.description,
//                                                          frameHeight: face.frameHeight.databaseValue.description,
//                                                          imageDate: image.photoTakenDate,
//                                                          tagOnly: false,
//                                                          remark: "",
//                                                          year: image.photoTakenYear ?? 0,
//                                                          month: image.photoTakenMonth ?? 0,
//                                                          day: image.photoTakenDay ?? 0)
//                            let _ = FaceDao.default.saveFaceCrop(imageFace)
//                            self.logger.log(.trace, "Face crop \(imageFace.id) saved.")
//                        }else{
//                            self.logger.log(.trace, "Face already in DB")
//                        }
//                    }
//
//                    self.logger.log(.trace, "Face detection done in \(cropPath.path)")
//
//                    img.scanedFace = true
//                    let _ = ImageFaceDao.default.updateImageScannedFace(imageId: imageId, facesCount: faces.count)
//                }) // another thread
//
//            }else{
//                self.logger.log(.trace, "ERROR: Crop path is empty, please assign it first: \(repository.path)")
//                return false
//            }
//        }else{
//            self.logger.log(.trace, "ERROR: Cannot find image's repository by repository path: \(image.repositoryPath)")
//            return false
//        }
//        return true
//    }
//
//    func findFaces(path:String) -> Bool {
//        if let image = ImageRecordDao.default.getImage(path: path) {
//            return self.findFaces(image: image)
//        }else{
//            self.logger.log(.trace, "ERROR: Cannot find image record: \(path)")
//            return false
//        }
//    }
    
//    func recognizeFaces(image:Image) -> Bool {
//
//        if !FileManager.default.fileExists(atPath: image.path) {
//            self.logger.log(.trace, "ERROR: No file found at \(image.path)")
//            return false
//        }
//        if Naming.FileType.recognize(from: image.filename) != .photo  {
//            return false
//        }
//        if let imageId = image.id {
//            var recognizedPeopleIds = ","
//            let crops = FaceDao.default.getFaceCrops(imageId: imageId)
//            if crops.count > 0 {
//                for crop in crops {
//                    let path = URL(fileURLWithPath: crop.cropPath).appendingPathComponent(crop.subPath).appendingPathComponent(crop.filename)
//                    let recognition = FaceRecognition.default.recognize(imagePath: path.path)
//                    if recognition.count > 0 {
//                        let name = recognition[0]
//                        self.logger.log(.trace, "Face crop \(crop.id) is recognized as \(name)")
//                        //if name != "unknown" && name != "Unknown" && name != "" {
//                            recognizedPeopleIds += "\(name),"
//                        //}
//                        let c = crop
//                        c.peopleId = name
//                        c.recognizeBy = "FaceRecognitionOpenCV"
//                        c.recognizeDate = Date()
//                        if c.recognizeVersion == nil {
//                            c.recognizeVersion = "1"
//                        }else{
//                            var version = Int(c.recognizeVersion ?? "0") ?? 0
//                            version += 1
//                            c.recognizeVersion = "\(version)"
//                        }
//                        let _ = FaceDao.default.saveFaceCrop(c)
//                        self.logger.log(.trace, "Face crop \(crop.id) updated into DB.")
//                    }else{
//                        self.logger.log(.trace, "No face recognized for image [\(imageId)].")
//                    }
//                }
//
//                let _ = ImageFaceDao.default.updateImageRecognizedFace(imageId: imageId, recognizedPeopleIds: recognizedPeopleIds)
//            }else{
//                self.logger.log(.trace, "No crops for this image.")
//                let _ = ImageFaceDao.default.updateImageRecognizedFace(imageId: imageId)
//                return false
//            }
//
//
//
//        }else{
//            self.logger.log(.trace, "ERROR: Image ID is not set.")
//            return false
//        }
//        return true
//    }
//
//    func recognizeFaces(path:String) -> Bool {
//        if let image = ImageRecordDao.default.getImage(path: path) {
//            return self.recognizeFaces(image: image)
//        }else{
//            self.logger.log(.trace, "ERROR: Cannot find image record: \(path)")
//            return false
//        }
//    }
}
