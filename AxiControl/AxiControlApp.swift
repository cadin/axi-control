//
//  AxiControlApp.swift
//  AxiControl
//
//  Created by Cadin Batrack on 6/26/23.
//

import SwiftUI

@main
struct AxiControlApp: App {
    private let axiCLIURL = ContentView.findAxiCLI()

    var body: some Scene {
        WindowGroup {
            ContentView(axiCLIURL: axiCLIURL)
        }
    }
}
