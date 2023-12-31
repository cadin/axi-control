//
//  SidebarView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/4/23.
//

import SwiftUI
import Combine

let controlWidth = 180.0


let models: [[String: Any]] = [
    ["name": "AxiDraw V2", "value": 1],
    ["name": "AxiDraw V3", "value": 1],
    ["name": "AxiDraw SE/A4", "value": 1],
    ["name": "AxiDraw V3/A3", "value": 2],
    ["name": "AxiDraw SE/A3", "value": 2],
    ["name": "AxiDraw V3 XLX", "value": 3],
    ["name": "AxiDraw MiniKit", "value": 4],
    ["name": "AxiDraw SE/A1", "value": 5],
    ["name": "AxiDraw SE/A2", "value": 6],
    ["name": "AxiDraw V3/B6", "value": 7],
]

let reorderOptions: [[String:Any]] = [
    ["name" : "Least", "value": 0],
    ["name" : "Basic", "value": 1],
    ["name": "Full", "value": 2],
    ["name": "None", "value": 4]
]

struct SidebarView: View {
    @Binding var modelNumber: Int
    @Binding var modelIndex: Int
    
    @Binding var reorderIndex: Int
    @Binding var reorderNumber: Int
    
    @Binding var removeHiddenLines: Bool
    @Binding var runWebhook: Bool
    @Binding var webhookURL: String
    
    @Binding var showPopover:Bool
    @Binding var speed: Double
    
    @Binding var singleLayer: Bool
    @Binding var layerNum: String
    
    var goHome:() -> Void
    var walkX:() -> Void
    var walkY:() -> Void
    var enableMotors:() -> Void
    var disableMotors:() -> Void
    var penUp:() -> Void
    var penDown:() -> Void
    var onPreviewInvalidated:() -> Void
    
    var hasFile: Bool
    
    var output: String
    
    @State var textFieldDisabled = true
    
    func onModelSelect(_ index: Int) {
        let num = models[index]["value"] as! Int
        modelNumber = num;
        modelIndex = index;
    }
    
    func onReorderSelect(_ index: Int) {
        let num = reorderOptions[index]["value"] as! Int
        reorderNumber = num
        reorderIndex = index
    }
    
    private let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    private let validCharacterSet = CharacterSet.decimalDigits
    
    var body: some View {
        
        
        VStack() {
            VStack(alignment: .trailing) {
            
                HStack {
                    Text("Model:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
                    Menu (models[modelIndex]["name"] as? String ?? "Select a model"){
                        ForEach(models.indices, id: \.self) { index in
                            Button(action: { onModelSelect(index) }) {
                                Text(models[index]["name"] as? String ?? "")
                            }
                        }
                        
                    }.frame(width: controlWidth )
                    .onChange(of: modelIndex) { _ in
                        onPreviewInvalidated()
                    }
                }
                
                HStack {
                    Text("Pen:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
                    HStack {
                        
                        Button(action: penUp) {
                            Text("Up").frame(maxWidth: .infinity)
                        }
                        Button(action: penDown) {
                            Text("Down").frame(maxWidth: .infinity)
                        }
                    }.frame(width: controlWidth)
                }
                
                HStack {
                    Text("Motors:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
                    HStack {
                        
                        Button(action: enableMotors) {
                            Text("Enable").frame(maxWidth: .infinity)
                        }
                        Button(action: disableMotors) {
                            Text("Disable").frame(maxWidth: .infinity)
                        }
                    }.frame(width: controlWidth)
                }
                
                HStack {
                    Text("Walk:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
                    HStack {
                        Button(action: goHome) {
                            Text("Home").frame(maxWidth: .infinity)
                        }
                        Button(action: walkX) {
                            Text("Max X").frame(maxWidth: .infinity)
                        }
                        Button(action: walkY) {
                            Text("Max Y").frame(maxWidth: .infinity)
                        }
                    }.frame(width: controlWidth)
                    
                }
                Spacer().frame(height: 32)
                
                HStack {
                    Text("Speed:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
                    Slider(
                        value: $speed,
                        in: 1...110,
                        label: {
                            Text("\(Int(speed))")
                                .frame(width: 24, alignment: .leading)
                        }
                    )
                    .frame(width: controlWidth )
                        .onChange(of: speed) { _ in
                            onPreviewInvalidated()
                        }
                }
                
                HStack {
                    Text("Reorder:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
                    Menu (reorderOptions[reorderIndex]["name"] as? String ?? "Select"){
                        ForEach(reorderOptions.indices, id: \.self) { index in
                            Button(action: { onReorderSelect(index) }) {
                                Text(reorderOptions[index]["name"] as? String ?? "")
                            }
                        }
                        
                    }.frame(width: controlWidth )
                        .onChange(of: reorderIndex) { _ in
                            onPreviewInvalidated()
                        }
                    
                }
                
                
                HStack {
                    
                    Toggle(isOn: $removeHiddenLines) {
                        Text("Remove hidden lines")
                    }
                    .onChange(of: removeHiddenLines) { _ in
                        onPreviewInvalidated()
                    }
                    Spacer()
                }.frame(width: controlWidth)
                
                HStack {
                    Toggle(isOn: $singleLayer) {
                        Text("Single layer").frame(minWidth: 80, alignment: .leading)
                    }
                    .onChange(of: singleLayer) { _ in
                        onPreviewInvalidated()
                    }
                    Spacer()
                    TextField("", text: $layerNum)
                        .onChange(of: layerNum) { _ in
                            onPreviewInvalidated()
                        }
                        .onReceive(Just(layerNum)) { newValue in
                            let filteredValue = newValue.filter { validCharacterSet.contains($0.unicodeScalars.first!) }
                            if numberFormatter.number(from: filteredValue) != nil {
                                layerNum = filteredValue
                            } else {
                                layerNum = ""
                            }
                        }
                        .frame(maxWidth: 64)
                        .disabled(!singleLayer)
                    
                }.frame(width: controlWidth)
                
                HStack {
                    Toggle(isOn: $runWebhook) {
                        Text("Run webhook")
                    }.disabled(webhookURL.count < 1)
                    Spacer()
                    
                    Button("􀣌") {
                        self.showPopover = true
                                }.popover(
                                    isPresented: $showPopover,
                                    arrowEdge: .bottom
                                ) { WebhookPopoverView(webhookURL: $webhookURL) }
                }.textFieldStyle(.roundedBorder).frame(width: controlWidth)
                
            }.padding()
            
            
            
            Spacer()
            
            
            ConsoleView(output: output)
            
        }
        
        .frame(minWidth: 274, maxWidth: 274, maxHeight: .infinity)
        .background(Color.white)
        .overlay(Divider().background(Color(red: 0.88, green: 0.88, blue: 0.88)), alignment: .trailing)
        
    }
}


func nullCommand() {}

//struct SidebarView_Previews: PreviewProvider {
//
//static var previews: some View {
//    SidebarView( modelNumber: .constant(1), modelIndex: .constant(1), reorderIndex: .constant(0), reorderNumber: .constant(1), removeHiddenLines: .constant(true), webhookURL: .constant(""), goHome: nullCommand, walkX: nullCommand, walkY: nullCommand, enableMotors: nullCommand, disableMotors: nullCommand, penUp: nullCommand, penDown: nullCommand, hasFile: true, output: "", error: "")
//}
//}
