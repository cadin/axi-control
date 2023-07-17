//
//  WebhookPopoverView.swift
//  AxiControl
//
//  Created by Cadin Batrack on 7/14/23.
//

import SwiftUI

struct WebhookPopoverView: View {
    @Binding var webhookURL: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text("Webhook URL:").font(.subheadline).foregroundColor(Color.black.opacity(0.5))
            TextField("Enter URL", text: $webhookURL, onCommit: {
                DispatchQueue.main.async {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                }
            }).frame(width: 300)
        }.padding([.horizontal, .bottom]).padding([.top], 8)
    }
}

struct WebhookPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        WebhookPopoverView(webhookURL: .constant(""))
    }
}
