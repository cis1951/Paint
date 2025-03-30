//
//  ContentView.swift
//  Paint
//
//  Created by Anthony Li on 3/29/25.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    @Binding var document: PaintDocument
    @State var toolPicker = PKToolPicker()

    var body: some View {
        CanvasView(drawing: $document.drawing)
            .environment(\.toolPicker, toolPicker)
    }
}

#Preview {
    @Previewable @State var document = PaintDocument()
    ContentView(document: $document)
}
