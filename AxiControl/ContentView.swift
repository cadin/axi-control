//
//  ContentView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 6/26/23.
//

import SwiftUI


struct ContentView: View {
    @AppStorage("modelNumber") var modelNumber = 1
    @AppStorage("modelIndex") var modelIndex = 1
    
    @AppStorage("reorderNumber") var reorderNumber = 1
    @AppStorage("reorderIndex") var reorderIndex = 1
    @AppStorage("runWebhook") var runWebhook = false
    @AppStorage("webhookURL") var webhookURL = ""
    
    @State var removeHiddenLines = false
    
    @State var isRunning = false
    @State var outputMessage = ""
    @State var errorMessage = ""
    
    @State var currentFileURL: URL?
    @State var originalFileURL: URL?
    
    @State var showPopover = false
    
    @State var tempCount = 1
    
    @State var error = ""
    @State var showError = false
    
    let axiURL = URL(fileURLWithPath: "/usr/local/bin/axicli")
    
    func onFilePathChanged(url: URL) {
        currentFileURL = url
        originalFileURL = url
        tempCount = 1
    }
    
    func goHome() {
        sendAxiCommand( "-m manual -M walk_home")
    }
    
    func runAxiCLI(args: [String]) {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        self.isRunning = true
            
        var newArgs = args + ["--model", String(modelNumber), "--reordering", String(reorderNumber)]
        if(webhookURL.count > 0){
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
        task.terminationHandler = { _ in self.isRunning = false }
        
        try! task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        outputMessage = String(decoding: outputData, as: UTF8.self)
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        errorMessage = String(decoding: errorData, as: UTF8.self)


        if(errorMessage.count > 0){
            showError = true
        }
        
        print(outputMessage)
        print(errorMessage)
    
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
        // TODO: get max dist for selected model
        sendAxiCommand("-m manual -M walk_x --dist 16.5")
    }
    
    func walkY() {
        // TODO: get max dist for selected model
        sendAxiCommand("-m manual -M walk_y --dist 16.5")
    }
    
    func preview() {
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
                runAxiCLI(args: [url.path, "-o", outputPath])
            }
        }
    }
    
    func resumeFromLocation() {
        if let original = originalFileURL {
            let url = getCurrentOutputPath(path: original)
            let outputPath = getNewOutputPath(path: original)
            currentFileURL = URL(string: url)
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
    

    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(spacing: 0){
                SidebarView(modelNumber:$modelNumber, modelIndex: $modelIndex, reorderIndex: $reorderIndex, reorderNumber: $reorderNumber, removeHiddenLines: $removeHiddenLines, runWebhook: $runWebhook, webhookURL: $webhookURL, showPopover: $showPopover, goHome: goHome, walkX: walkX, walkY: walkY, enableMotors: enableMotors, disableMotors: disableMotors, penUp: penUp, penDown: penDown, hasFile: currentFileURL != nil, output: outputMessage)
                DragDropContentView(onFileDropped: onFilePathChanged)
            }.frame(maxWidth: .infinity)
         CommandBarView(startPlot: startPlot, resumeFromLocation: resumeFromLocation, resumeFromHome: resumeFromHome, hasFile: currentFileURL != nil, hasOutputFile: outputFileExists())
        }.alert(errorMessage, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
