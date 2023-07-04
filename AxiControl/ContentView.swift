//
//  ContentView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 6/26/23.
//

import SwiftUI


struct ContentView: View {
    @AppStorage("modelNumber") var modelNumber = 1
    @State var isRunning = false
    @State var output = "Hello AxiControl"
    
    @State var currentFileURL: URL?
    
    let axiModels  = [
        "AxiDraw V2, V3, or SE/A4",
        "AxiDraw V3/A3 or SE/A3",
        "AxiDraw V3 XLX",
        "AxiDraw MiniKit",
        "AxiDraw SE/A1",
        "AxiDraw SE/A2",
        "AxiDraw V3/B6",
    ]
    
//    let models = [
//        {name: "AxiDraw V2", value: 1},
//        {name: "AxiDraw V3", value: 1},
//        {name: "AxiDraw SE/A4", value: 1},
//        {name: "Axidraw V3/A3", value: 2}
//    ]
    
    
    let axiURL = URL(fileURLWithPath: "/usr/local/bin/axicli")
    
    func onFilePathChanged(url: URL) {
        currentFileURL = url
    }
    
    func goHome() {
        sendAxiCommand( "-m manual -M walk_home")
    }
    
    func runAxCLI(args: [String]) {
        let outputPipe = Pipe()
        self.isRunning = true
        let task = Process()
        task.executableURL = axiURL
        task.standardOutput = outputPipe
        task.arguments = args + ["--model", String(modelNumber)]
        task.terminationHandler = { _ in self.isRunning = false }
        
        try! task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        output = String(decoding: outputData, as: UTF8.self)
        print(output)
    
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
        
    }
    
    func penDown() {
        
    }
    
    func startPlot() {
        if let url = currentFileURL {
            runAxCLI(args: [url.path])
        }
    }
    
    let controlWidth = 180.0
    
//    let modelName = axiModels[modelNumber - 1]

    var body: some View {
        VStack(alignment: .leading){
            HStack(){
                SidebarView(modelNumber:$modelNumber, goHome: goHome, walkX: walkX, walkY: walkY, enableMotors: enableMotors, disableMotors: disableMotors, penUp: penUp, penDown: penDown  )
                DragDropContentView(onFileDropped: onFilePathChanged)
            }.frame(maxWidth: .infinity)
            
        }

//        VStack(alignment: .trailing) {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text(output)
            
           
           
            
            
//            Button("Version", action: version)
//            Button("Preview", action: preview)
            
            
//        }
        
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
