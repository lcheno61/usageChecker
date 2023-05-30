//
//  ViewModel.swift
//  usageChecker
//
//  Created by lChen on 2023/5/26.
//

import AppKit
import Foundation
extension ContentView {
    class ViewModel: ObservableObject {
        
        var dataLock: NSLock?
        var progress = 0
        var spentTime = ""
        
        @Published var unusedData = [UnusedModel]()
        @Published var dependsOnData = [DependsOnModel]()
        @Published var searchProgress = ""
        @Published var isUIDisable = false
        @Published var isExportButtonHidden = true
        @Published var resultSegmented = 0
        
        init() {
            dataLock = NSLock()
        }
        
        
        func doFilesCheck(_ path: String, targetPath: String? = "", type: String){
            
            unusedData.removeAll()
            dependsOnData.removeAll()
            progress = 0
            spentTime = ""
            isUIDisable = true
            let startTime = Date()
            
            var targetFiles = [String]()
            if targetPath == "" {
                targetFiles = Utilities.shared.imageFiles(path)
            } else {
                targetFiles = Utilities.shared.sourceCodeFiles(path)
            }
            let targetCount = targetFiles.count
            
            DispatchQueue.global(qos: .background).async {
                for file in targetFiles where file != "" {
                    self.progress += 1
                    let strFile = "file://" +  file
                    let cmdOutput = self.checkDependsOn(strFile, dir: path, type: type)
                    DispatchGroup().notify(queue: DispatchQueue.main) {
                        DispatchQueue.main.async {
                            if cmdOutput.count == 0 {
                                let unUsedFile = UnusedModel(fileImage: cmdOutput.filePath, fileName: cmdOutput.fileName, filePath: cmdOutput.filePath)
                                self.unusedData.append(unUsedFile)
                            } else if cmdOutput.count > 0 {
                                let dependsOnFile = DependsOnModel(identifier: cmdOutput.identifier, fileName: cmdOutput.fileName, dependsOn: cmdOutput.dependsOn)
                                self.dependsOnData.append(dependsOnFile)
                            }
                            self.searchProgress = "Searching ... \(self.progress) / \(targetCount)"
                        }
                    }
                }
                DispatchGroup().notify(queue: DispatchQueue.main) {
                    DispatchQueue.main.async {
                        let time: TimeInterval = Date().timeIntervalSince(startTime)
                        self.spentTime = String(format: " Time : %.2fs ", arguments: [time])
                        self.updateSearchProgress(self.resultSegmented)
                        self.isUIDisable = false
                        self.isExportButtonHidden = false
                    }
                }
            }
        }
        
        func checkDependsOn(_ fileName: String,  dir: String,  type: String) -> cmdOutputModel {
            
            dataLock = NSLock()
//            let key = "\(fileName)"
            var count = 0
            
            let encodingFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let fileURL = URL(string: encodingFileName!)
            let fileNameWithoutPath = fileURL!.lastPathComponent
            let name = URL(fileURLWithPath: fileNameWithoutPath, isDirectory: false).deletingPathExtension().lastPathComponent
            
            let cmd = "for filename in `find \(dir) -name *.\(type)`; do if (cat $filename 2>/dev/null | grep -o \(name)); then dependfiles=`basename -a $filename`; echo $dependfiles; else echo UnusedFile; fi; done;"
            let process = Process()
            process.launchPath = "/bin/sh"
            let para = ["-c", cmd]
            process.arguments = para
            let pipe = Pipe()
            process.standardOutput = pipe
            process.launch()
            
            var dependsOnFilesString = ""
            let output = pipe.fileHandleForReading.readDataToEndOfFile()
            let outputString = String(data: output, encoding: .utf8)
            
            guard let result = outputString else { return cmdOutputModel(identifier: "", fileName: "", filePath: "", dependsOn: "", count: -2) }
            let results = result.replacingOccurrences(of: "\(name)\n", with: "")
            let resultsArray = results.components(separatedBy: "\n")
            
            for data in resultsArray where (data != "" && data != "UnusedFile"){
                count += 1
                if dependsOnFilesString == "" {
                    dependsOnFilesString = data
                } else {
                    dependsOnFilesString = dependsOnFilesString + "; \(data)"
                }
            }
            let cmdOutput = cmdOutputModel(identifier: fileName, fileName: fileNameWithoutPath, filePath: fileName, dependsOn: dependsOnFilesString, count: count)
//            print("string[\(fileName)] = [\(count)] \(dependsOnFilesString)")
            dataLock!.unlock()
             return cmdOutput
        }
        
        func updateSearchProgress(_ segmente: Int) {
            if segmente == 0 {
                searchProgress = "Found : \(unusedData.count) files  / " + spentTime
            } else {
                searchProgress = "Found : \(dependsOnData.count) files  / " + spentTime
            }
        }
        
    }

}
