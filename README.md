# Paint

This repo contains the code for **Lecture 10: UIKit**, updated for Spring 2025.

In this lecture, we'll be using PencilKit to build an app that lets you create and save drawings to your device. Along the way, you'll learn how to use UIViewRepresentable to use UIKit views with minimal fuss in SwiftUI.

> As always, the finished code is available on the [`solution` branch](https://github.com/cis1951/Paint/tree/solution).

## Step 1: Set up the canvas view

If we launch our app right now, we'll see that while it builds and runs, all we see when we get to a drawing is the simple "Hello, world!" message located in our `CanvasView`. We ideally want to replace this with an actual drawing canvas.

The good news is that iOS/iPadOS has a built-in drawing canvas view that makes this way easier than CIS 1200's Paint assignment: [PKCanvasView](https://developer.apple.com/documentation/pencilkit/pkcanvasview). The bad news is this view is stuck in UIKit-land — there's no SwiftUI equivalent, so it'll be up to us to make one.

To add a UIKit view to a SwiftUI app, we'll need to define a `UIViewRepresentable` view to stand in for the UIKit view. Go to `CanvasView` and replace the struct with skeleton code for a `UIViewRepresentable`:

```swift
struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Environment(\.undoManager) var undoManager
    
    func makeUIView(context: Context) -> PKCanvasView {
        
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
}
```

When we declare a `CanvasView` in our app, SwiftUI will call `makeUIView` to let us create and return a UIKit view — in this case, `PKCanvasView`. For now, we'll just instantiate one and apply some basic customizations to it:

```swift
func makeUIView(context: Context) -> PKCanvasView {
    let view = PKCanvasView()
    view.drawingPolicy = .anyInput
    view.backgroundColor = .clear
    return view
}
```

Try running the app. You should be able to draw stuff on the canvas! However, there's one small issue...

## Step 2: Passing drawings to the canvas view

If you play around with the app long enough to close and reopen a file, you may have noticed one thing: nothing's saving. In fact, the drawings you make don't even appear to be connected to the files at all. Let's set out to fix that.

You may have noticed that `drawing` binding throughout our `CanvasView` and `ContentView`. It's ultimately provided by our `PaintDocument` struct, meaning that our actual source of truth should come from there in some way.

When we're wiring up a binding to a UIKit view, we'll need to do it both ways. Let's start by passing our drawing from SwiftUI-land to our UIKit view. Whenever our drawing updates, SwiftUI will call the `updateUIView` method, making that a good place to pass our drawing to the PKCanvasView:

```swift
func updateUIView(_ uiView: PKCanvasView, context: Context) {
    if uiView.drawing != drawing {
        uiView.drawing = drawing
    }
}
```

Why are we checking if the `uiView` already has the same drawing as our binding? It's because the drawing changing outside isn't the *only* reason `updateUIView` might get called — some environment value (like whether the app is using dark mode) may have been changed, or maybe the canvas view itself changed the drawing after an edit. Checking equality like this helps reduce unnecessary writes and prevents any infinite loops later down the road.

But this is only one part of the story. We now need to wire it up the other way around:

## Step 3: Getting drawings *from* the canvas view

Our canvas view has the ability to load drawings from a file, but what about writing it back? That's what we'll now tackle.

To save drawings, we need some way to:

1. Get notified whenever the drawing changes
2. Retrieve the drawing from the canvas
3. Save it back to the `drawing` binding

Let's tackle each step in order.

For step 1, PKCanvasView takes an optional *delegate* with a method named `canvasViewDrawingDidChange` that will be called whenever the drawing changes. This seems like it would be an ideal solution, but who will be the delegate?

In SwiftUI, this role is performed by the *coordinator* — an optional object that takes care of any long-running interactions between SwiftUI and UIKit. Let's define a coordinator inside the `CanvasView` class, like so:

```swift
class Coordinator: NSObject, PKCanvasViewDelegate {
    var parent: CanvasView
    
    init(parent: CanvasView) {
        self.parent = parent
    }
}
```

This `Coordinator` takes in its parent `CanvasView`, which then contains the binding to the drawing. With this, we can go ahead and implement `canvasViewDrawingDidChange` to update this binding whenever the drawing changes:

```swift
func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    if parent.drawing != canvasView.drawing {
        Task { @MainActor in
            parent.undoManager?.disableUndoRegistration()
            parent.drawing = canvasView.drawing
            parent.undoManager?.enableUndoRegistration()
        }
    }
}
```

(The complicated logic is there to ensure that this method doesn't try to update the drawing while SwiftUI is running its internal logic. Specifically, it defers the actual saving until there is free time on the main thread, and it disables undo registration to prevent SwiftUI from logging edits twice.)

Once we've defined our coordinator, we need to explicitly set it up for each `CanvasView` that SwiftUI creates. Go ahead and define a new method under `CanvasView` called `makeCoordinator`:

```swift
func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
}
```

This coordinator will now be passed into `makeUIView` and `updateUIView` as `context.coordinator`. This is enough for what we'd like to do — setting up the coordinator as the canvas view's delegate. Update `makeUIView` with one more line that does this:

```swift
view.delegate = context.coordinator
```

And we're done with wiring up the `drawing` binding! Try running the app now — you'll notice that you can save and reload drawings just like you'd expect from a typical file.

## Bonus Step: Adding a Tool Picker

If you've made it this far, great job! Now you may have noticed some code around related to a Tool Picker in the `ContentView` and original `CanvasView`.

If you find yourself with extra time, to try to add a [`PKToolPicker`](https://developer.apple.com/documentation/pencilkit/pktoolpicker) to the app so you can control what pen you are drawing with (color, size, etc.).

It should be pretty straightforward to add and doesn't require too much more code (you should only need to modify the `CanvasView` struct). If you want to see the completed version, check out the [`solution` branch](https://github.com/cis1951/Paint/tree/solution)!
