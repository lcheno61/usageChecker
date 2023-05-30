//
//  Utilities.swift
//  usageChecker
//
//  Created by lChen on 2023/5/26.
//

import Cocoa

class Utilities: NSObject {
    
    static let shared = Utilities()

    func imageFiles(_ dir: String) -> [String] {
        var imageArray = [String]()
        let jpgFile = self.shellScript_Find(dir, type: "jpg")
        if let jpgFiles = jpgFile {
            imageArray.append(contentsOf: jpgFiles)
        }
        let jpegFile = self.shellScript_Find(dir, type: "jpeg")
        if let jpegFiles = jpegFile {
            imageArray.append(contentsOf: jpegFiles)
        }
        let pngFile = self.shellScript_Find(dir, type: "png")
        if let pngFiles = pngFile {
            imageArray.append(contentsOf: pngFiles)
        }
        let gifFile = self.shellScript_Find(dir, type: "gif")
        if let gifFiles = gifFile {
            imageArray.append(contentsOf: gifFiles)
        }
        return imageArray
    }
    
    func sourceCodeFiles(_ dir: String) -> [String] {
        var fileArray = [String]()
        let hmcaFile = self.shellScript_Find(dir, type: "[hm]")
        if let hmcaFiles = hmcaFile {
            fileArray.append(contentsOf: hmcaFiles)
        }
        let swiftFile = self.shellScript_Find(dir, type: "swift")
        if let swiftFiles = swiftFile {
            fileArray.append(contentsOf: swiftFiles)
        }
        return fileArray
    }

    func shellScript_Find(_ dir: String, type: String) -> [String]? {
        
        let task = Process()
        task.launchPath = "/usr/bin/find"
        
        let para = [dir, "-name", "*.\(type)"]
        task.arguments = (para as! [String])
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let file = pipe.fileHandleForReading
        let data = file.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        let result = output?.components(separatedBy: "\n")
        var resultArray = result?.filter{ !$0.contains("AppIcon.appiconset") }
        resultArray = resultArray?.filter{ !$0.contains("LaunchImage.launchimage") }
        resultArray = resultArray?.filter{ !$0.contains(".xcarchive") }
        resultArray = resultArray?.filter{ !$0.contains("@2x") }
        resultArray = resultArray?.filter{ !$0.contains("@3x") }

        return resultArray
    }
}
