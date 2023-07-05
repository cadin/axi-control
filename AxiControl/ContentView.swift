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
    
    @State var isRunning = false
    @State var outputMessage = ""
    @State var errorMessage = ""
    
    @State var currentFileURL: URL?
    
    let axiURL = URL(fileURLWithPath: "/usr/local/bin/axicli")
    
    func onFilePathChanged(url: URL) {
        currentFileURL = url
    }
    
    func goHome() {
        sendAxiCommand( "-m manual -M walk_home")
    }
    
    func runAxCLI(args: [String]) {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        self.isRunning = true
        let task = Process()
        task.executableURL = axiURL
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.arguments = args + ["--model", String(modelNumber), "--reordering", String(reorderNumber)]
        task.terminationHandler = { _ in self.isRunning = false }
        
        try! task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        outputMessage = String(decoding: outputData, as: UTF8.self)
        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        errorMessage = String(decoding: errorData, as: UTF8.self)
        print(outputMessage)
        print(errorMessage)
    
    }
    
    func sendAxiCommand(_ cmd: String, withFile path: String) {
        let args = cmd.components(separatedBy: " ")
        runAxCLI(args: [path] + args)
    }
    
    func sendAxiCommand(_ cmd: String) {
        print("command: " + cmd)
        let args = cmd.components(separatedBy: " ")
        runAxCLI(args: args)
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
    
    func startPlot() {
        if let url = currentFileURL {
            runAxCLI(args: [url.path])
        }
    }
    
    func resumeFromLocation() {
        // TODO res_plot
    }
    
    func resumeFromHome() {
        // TODO res_home
    }
    

    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(spacing: 0){
                SidebarView(modelNumber:$modelNumber, modelIndex: $modelIndex, reorderIndex: $reorderIndex, reorderNumber: $reorderNumber, goHome: goHome, walkX: walkX, walkY: walkY, enableMotors: enableMotors, disableMotors: disableMotors, penUp: penUp, penDown: penDown, hasFile: currentFileURL != nil, output: outputMessage, error: errorMessage  )
                DragDropContentView(onFileDropped: onFilePathChanged)
            }.frame(maxWidth: .infinity)
         CommandBarView(startPlot: startPlot, resumeFromLocation: resumeFromLocation, resumeFromHome: resumeFromHome, hasFile: currentFileURL != nil)
        }
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
