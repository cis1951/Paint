import PencilKit
import SwiftUI

extension EnvironmentValues {
    @Entry var toolPicker: PKToolPicker? = nil
}

struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Environment(\.toolPicker) var toolPicker
    @Environment(\.undoManager) var undoManager
    
    func makeUIView(context: Context) -> PKCanvasView {
        let view = PKCanvasView()
        view.drawingPolicy = .anyInput
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        
        updateUIView(view, context: context)
        
        view.becomeFirstResponder()
        return view
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
        
        if let toolPicker {
            toolPicker.setVisible(true, forFirstResponder: uiView)
            toolPicker.addObserver(uiView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        
        init(parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if parent.drawing != canvasView.drawing {
                Task { @MainActor in
                    parent.undoManager?.disableUndoRegistration()
                    parent.drawing = canvasView.drawing
                    parent.undoManager?.enableUndoRegistration()
                }
            }
        }
    }
}
