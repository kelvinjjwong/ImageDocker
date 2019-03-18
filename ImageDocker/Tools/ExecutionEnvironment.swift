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
    
    fileprivate let RUBY = URL(fileURLWithPath: "/usr/bin/ruby")
    
    func installHomebrew() -> String{
        var result = ""
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = RUBY.path
            cmd.arguments = ["-e", "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""]
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
    
    func uninstallHomebrew() -> String{
        var result = ""
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = RUBY.path
            cmd.arguments = ["-e", "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)\""]
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
    
    func locate(_ command:String) -> String{
        var paths:[String] = ["/usr/local/bin","/usr/bin","/bin","/usr/sbin","/sbin"]
        autoreleasepool { () -> Void in
            let taskShell = Process()
            taskShell.launchPath = "/bin/ls"
            taskShell.arguments = ["-r", "/Library/Frameworks/Python.framework/Versions/"]
            let pipeShell = Pipe()
            taskShell.standardOutput = pipeShell
            taskShell.standardError = pipeShell
            taskShell.launch()
            taskShell.waitUntilExit()
            let data = pipeShell.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: String.Encoding.utf8)!
            pipeShell.fileHandleForReading.closeFile()
            if output != "" {
                let versions = output.components(separatedBy: "\n")
                for version in versions {
                    paths.append("/Library/Frameworks/Python.framework/Versions/\(version)/bin")
                }
            }
        }
        
        for path in paths {
            let p = URL(fileURLWithPath: path).appendingPathComponent(command).path
            //print(p)
            if FileManager.default.fileExists(atPath: p) {
                return p
            }
        }
        return ""
    }
    
    func pipList(_ pipPath:String) -> Set<String>{
        print("calling pip: \(pipPath)")
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
            print(string)
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
    
    static let instructionForDlibFaceRecognition = """
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
    
    static let componentsForDlibFaceRecognition:[String] = ["boost-python", "numpy", "dlib", "imutils", "opencv-python", "face-recognition"]
    

}
