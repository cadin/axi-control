//
//  SVGImageView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/1/23.
//
import SwiftUI
import WebKit

struct SVGImageView: NSViewRepresentable {
    let svgURL: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadFileURL(svgURL, allowingReadAccessTo: svgURL.deletingLastPathComponent())
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
