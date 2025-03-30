//
//  PaintApp.swift
//  Paint
//
//  Created by Anthony Li on 3/29/25.
//

import SwiftUI

@main
struct PaintApp: App {
    var body: some Scene {
        if #available(iOS 18.0, *) {
            DocumentGroupLaunchScene {
                NewDocumentButton("New Drawing")
            } background: {
                LinearGradient(colors: [
                    .pink,
                    .orange
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        
        DocumentGroup(newDocument: PaintDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
