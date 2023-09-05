//
//  ContentView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 6/26/23.
//

import SwiftUI


let plotDimensions: [[String: Double]] = [
    ["x": 0,     "y": 0],     // models are 1-indexed
    ["x": 11.81, "y": 8.58],  // V2, V3, SE/A4
    ["x": 16.93, "y": 11.69], // V3/A3, SE/A3
    ["x": 23.42, "y": 8.58],  // V3 XLX
    ["x": 6.3,   "y": 4],     // MiniKit
    ["x": 34.02, "y": 23.39], // SE/A1
    ["x": 23.39, "y": 17.01], // SE/A2
    ["x": 7.48,  "y": 5.51]   // V3/B6
]

struct ContentView: View {
    @AppStorage("modelNumber") var modelNumber = 1
    @AppStorage("modelIndex") var modelIndex = 1
    
    @AppStorage("reorderNumber") var reorderNumber = 1
    @AppStorage("reorderIndex") var reorderIndex = 1
    @AppStorage("runWebhook") var runWebhook = false
    @AppStorage("webhookURL") var webhookURL = ""
    @AppStorage("speed") var speed = 25.0
    
    
    @State var removeHiddenLines = false
    
    @State var isRunning = false
    @State var outputMessage = ""
    @State var errorMessage = ""
    
    @State var currentFileURL: URL?
    @State var originalFileURL: URL?
    
    @State var showPopover = false
    
    @State var tempCount = 0
    
    @State var error = ""
    @State var showError = false
    
    @State private var runningProcess: Process?
    @State var isPlotting = false
    
    @State var plotSingleLayer = false
    @State var singleLayerNum = "1"
    
    let axiURL = URL(fileURLWithPath: "/usr/local/bin/axicli")
    
    func onFilePathChanged(url: URL) {
        currentFileURL = url
        originalFileURL = url
        tempCount = 0
        onPreviewInvalidated()
    }
    
    func goHome() {
        sendAxiCommand( "-m manual -M walk_home")
    }
    
    func runAxiCLI(args: [String]) {
        Task {
            do {
                let outputPipe = Pipe()
                let errorPipe = Pipe()
                self.isRunning = true
                
                var newArgs = args + ["--model", String(modelNumber), "--reordering", String(reorderNumber), "--speed_pendown", String(Int(speed)) ]
                
                if(plotSingleLayer){
                    if let layerNum = Int(singleLayerNum){
                        if(layerNum > 0 && layerNum <= 1000){
                            newArgs = newArgs + ["--layer", "\(layerNum)"]
                        }
                    }
                }
                
                if(runWebhook && webhookURL.count > 0){
                    newArgs = newArgs + ["--webhook", "--webhook_url", webhookURL]
                }
                
                if(removeHiddenLines){
                    newArgs = newArgs + ["--hiding"]
                }
                
                print(newArgs.joined(separator: " "))
                
                let task = Process()
                task.executableURL = axiURL
                task.standardOutput = outputPipe
                task.standardError = errorPipe
                
                task.arguments = newArgs
                
                task.terminationHandler = { _ in
                    DispatchQueue.main.async {
                        self.isRunning = false
                        self.isPlotting = false

                        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        outputMessage = String(decoding: outputData, as: UTF8.self)

                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        errorMessage = String(decoding: errorData, as: UTF8.self)

                        if(errorMessage.count > 0){
                            // time estimate is sent through standard error
                            if(errorMessage.hasPrefix("Estimated print time:")) {
                                outputMessage = errorMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                            } else {
                                showError = true
                            }
                        }
                    }
                }
                
                try task.run()
                runningProcess = task
                
            } catch {
                errorMessage = "Error sending command"
                showError = true
            }
        }
    }
    
    func sendAxiCommand(_ cmd: String, withFile path: String) {
        let args = cmd.components(separatedBy: " ")
        runAxiCLI(args: [path] + args)
    }
    
    func sendAxiCommand(_ cmd: String) {
        print("command: " + cmd)
        let args = cmd.components(separatedBy: " ")
        runAxiCLI(args: args)
    }
    
    func version() {
        sendAxiCommand( "--version")
    }
    
    func disableMotors() {
        sendAxiCommand("-m manual -M disable_xy")
    }
    
    func enableMotors() {
        sendAxiCommand("-m manual -M enable_xy")
    }
    
    func walkX() {
        if let dist = plotDimensions[modelNumber]["x"] {
            sendAxiCommand("-m manual -M walk_x --dist \(dist)")
        }
    }
    
    func walkY() {
        if let dist = plotDimensions[modelNumber]["y"] {
            sendAxiCommand("-m manual -M walk_y --dist \(dist)")
        }
    }
    
    func runPreview() {
        if let url = currentFileURL {
            sendAxiCommand("-v --report_time", withFile: url.path)
        }
       
    }
    
    func penUp() {
        sendAxiCommand("-m manual -M raise_pen")
    }
    
    func penDown() {
        sendAxiCommand("-m manual -M lower_pen")
    }
    
    func getNewOutputPath(path: URL)->String {
        tempCount = tempCount+1
        let outputPath = path.deletingPathExtension().path + "-tmp\(tempCount).svg"
        return outputPath
    }
    
    func getCurrentOutputPath(path: URL)->String {
        return path.deletingPathExtension().path + "-tmp\(tempCount).svg"
    }
    
    func startPlot() {
        if let url = currentFileURL {
            if let original = originalFileURL {
                let outputPath = getNewOutputPath(path: original)
                isPlotting = true
                runAxiCLI(args: [url.path, "-o", outputPath])
            }
        }
    }
    
    func terminatePlot() {
        runningProcess?.terminate()
        goHome()
    }
    
    func resumeFromLocation() {
        if let original = originalFileURL {
            let url = getCurrentOutputPath(path: original)
            let outputPath = getNewOutputPath(path: original)
            currentFileURL = URL(string: url)
            isPlotting = true
            runAxiCLI(args: [url, "--mode", "res_plot", "-o", outputPath])
        }
    }
    
    func resumeFromHome() {
        if let original = originalFileURL {
            let url = getCurrentOutputPath(path: original)
            let outputPath = getNewOutputPath(path: original)
            currentFileURL = URL(string: url)
            runAxiCLI(args: [url, "--mode", "res_home", "-o", outputPath])
        }
    }
    
    func outputFileExists() -> Bool {
        guard let original = originalFileURL else { return false }
        let output = getCurrentOutputPath(path: original)
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: output)
    }
    
    func onPreviewInvalidated(){
        outputMessage = ""
    }
    

    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(spacing: 0){
                SidebarView(modelNumber:$modelNumber, modelIndex: $modelIndex, reorderIndex: $reorderIndex, reorderNumber: $reorderNumber, removeHiddenLines: $removeHiddenLines, runWebhook: $runWebhook, webhookURL: $webhookURL, showPopover: $showPopover, speed: $speed, singleLayer: $plotSingleLayer, layerNum: $singleLayerNum, goHome: goHome, walkX: walkX, walkY: walkY, enableMotors: enableMotors, disableMotors: disableMotors, penUp: penUp, penDown: penDown,onPreviewInvalidated: onPreviewInvalidated, hasFile: currentFileURL != nil, output: outputMessage)
                DragDropContentView(onFileDropped: onFilePathChanged)
            }.frame(maxWidth: .infinity)
            CommandBarView(startPlot: startPlot, resumeFromLocation: resumeFromLocation, resumeFromHome: resumeFromHome, runPreview: runPreview, hasFile: currentFileURL != nil, hasOutputFile: outputFileExists())
        }.alert(errorMessage, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
//        .alert("Plot is running", isPresented: $isRunning) {
//            Button("Cancel Plot", role: .cancel, action: terminatePlot)
//        }
//        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
