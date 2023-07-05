//
//  CommandBarView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/4/23.
//
import SwiftUI



struct CommandBarView: View {
    var startPlot:() -> Void
    var resumeFromLocation:() -> Void
    var resumeFromHome:() -> Void
    
    var hasFile: Bool
//    var hasOutputFile: Bool
    
    
    var body: some View {
        
            HStack {
                HStack {
                    Button(action: resumeFromLocation) {
                        Text("Resume")
                    }.disabled(!hasFile)
                    Button(action: resumeFromHome) {
                        Text("Resume from home")
                    }.disabled(!hasFile)
                }
                
                Spacer()
                
                Button(action: startPlot) {
                    Text("Start plot")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasFile)

            }
            .padding()
            .background(.white)
            .overlay(Divider().background(Color(red: 0.88, green: 0.88, blue: 0.88)), alignment: .top)
            
    }
}




struct CommandBarView_Previews: PreviewProvider {
    
static var previews: some View {
    CommandBarView(startPlot: nullCommand, resumeFromLocation: nullCommand, resumeFromHome: nullCommand, hasFile: true)
}
}
