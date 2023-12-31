//
//  ConsoleView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/4/23.
//

import SwiftUI

struct ConsoleView: View {
    var output: String
    
    let monoFont = Font
        .system(size: 10)
        .monospaced()
    
    var body: some View {
        if(output.count > 0){
            VStack(){
                if(output.count > 0){
                    Text(output)
                        .font(monoFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }

            }
            
            .padding()
            .frame(maxWidth: .infinity)
            .overlay(Divider().background(Color(red: 95, green: 0.95, blue: 0.95)), alignment: .top)
        }
    }
}

struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        ConsoleView(output: "output")
    }
}
