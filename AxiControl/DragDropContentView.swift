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
                   VStack (spacing: 16){
                       VStack {
                           loadImage(from: url)
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                       }
                       .background(Color.white
                           .shadow( radius: 2, x: 0, y: 1)
                         )
                       
                       Text(url.lastPathComponent)
                   }
                   
               } else {
                   Text("Drop an SVG file here")
                       .padding()
               }
           
       }.frame(maxWidth: .infinity, maxHeight: .infinity)
       .dropDestination(for:URL.self) { items, _ in
           guard let item = items.first else { return false}
           
           fileURL = item
           onFileDropped(fileURL!)
           return true
       }
       .padding()
    }
    
    func loadImage(from url: URL) -> Image {
        guard let imageData = try? Data(contentsOf: url),
              let image = NSImage(data: imageData) else {
            return Image(systemName: "photo") // Placeholder image if loading fails
        }
        return Image(nsImage: image)
    }
}
