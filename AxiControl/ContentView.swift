//
//  ContentView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 6/26/23.
//

import SwiftUI




struct ContentView: View {
    @State var isRunning = false
    @State var output = "Hello AxiControl"
    @AppStorage("modelNumber") private var modelNumber = 1
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
    
    func walkX() {
        sendAxiCommand("-m manual -M walk_x --dist 16.5")
    }
    
    func preview() {
        if let url = currentFileURL {
            sendAxiCommand("-v --report_time", withFile: url.path)
        }
       
    }
    
    func startPlot() {
        if let url = currentFileURL {
            runAxCLI(args: [url.path])
        }
    }
    
    func onModelSelect(_ modelName: String) {
        let num = axiModels.firstIndex(of: modelName)! + 1
        modelNumber = num;
        
        
    }
    
//    let modelName = axiModels[modelNumber - 1]

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(output)
            Menu (axiModels[modelNumber - 1]){
                ForEach(axiModels, id: \.self){ model in
                    Button(model, action: {onModelSelect(model)})
                }
                
            }
            Button("Home", action: goHome)
            Button("Disable Motors", action: disableMotors)
            Button("Walk X", action: walkX)
            Button("Version", action: version)
            Button("Preview", action: preview)
            
            DragDropContentView(onFileDropped: onFilePathChanged)
        }
        .padding()
        
        .toolbar {
            Button(action: startPlot) {
                Label("Start Plot", systemImage: "pencil.line")
            }.help("Start a plot")
        
            Button("Start Plot", action: startPlot)
            
        }.navigationTitle("")
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
