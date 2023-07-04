//
//  DragAndDropView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/1/23.
//

import SwiftUI

struct DragDropContentView: View {
    @State private var fileURL: URL?
    
    var onFileDropped: (URL) -> Void

    var body: some View {
       VStack {
           if let url = fileURL {
                           loadImage(from: url)
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                       } else {
                           Text("Drop an image file here")
                               .padding()
                       }
       }.frame(maxWidth: .infinity)
       .dropDestination(for:URL.self) { items, _ in
           guard let item = items.first else { return false}
           
           fileURL = item
           onFileDropped(fileURL!)
           return true
       }
    }
    
    func loadImage(from url: URL) -> Image {
        guard let imageData = try? Data(contentsOf: url),
              let image = NSImage(data: imageData) else {
            return Image(systemName: "photo") // Placeholder image if loading fails
        }
        return Image(nsImage: image)
    }
}
