//
//  Utilities.swift
//  usageChecker
//
//  Created by lChen on 2023/5/26.
//

import Cocoa

class Utilities: NSObject {
    
    static let shared = Utilities()

    func imageFiles(_ path: String) -> [String] {
        var imageArray = [String]()
        let jpgFile = self.shellScript_Find(path, type: "jpg")
        if let jpgFiles = jpgFile {
            imageArray.append(contentsOf: jpgFiles)
        }
        let jpegFile = self.shellScript_Find(path, type: "jpeg")
        if let jpegFiles = jpegFile {
            imageArray.append(contentsOf: jpegFiles)
        }
        let pngFile = self.shellScript_Find(path, type: "png")
        if let pngFiles = pngFile {
            imageArray.append(contentsOf: pngFiles)
        }
        let gifFile = self.shellScript_Find(path, type: "gif")
        if let gifFiles = gifFile {
            imageArray.append(contentsOf: gifFiles)
        }
        return imageArray
    }
    
    func sourceCodeFiles(_ path: String) -> [String] {
        var fileArray = [String]()
        let hmcaFile = self.shellScript_Find(path, type: "[hm]")
        if let hmcaFiles = hmcaFile {
            fileArray.append(contentsOf: hmcaFiles)
        }
        let swiftFile = self.shellScript_Find(path, type: "swift")
        if let swiftFiles = swiftFile {
            fileArray.append(contentsOf: swiftFiles)
        }
        return fileArray
    }
    
    func directorys(_ path: String, dirOnly: Bool) -> [String]  {
        var packageArray = [String]()

        let scriptOutput = self.shellScript_ls(path, dirOnly: dirOnly)
        if let packages = scriptOutput {
            packageArray.append(contentsOf: packages)
        }
        return packageArray
    }

    func shellScript_Find(_ path: String, type: String) -> [String]? {
        
        let task = Process()
        task.launchPath = "/usr/bin/find"
        
        let para = [path, "-name", "*.\(type)"]
        task.arguments = para
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let file = pipe.fileHandleForReading
        let data = file.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        let resultArray = output?.components(separatedBy: "\n")
        var finalOutput = resultArray?.filter{ !$0.contains("AppIcon.appiconset") }
        finalOutput = finalOutput?.filter{ !$0.contains("LaunchImage.launchimage") }
        finalOutput = finalOutput?.filter{ !$0.contains(".xcarchive") }
        finalOutput = finalOutput?.filter{ !$0.contains("@2x") }
        finalOutput = finalOutput?.filter{ !$0.contains("@3x") }
        finalOutput?.removeLast()
        return finalOutput
    }
    
    func shellScript_ls(_ path: String, dirOnly: Bool) -> [String]? {
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        
        let para = ["ls", path]
        task.arguments = para
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let file = pipe.fileHandleForReading
        let data = file.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        guard let resultArray = output?.components(separatedBy: "\n") else { return nil }
        var finalOutput = [String]()
        for result in resultArray where result != "" {
            let file = path + "/\(result)"
            if dirOnly {
                let targetFile = "file://" + file
                if let targetFileURL = URL(string: targetFile) {
                    let isDirectory = (try? targetFileURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
                    if isDirectory {
                        finalOutput.append(file)
                    }
                }
            } else {
                finalOutput.append(file)
            }
        }
        return finalOutput
    }
}
