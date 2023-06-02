//
//  ContentView.swift
//  usageChecker
//
//  Created by lChen on 2023/5/26.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var userSettings = UserSettings()
    @State var tableSelected: String?

    var extensionString : String {
        var settings = [String]()
        var output = ""
        
        if userSettings.hCheckBox {
            settings.append("h")
        }
        if userSettings.mCheckBox {
            settings.append("m")
        }
        if userSettings.swiftCheckBox {
            settings.append("swift")
        }
        if userSettings.plistCheckBox {
            settings.append("plist")
        }
        if userSettings.storyboardCheckBox {
            settings.append("storyboard")
        }
        if userSettings.xibCheckBox {
            settings.append("xib")
        }
        
        for ext in settings {
            if output == "" {
                output = ext
            } else {
                output = output + " -o -name *.\(ext)"
            }
        }
        
        return output
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            //- Project ------------------------------
            Group {
                Spacer().frame(height: 5)
                HStack {
                    Text("Project").bold()
                        .fixedSize()
                    
                    VStack{ Divider() }
                }.frame(height: 24)
                HStack {
                    Spacer().frame(width: 10)
                    Text("Path")
                        .fixedSize()
                    Spacer().frame(width: 25)
                    TextField("" ,text: $userSettings.projectPath)
                        .cornerRadius(5)
                        .frame(minWidth: 350)
                        .disabled(viewModel.isUIDisable)
                    Button(action: {
                        self.browseButtonAction("projectPath")
                    }) {
                        Text("Browse")
                    }
                    .frame(minWidth: 120)
                    .disabled(viewModel.isUIDisable)
                    .buttonStyle(.borderedProminent)
                }.frame(height: 24)
                HStack(alignment: .top) {
                    Spacer().frame(width: 10)
                    Text("Target")
                        .fixedSize()
                    Picker(selection: $userSettings.isTargetPathHidden,
                           label: Text("")) {
                        Text("Image").tag(0).frame(minHeight: 24)
                        Text("Folder").tag(1).frame(minHeight: 24)
                    }
                    .pickerStyle(.radioGroup)
                    .disabled(viewModel.isUIDisable)
                    .frame(height: 48)
                    .fixedSize()
                    if userSettings.isTargetPathHidden == 1 {
                        VStack {
                            Spacer()
                            TextField("" ,text: $userSettings.targetPath)
                                .cornerRadius(5)
                                .frame(minWidth: 350)
                                .disabled(viewModel.isUIDisable)
                        }.frame(height: 48)
                        VStack {
                            Spacer()
                            Button(action: {
                                self.browseButtonAction("targetPath")
                            }) {
                                Text("Browse")
                            }.frame(minWidth: 120)
                                .disabled(viewModel.isUIDisable)
                                .buttonStyle(.borderedProminent)
                        }.frame(height: 48)

                    }
                }.frame(height: 48)
                if userSettings.isTargetPathHidden == 1 {
                    HStack {
                        Spacer().frame(width: 131)
                        Toggle("Search for directory only.", isOn: $userSettings.searchDirectoryOnly).disabled(viewModel.isUIDisable)
                    }.frame(height: 24)
                }
            }
            //- Setting ------------------------------
            Group {
                Spacer().frame(height: 15)
                HStack {
                    Text("Setting").bold()
                        .fixedSize()
                    VStack{ Divider() }
                }.frame(height: 24)
                HStack {
                    Spacer().frame(width: 10)
                    Text("Extension ")
                    Spacer().frame(width: 10)
                    VStack(alignment: .leading) {
                        Toggle(".h", isOn: $userSettings.hCheckBox).disabled(viewModel.isUIDisable)
                        Toggle(".m", isOn: $userSettings.mCheckBox).disabled(viewModel.isUIDisable)
                    }
                    VStack(alignment: .leading) {
                        Toggle(".swift", isOn: $userSettings.swiftCheckBox).disabled(viewModel.isUIDisable)
                        Toggle(".plist", isOn: $userSettings.plistCheckBox).disabled(viewModel.isUIDisable)
                    }
                    VStack(alignment: .leading) {
                        Toggle(".storyboard", isOn: $userSettings.storyboardCheckBox).disabled(viewModel.isUIDisable)
                        Toggle(".xib", isOn: $userSettings.xibCheckBox).disabled(viewModel.isUIDisable)
                    }
                    Spacer()
                }
            }
            //- Result ------------------------------
            Group {
                Spacer().frame(height: 15)
                HStack {
                    Text("Result").bold()
                        .fixedSize()
                        .multilineTextAlignment(TextAlignment.leading)
                    VStack{ Divider() }
                }
                Picker(selection: $viewModel.resultSegmented, label: Text("")) {
                    Text("Unused").tag(0)
                    Text("Depends On").tag(1)
                }.pickerStyle(.segmented)
                    .frame(width: 240)
                    .disabled(viewModel.isUIDisable)
                    .onChange(of: viewModel.resultSegmented) {
                        if (!viewModel.searchProgress.contains("Searching") && viewModel.searchProgress != "") {
                            viewModel.updateSearchProgress($0)
                        }
                    }
                Spacer().frame(height: 15)
                if viewModel.resultSegmented == 0 {
                    Table(viewModel.unusedData, selection: $tableSelected) {
                        TableColumn("Image") {
                            let encodingPath = $0.fileImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            AsyncImage(url: URL(string: encodingPath!)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(width: 21, height: 21)
                        }.width(min: 40, max: 80)
                        TableColumn("FileName", value: \.fileName).width(min: 100, max: 200)
                        TableColumn("Path", value: \.filePath).width(min: 200)
                    }.frame(minHeight: 200)
                        .tableStyle(.bordered(alternatesRowBackgrounds: true))
                    
                } else {
                    Table(viewModel.dependsOnData, selection: $tableSelected) {
                        TableColumn("FileName", value: \.fileName).width(min: 100, max: 200)
                        TableColumn("Depends On", value: \.dependsOn).width(min: 200)
                    }.frame(minHeight: 200)
                        .tableStyle(.bordered(alternatesRowBackgrounds: true))
                }
                
            }
            //- Srearch and Export Button ------------------------------
            Group {
                Spacer().frame(height: 15)
                HStack {
                    Button(action: {
                        self.searchButtonAction()
                    }) {
                        Text("Search")
                    }
                    .frame(minWidth: 100)
                    .disabled(viewModel.isUIDisable)
                    .buttonStyle(.borderedProminent)
                    
                    if viewModel.isUIDisable {
                        ProgressView().controlSize(.small)
                        Spacer().frame(width: 10)
                    }
                    Text(viewModel.searchProgress)
                    Spacer()
                    if !viewModel.isExportButtonHidden {
                        Button(action: {
                            self.exportButtonAction()
                        }) {
                            Text("Export")
                        }
                        .frame(minWidth: 100)
                        .disabled(viewModel.isUIDisable)
                        .buttonStyle(.borderedProminent)

                    }
                }
                Spacer().frame(height: 15)
            }
        }.padding()
        
        
    }
    //MARK: - Actions ------------------------------

    func browseButtonAction(_ sender: String) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        let okButtonPressed = openPanel.runModal() == .OK
        if okButtonPressed {
            // Update the path text field
            let path = openPanel.url?.path
            if sender == "projectPath" {
                userSettings.projectPath = path!
            } else if sender == "targetPath" {
                userSettings.targetPath = path!
            }
        }
    }
    
    func showAlert(with style: NSAlert.Style, title: String?, subtitle: String?) {
        let alert = NSAlert()
        alert.alertStyle = style
        alert.messageText = title ?? ""
        alert.informativeText = subtitle ?? ""
        alert.runModal()
    }
    
    func searchButtonAction() {
        
        let ext = extensionString
        var errorMessage = ""
        
        if userSettings.projectPath.isEmpty || (userSettings.isTargetPathHidden != 0 && userSettings.targetPath.isEmpty) {
            errorMessage = "Path cannot be empty."
        }
        if !FileManager.default.fileExists(atPath: userSettings.projectPath) || (userSettings.isTargetPathHidden != 0 && !FileManager.default.fileExists(atPath: userSettings.targetPath)) {
            errorMessage = "Please check the path."
        }
        if ext.isEmpty {
            errorMessage = "Setting cannot be empty."
        }
        
        guard errorMessage == "" else {
            showAlert(with: .warning, title: "Error", subtitle: errorMessage)
            return
        }
        let path = userSettings.isTargetPathHidden == 0 ? userSettings.projectPath : userSettings.targetPath
        viewModel.setupTargetArray(targetType: userSettings.isTargetPathHidden, path: path, dirOnly: userSettings.searchDirectoryOnly)
        viewModel.doFilesCheck(userSettings.projectPath, type: ext)
    }
    
    func createCSV(from array: [UnusedModel]) -> String {
        guard array.count > 0 else { return "" }
        var csvString = "\("FileName"),\("Path")\n\n"
        for data in array {
            csvString = csvString.appending("\(data.fileName) ,\(data.filePath)\n")
        }
        return csvString
    }
    
    func createCSV(from array: [DependsOnModel]) -> String {
        guard array.count > 0 else { return "" }
        var csvString = "\("FileName"),\("Depends On")\n\n"
        for data in array {
            let dependsArray = data.dependsOn.components(separatedBy: "; ")
            var appendString = data.fileName
            for depends in dependsArray where depends != "" {
                appendString = appendString + " ," + depends
            }
            appendString = appendString + "\n"
            csvString = csvString.appending(appendString)
        }
        return csvString
    }
    
    func exportButtonAction() {
        var exportData = ""
        var exportFileName = ""
        if viewModel.resultSegmented == 0 {
            exportData = self.createCSV(from: viewModel.unusedData)
            exportFileName = "UnusedFiles.csv"

        } else {
            exportData = self.createCSV(from: viewModel.dependsOnData)
            exportFileName = "DependsOnFiles.csv"
        }
        
        guard exportData != "" else {
            showAlert(with: .warning, title: "Error", subtitle: "Unable export the data.")
            return
        }
        
        let savePanel = NSSavePanel()
          savePanel.title = "Save"
          savePanel.nameFieldStringValue = exportFileName
        
        let okButtonPressed = savePanel.runModal() == .OK
        if okButtonPressed {
            let selectedFile = savePanel.url?.path
            try? exportData.write(toFile: selectedFile ?? "", atomically: true, encoding: .utf8)
        }
    }
    
}

class UserSettings: ObservableObject {
        
    @Published var projectPath: String {
        didSet {
            UserDefaults.standard.set(projectPath, forKey: "projectPath")
        }
    }
    @Published var targetPath: String {
        didSet {
            UserDefaults.standard.set(targetPath, forKey: "targetPath")
        }
    }
    @Published var isTargetPathHidden: Int {
        didSet {
            UserDefaults.standard.set(isTargetPathHidden, forKey: "isTargetPathHidden")
        }
    }
    @Published var searchDirectoryOnly: Bool {
        didSet {
            UserDefaults.standard.set(searchDirectoryOnly, forKey: "searchDirectoryOnly")
        }
    }
    @Published var hCheckBox: Bool {
        didSet {
            UserDefaults.standard.set(hCheckBox, forKey: "hCheckBox")
        }
    }
    @Published var mCheckBox: Bool {
        didSet {
            UserDefaults.standard.set(mCheckBox, forKey: "mCheckBox")
        }
    }
    @Published var swiftCheckBox: Bool {
        didSet {
            UserDefaults.standard.set(swiftCheckBox, forKey: "swiftCheckBox")
        }
    }
    @Published var plistCheckBox: Bool {
        didSet {
            UserDefaults.standard.set(plistCheckBox, forKey: "plistCheckBox")
        }
    }
    @Published var storyboardCheckBox: Bool {
        didSet {
            UserDefaults.standard.set(storyboardCheckBox, forKey: "storyboardCheckBox")
        }
    }
    @Published var xibCheckBox: Bool {
        didSet {
            UserDefaults.standard.set(xibCheckBox, forKey: "xibCheckBox")
        }
    }

    init() {
        self.projectPath = UserDefaults.standard.string(forKey: "projectPath") ?? ""
        self.isTargetPathHidden = UserDefaults.standard.integer(forKey: "isTargetPathHidden")
        if UserDefaults.standard.integer(forKey: "isTargetPathHidden") == 2 {
            self.targetPath = ""
        } else {
            self.targetPath = UserDefaults.standard.string(forKey: "targetPath") ?? ""
        }
        self.searchDirectoryOnly = UserDefaults.standard.bool(forKey: "searchDirectoryOnly")
        self.hCheckBox = UserDefaults.standard.bool(forKey: "hCheckBox")
        self.mCheckBox = UserDefaults.standard.bool(forKey: "mCheckBox")
        self.swiftCheckBox = UserDefaults.standard.bool(forKey: "swiftCheckBox")
        self.plistCheckBox = UserDefaults.standard.bool(forKey: "plistCheckBox")
        self.storyboardCheckBox = UserDefaults.standard.bool(forKey: "storyboardCheckBox")
        self.xibCheckBox = UserDefaults.standard.bool(forKey: "xibCheckBox")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
