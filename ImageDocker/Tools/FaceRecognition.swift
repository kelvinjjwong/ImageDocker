//
//  FaceRecognition.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/17.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Foundation

struct FaceRecognition {
    
    static let `default` = FaceRecognitionOpenCV()
    
    static let recognitionModelPath = PreferencesController.databasePath(filename: "faceRecognitionModel.pickle")
    static let recognitionModelPath2 = URL(fileURLWithPath: "/Users/kelvinwong/git-other/face-recognition-opencv/family.pickle").path
    static let trainingSamplePath = PreferencesController.databasePath(filename: "faceTrainingSamples")

}

struct FaceRecognitionOpenCV {
    
    fileprivate var python: URL = URL(fileURLWithPath: "/Library/Frameworks/Python.framework/Versions/3.7/bin/python3")
    fileprivate var workingPath: URL
    
    init() {
        if let workingUrl = Bundle.main.url(forResource: "FaceRecognitionOpenCV", withExtension: nil) {
            workingPath = workingUrl
        } else {
            fatalError("The Application Bundle is corrupt.")
        }
    }
    
    func training(dataSetPath:String = FaceRecognition.trainingSamplePath, modelPath:String = FaceRecognition.recognitionModelPath) {
        
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = python.path
            cmd.currentDirectoryPath = workingPath.path
            cmd.arguments = ["encode_faces.py", "--dataset", dataSetPath.withStash(), "--encodings", modelPath]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            print(string)
        }
    }
    
    func recognize(imagePath:String, modelPath:String = FaceRecognition.recognitionModelPath) -> [String]{
        
        let pipe = Pipe()
        
        var result:[String] = []
        
        var modelpath = modelPath
        if !FileManager.default.fileExists(atPath: modelpath) {
            modelpath = FaceRecognition.recognitionModelPath2
        }
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = python.path
            cmd.currentDirectoryPath = workingPath.path
            cmd.arguments = ["recognize_faces_image.py", "--encodings", modelpath, "--image", imagePath, "--display", "0"]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            print(string)
            
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                print(line)
                if line.starts(with: "RECOGNITION RESULT:") {
                    //print(line)
                    let parts = line.components(separatedBy: " ")
                    if parts.count == 7 && parts[6] != "" {
                        let name = parts[6]
                        result.append(name)
                        print("Found face [\(name)] from image \(imagePath)")
                    }
                }
            }
        }
        return result
    }
}
