# Filter Dropper

This is a simple demonstration app for iOS 11's new Drag & Drop functionality. To use it, simply drag images from another app (Photos being the most obvious choice) and drop them onto the filter tiles. The images will automatically have the selected filter applied and appear in the top results area. From there, it can be dragged onto another filter, or to any other app which accepts image drops.

### Drag & Drop

For those interested in how the drag and drop work, check out the `FilterCollectionDropManager` and `ResultCollectionDragManager` classes, which act as the drop and drag delegates for their respective views.

### Operation-based Rendering

Two `NSOperation` subclasses manage the bulk of the rendering: `GeneratePreviewOperation` and `ApplyFilterOperation`. I chose to use operation queues because I have no way of knowing how many images will be dropped on the app. It could be 1, it could be 100… I wanted to make sure I'm not blocking the main thread as I perform potentially lengthy rendering operations.

### CoreImage

If you're interested in how I'm rendering the images, check out the `RenderService` class, which is called by both of the rendering operations. It sets up a simple CoreImage rendering pipeline based on Metal or OpenGL, depending on the host device's capability. The first generation of 64-bit processors technically can use Metal, but they're abysmally slow at it, with OpenGL providing an order of magnitude better performance.
