//
//  DragAndDropView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/1/23.
//

import SwiftUI

struct DragAndDropView: NSViewRepresentable {
    typealias NSViewType = DragAndDropNSView

    var onDrop: ([URL]) -> Void

    func makeNSView(context: Context) -> DragAndDropNSView {
        let view = DragAndDropNSView()
        view.onDrop = onDrop
        return view
    }

    func updateNSView(_ nsView: DragAndDropNSView, context: Context) {}
}

class DragAndDropNSView: NSView {
    var onDrop: ([URL]) -> Void = { _ in }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(draggingInfo: sender) {
            return .copy
        }
        return []
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: .fileURL) as? [String: Any],
            let url = pasteboard["NSURL"] as? URL else {
            return false
        }
        onDrop([url])
        return true
    }

    private func checkExtension(draggingInfo: NSDraggingInfo) -> Bool {
        guard let pasteboard = draggingInfo.draggingPasteboard.propertyList(forType: .fileURL) as? [String: Any],
            let url = pasteboard["NSURL"] as? URL else {
            return false
        }
        return url.pathExtension.lowercased() == "svg"
    }
}

