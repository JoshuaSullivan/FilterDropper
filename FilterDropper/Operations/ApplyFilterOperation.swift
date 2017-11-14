//
//  ApplyFilterOperation.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/1/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit
import CoreImage

/// Renders the preview and full-res versions of a dropped image.
class ApplyFilterOperation: Operation {
    
    typealias Completion = (RenderResult?) -> Void
    
    static var thumbnailHeight: CGFloat = 300.0 * UIScreen.main.scale
    
    let image: CIImage
    let orientation: UIImageOrientation
    let filterName: String
    let completion: Completion
    let isRaw: Bool
    
    init?(image: UIImage, filterName: String, completion: @escaping Completion) {
        guard let cg = image.cgImage else {
            print("ERROR: UIImage contained no CGImage.")
            return nil
        }
        self.image = CIImage(cgImage: cg)
        self.orientation = image.imageOrientation
        self.filterName = filterName
        self.completion = completion
        self.isRaw = false
    }
    
    init?(rawImage url: URL, imageUTI: String, filterName: String, completion: @escaping Completion) {
        let rawOptions = [ String(kCGImageSourceTypeIdentifierHint) : imageUTI ]
        let rawFilter = CIFilter(imageURL: url, options: rawOptions)
        guard let image = rawFilter?.outputImage else {
            print("ERROR: Could not get output image from the raw filter.")
            return nil
        }
        self.image = image
        self.filterName = filterName
        self.orientation = .up
        self.completion = completion
        self.isRaw = true
    }
    
    override func main() {
        guard
            let filter = CIFilter(name: filterName)
        else {
            print("ERROR: Could not create filter.")
            complete(nil)
            return
        }
        
        let oriented = correctOrientation(of: image, for: self.orientation)
        filter.setValue(oriented, forKey: kCIInputImageKey)
        
        guard let output = AestheticsManager.applyAesthetics(to: filter, withImageSize: image.extent.size) else {
            print("ERROR: Couldn't get output image from filter.")
            complete(nil)
            return
        }
    
        // Render the full-res image.
        guard let rendered = RenderService.shared.render(image: output, bounds: image.extent, isRaw: isRaw) else {
            print("ERROR: Failed to render full-sized image.")
            complete(nil)
            return
        }
        
        guard let fullResURL = save(image: rendered) else {
            print("ERROR: Failed to save full-sized image.")
            complete(nil)
            return
        }
        
        let scale = min(ApplyFilterOperation.thumbnailHeight / image.extent.height, 1.0)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = output.transformed(by: transform)
        let scaledBounds = image.extent * scale
        guard let scaledRender = RenderService.shared.render(image: scaledImage, bounds: scaledBounds, isRaw: isRaw) else {
            print("ERROR: Failed to render preview image.")
            complete(nil)
            return
        }
        
        guard let previewURL = save(image: scaledRender) else {
            print("ERROR: Failed to save preview image.")
            complete(nil)
            return
        }
        
        complete(RenderResult(previewURL: previewURL, fullResolutionURL: fullResURL))
    }
    
    private func complete(_ result: RenderResult?) {
        DispatchQueue.main.async {
            self.completion(result)
        }
    }
    
    private func save(image: UIImage) -> URL? {
        let destination = FilterFileManager.savedImagesDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            return nil
        }
        do {
            try imageData.write(to: destination)
            return destination
        } catch {
            print("ERROR: Unable to save image: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func correctOrientation(of image: CIImage, for orientation: UIImageOrientation) -> CIImage {
        let cgOrientation = orientation.cgImageOrientation
        return image.oriented(cgOrientation)
    }
}
