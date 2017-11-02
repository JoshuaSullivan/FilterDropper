//
//  ApplyFilterOperation.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/1/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit
import CoreImage

class ApplyFilterOperation: Operation {
    
    typealias Completion = (RenderResult?) -> Void
    
    static var thumbnailHeight: CGFloat = 300.0 * UIScreen.main.scale
    
    let image: UIImage
    let filterName: String
    let completion: Completion
    
    init(image: UIImage, filterName: String, completion: @escaping Completion) {
        self.image = image
        self.filterName = filterName
        self.completion = completion
    }
    
    override func main() {
        guard
            let filter = CIFilter(name: filterName),
            let ci = CIImage(image: image)
        else {
            print("ERROR: Could not create filter.")
            complete(nil)
            return
        }
        if filter.inputKeys.contains(kCIInputCenterKey) {
            let center = CIVector(x: image.size.width / 2.0, y: image.size.height / 2.0)
            filter.setValue(center, forKey: kCIInputCenterKey)
        }
        filter.setValue(ci, forKey: kCIInputImageKey)
        
        // Render the full-res image.
        guard let output = filter.outputImage else {
            print("ERROR: Couldn't get output image from filter.")
            complete(nil)
            return
        }
        guard let rendered = RenderService.shared.render(image: output, bounds: ci.extent) else {
            print("ERROR: Failed to render full-sized image.")
            complete(nil)
            return
        }
        
        guard let fullResURL = save(image: rendered) else {
            print("ERROR: Failed to save full-sized image.")
            complete(nil)
            return
        }
        
        let scale = min(ApplyFilterOperation.thumbnailHeight / image.size.height, 1.0)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = output.transformed(by: transform)
        let scaledBounds = ci.extent * scale
        guard let scaledRender = RenderService.shared.render(image: scaledImage, bounds: scaledBounds) else {
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
        do {
            let docs = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destination = docs
                .appendingPathComponent(savedImageDirectory)
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
                return nil
            }
            try imageData.write(to: destination)
            return destination
        } catch {
            print("ERROR: Unable to save image: \(error.localizedDescription)")
            return nil
        }
    }
}
