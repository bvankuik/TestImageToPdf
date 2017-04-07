# TestImageToPdf

An example in Swift where you shoot a picture, and then convert the resulting
picture to a PDF that's previewed with a WKWebView. This app has two methods
to create the PDF.

## Method 1: createPdfByRenderingContainerView()

This is a very easy way to create a PDF: you simply create a PDF context with
the appropriate size (A4 in this instance), then ask the appropriate view to
render in that context.

One advantage is that you can simply use AutoLayout to construct a PDF-sized
view with subviews, then render it to a file without additional steps.

One big disadvantage of this method is that the resulting PDF size is very
big; the image is not compressed.

## Method 2: createPdfAndManuallyLayoutImage()

The hard and manual way to create a PDF: create an empty PDF context, then
use the Core Graphics routines to put the image in there (appropriately
positioned and scaled).

The advantage is of course that you can set the exact compression size. And the
major disadvantage is that the code looks nothing like the usual UIKit stuff. 
