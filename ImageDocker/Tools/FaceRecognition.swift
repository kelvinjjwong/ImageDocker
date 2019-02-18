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
    static let trainingSamplePath = PreferencesController.databasePath(filename: "faceTrainingSamples")

}

struct FaceRecognitionOpenCV {
    
    fileprivate var python: URL
    
    init() {
        if let pythonUrl = Bundle.main.url(forResource: "FaceRecognitionOpenCV", withExtension: nil) {
            python = pythonUrl.appendingPathComponent("python3")
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
            cmd.arguments = ["encode_faces.py", "--dataset", dataSetPath.withStash(), "--encodings", modelPath]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            print(string)
        }
    }
    
    func recognize(imagePath:String, modelPath:String = FaceRecognition.recognitionModelPath) -> [String]{
        
        let pipe = Pipe()
        
        var result:[String] = []
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = python.path
            cmd.arguments = ["recognize_faces_image.py", "--encodings", modelPath, "--image", imagePath, "--display", "0"]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
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
