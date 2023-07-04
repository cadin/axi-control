//
//  SidebarView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/4/23.
//

import SwiftUI

let controlWidth = 180.0


let axiModels  = [
    "AxiDraw V2, V3, or SE/A4",
    "AxiDraw V3/A3 or SE/A3",
    "AxiDraw V3 XLX",
    "AxiDraw MiniKit",
    "AxiDraw SE/A1",
    "AxiDraw SE/A2",
    "AxiDraw V3/B6",
]

struct SidebarView: View {
    @Binding var modelNumber: Int
    
    var goHome:() -> Void
    var walkX:() -> Void
    var walkY:() -> Void
    var enableMotors:() -> Void
    var disableMotors:() -> Void
    var penUp:() -> Void
    var penDown:() -> Void
    
    func onModelSelect(_ modelName: String) {
        let num = axiModels.firstIndex(of: modelName)! + 1
        modelNumber = num;
    }
    
    var body: some View {
        
        
        
        VStack(alignment: .trailing) {
            
            HStack {
                Text("Model:")
                Menu (axiModels[modelNumber - 1]){
                    ForEach(axiModels, id: \.self){ model in
                        Button(model, action: {onModelSelect(model)})
                    }
                    
                }.frame(width: controlWidth )
            }
            
            HStack {
                Text("Walk:")
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
            
            HStack {
                Text("Motors:")
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
                Text("Pen:")
                HStack {
                    
                    Button(action: penUp) {
                        Text("Up").frame(maxWidth: .infinity)
                    }
                    Button(action: penDown) {
                        Text("Down").frame(maxWidth: .infinity)
                    }
                }.frame(width: controlWidth)
            }
            
            Spacer()
            
        }
        .padding()
        .frame(minWidth: 268, maxHeight: .infinity)
        .background(Color.white)
        
    }
}


func nullCommand() {}

struct SidebarView_Previews: PreviewProvider {
    
static var previews: some View {
    SidebarView( modelNumber: .constant(1), goHome: nullCommand, walkX: nullCommand, walkY: nullCommand, enableMotors: nullCommand, disableMotors: nullCommand, penUp: nullCommand, penDown: nullCommand)
}
}
