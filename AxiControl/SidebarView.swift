//
//  SidebarView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/4/23.
//

import SwiftUI

let controlWidth = 180.0


let models: [[String: Any]] = [
    ["name": "AxiDraw V2", "value": 1],
    ["name": "AxiDraw V3", "value": 1],
    ["name": "AxiDraw SE/A4", "value": 1],
    ["name": "AxiDraw V3/A3", "value": 2],
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
    
    var goHome:() -> Void
    var walkX:() -> Void
    var walkY:() -> Void
    var enableMotors:() -> Void
    var disableMotors:() -> Void
    var penUp:() -> Void
    var penDown:() -> Void
    
    var hasFile: Bool
    
    var output: String
    var error:String
    
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
                Text("Reorder:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
                Menu (reorderOptions[reorderIndex]["name"] as? String ?? "Select"){
                    ForEach(reorderOptions.indices, id: \.self) { index in
                        Button(action: { onReorderSelect(index) }) {
                            Text(reorderOptions[index]["name"] as? String ?? "")
                        }
                    }
                    
                }.frame(width: controlWidth )
                
            }
            }.padding()
            
            Spacer()
            
            
            ConsoleView(output: output, error: error)
            
        }
        
        .frame(minWidth: 266, maxWidth: 266, maxHeight: .infinity)
        .background(Color.white)
        .overlay(Divider().background(Color(red: 0.88, green: 0.88, blue: 0.88)), alignment: .trailing)
        
    }
}


func nullCommand() {}

struct SidebarView_Previews: PreviewProvider {
    
static var previews: some View {
    SidebarView( modelNumber: .constant(1), modelIndex: .constant(1), reorderIndex: .constant(0), reorderNumber: .constant(1), goHome: nullCommand, walkX: nullCommand, walkY: nullCommand, enableMotors: nullCommand, disableMotors: nullCommand, penUp: nullCommand, penDown: nullCommand, hasFile: true, output: "", error: "")
}
}
