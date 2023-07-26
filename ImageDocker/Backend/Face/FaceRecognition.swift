//
//  FaceRecognition.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/17.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

//import Foundation
//
//struct FaceRecognition {
//    
//    static let `default` = FaceRecognitionOpenCV()
//    
//    static let defaultModelPath = PreferencesController.databasePath(filename: "faceRecognitionModel.pickle")
//    static let trainingSamplePath = PreferencesController.databasePath(filename: "faceTrainingSamples")
//    
//    static func selectedModelPath() -> String {
//        let option = PreferencesController.faceRecognitionModel()
//        if option == "alternative" {
//            let alternative = PreferencesController.alternativeFaceModel()
//            if alternative != "" {
//                return alternative
//            }
//        }
//        return defaultModelPath
//    }
//
//}
//
//struct FaceRecognitionOpenCV {
//    
//    let logger = LoggerFactory.get(category: "FaceRecognitionOpenCV")
//    
//    fileprivate var workingPath: URL
//    
//    init() {
//        if let workingUrl = Bundle.main.url(forResource: "FaceRecognitionOpenCV", withExtension: nil) {
//            workingPath = workingUrl
//        } else {
//            fatalError("The Application Bundle is corrupt.")
//        }
//    }
//    
//    func training(dataSetPath:String = FaceRecognition.trainingSamplePath, modelPath:String = FaceRecognition.defaultModelPath, onOutput:@escaping (String) -> Void) {
//        self.logger.log("training")
//        self.logger.log(dataSetPath)
//        self.logger.log(modelPath)
//        
//        let python = PreferencesController.pythonPath()
//        if python == "" {
//            self.logger.log("Path for python has not been located.")
//            return
//        }
//        if !FileManager.default.fileExists(atPath: python) {
//            self.logger.log("Python not found in \(python)")
//            return
//        }
//        
//        let pipe = Pipe()
//        
//        autoreleasepool { () -> Void in
//            let cmd = Process()
//            cmd.standardOutput = pipe
//            cmd.standardError = pipe
//            cmd.launchPath = python
//            cmd.currentDirectoryPath = workingPath.path
//            cmd.arguments = ["encode_faces.py", "--dataset", dataSetPath.withStash(), "--encodings", modelPath]
//            
//            let outHandle = pipe.fileHandleForReading
//            outHandle.waitForDataInBackgroundAndNotify()
//            
//            
//            var obs1 : NSObjectProtocol!
//            obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
//                                                          object: outHandle, queue: nil) {  notification in
//                                                            let data = outHandle.availableData
//                                                            if data.count > 0 {
//                                                                if let str = String(data: data, encoding: String.Encoding.utf8) {
//                                                                    self.logger.log("got output: \(str)")
//                                                                    onOutput(str)
//                                                                }
//                                                                //outHandle.waitForDataInBackgroundAndNotify()
//                                                            } else {
//                                                                self.logger.log("EOF on stdout from process")
//                                                                outHandle.closeFile()
//                                                                NotificationCenter.default.removeObserver(obs1!)
//                                                            }
//            }
//
//            var obs2 : NSObjectProtocol!
//            obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
//                                                          object: cmd, queue: nil) { notification in
//                                                            self.logger.log("terminated")
//                                                            outHandle.closeFile()
//                                                            NotificationCenter.default.removeObserver(obs2!)
//            }
//            
//            cmd.launch()
//            cmd.waitUntilExit()
//        }
//    }
//    
//    func recognize(imagePath:String, modelPath:String = FaceRecognition.selectedModelPath()) -> [String]{
//        
//        let pipe = Pipe()
//        
//        var result:[String] = []
//        
//        var modelpath = modelPath
//        if !FileManager.default.fileExists(atPath: modelpath) {
//            modelpath = FaceRecognition.defaultModelPath
//        }
//        if !FileManager.default.fileExists(atPath: modelpath) {
//            self.logger.log("No available encoded model for recognition")
//            return []
//        }
//        
//        let python = PreferencesController.pythonPath()
//        if python == "" {
//            self.logger.log("Path for python has not been located.")
//            return []
//        }
//        if !FileManager.default.fileExists(atPath: python) {
//            self.logger.log("Python not found in \(python)")
//            return []
//        }
//        
//        autoreleasepool { () -> Void in
//            let cmd = Process()
//            cmd.standardOutput = pipe
//            cmd.standardError = pipe
//            cmd.launchPath = python
//            cmd.currentDirectoryPath = workingPath.path
//            cmd.arguments = ["recognize_faces_image.py", "--encodings", modelpath, "--image", imagePath, "--display", "0"]
//            do {
//                try cmd.run()
//            }catch{
//                self.logger.log(error)
//            }
//            
//            let data = pipe.fileHandleForReading.readDataToEndOfFile()
//            let string = String(data: data, encoding: String.Encoding.utf8)!
//            pipe.fileHandleForReading.closeFile()
//            
//            self.logger.log(string)
//            
//            let lines = string.components(separatedBy: "\n")
//            for line in lines {
//                self.logger.log(line)
//                if line.starts(with: "RECOGNITION RESULT:") {
//                    //self.logger.log(line)
//                    let parts = line.components(separatedBy: " ")
//                    if parts.count == 7 && parts[6] != "" {
//                        let name = parts[6]
//                        result.append(name)
//                        self.logger.log("Found face [\(name)] from image \(imagePath)")
//                    }
//                }
//            }
//        }
//        return result
//    }
//}
