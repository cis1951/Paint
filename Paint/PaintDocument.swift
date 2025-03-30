import SwiftUI
import PencilKit
import UniformTypeIdentifiers

extension UTType {
    static var drawing: UTType {
        UTType(importedAs: "edu.upenn.seas.cis1951.drawing")
    }
}

struct PaintDocument: FileDocument {
    var drawing: PKDrawing

    init(drawing: PKDrawing = PKDrawing()) {
        self.drawing = drawing
    }

    static var readableContentTypes: [UTType] { [.drawing] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        drawing = try PKDrawing(data: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = drawing.dataRepresentation()
        return .init(regularFileWithContents: data)
    }
}
