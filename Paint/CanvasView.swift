import PencilKit
import SwiftUI

extension EnvironmentValues {
    @Entry var toolPicker: PKToolPicker? = nil
}

struct CanvasView: View {
    @Binding var drawing: PKDrawing
    @Environment(\.toolPicker) var toolPicker: PKToolPicker?
    @Environment(\.undoManager) var undoManager: UndoManager?
    
    var body: some View {
        Text("Hello, world!")
    }
}

#Preview {
    @Previewable @State var drawing = PKDrawing()
    @Previewable @State var toolPicker = PKToolPicker()
    
    CanvasView(drawing: $drawing)
        .environment(\.toolPicker, toolPicker)
}
