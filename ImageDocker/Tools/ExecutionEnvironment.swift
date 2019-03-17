//
//  ExecutionEnvironment.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/17.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

struct ExecutionEnvironment {
    
    static let `default` = ExecutionEnvironment()
    
    fileprivate let WHICH = URL(fileURLWithPath: "/usr/bin/which")
    
    func locate(_ command:String) -> String{
        var result = ""
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = WHICH.path
            cmd.arguments = [command]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            result = string
        }
        return result
    }
    
    func pipList(_ pipPath:String) -> Set<String>{
        var result:Set<String> = []
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = pipPath
            cmd.arguments = ["list"]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                let part = line.components(separatedBy: " ")
                if !part[0].starts(with: "Package") && !part[0].starts(with: "-") {
                    result.insert(part[0])
                }
            }
        }
        return result
    }
    
    
    
    func brewList(_ brewPath:String) -> Set<String>{
        var result:Set<String> = []
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = brewPath
            cmd.arguments = ["list"]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                let parts = line.components(separatedBy: " ")
                for part in parts {
                    if part != "" {
                        result.insert(part)
                    }
                }
            }
        }
        return result
    }
    
    func brewCaskList(_ brewPath:String) -> Set<String>{
        var result:Set<String> = []
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = brewPath
            cmd.arguments = ["cask", "list"]
            do {
                try cmd.run()
            }catch{
                print(error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                let parts = line.components(separatedBy: " ")
                for part in parts {
                    if part != "" {
                        result.insert(part)
                    }
                }
            }
        }
        return result
    }
    
    func instructionForDlibFaceRecognition() -> String {
        return """
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"

        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        
        brew install python3
        
        brew cask install xquartz
        
        brew install gtk+3 boost
        
        brew install boost-python
        
        pip3 install virtualenv virtualenvwrapper
        
        pip3 install numpy scipy matplotlib scikit-image scikit-learn ipython
        
        brew install dlib
        
        pip3 install imutils
        
        pip3 install opencv-python
        
        brew install cmake
        
        pip3 install face_recognition
        
"""
    }
    
    let componentsForDlibFaceRecognition:Set<String> = ["xquartz", "gtk+3", "boost-python", "virtualenv", "virtualenvwrapper", "numpy",
                                                        "scipy", "matplotlib", "scikit-image", "scikit-learn", "ipython", "dlib", "imutils",
                                                        "opencv-python", "cmake", "face_recognition"]
}
