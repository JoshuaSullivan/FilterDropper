//
//  RenderService.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit
import CoreImage
import Metal
import OpenGLES

/// A simple CoreImage rendering stack.
final class RenderService {
    
    typealias Completion = (UIImage?) -> Void
    
    // Singleton
    private static let _shared = RenderService()
    class var shared: RenderService {
        return _shared
    }
    
    // Properties
    private let context: CIContext
    
    init() {
        if UIDevice.current.isMetalCapable, let device = MTLCreateSystemDefaultDevice() {
            debugPrint("Using Metal rendering.")
            context = CIContext(mtlDevice: device)
        } else if let eagl = EAGLContext(api: .openGLES2) {
            debugPrint("Using OpenGL rendering.")
            context = CIContext(eaglContext: eagl)
        } else {
            print("WARNING: CPU Rendering Context is being used. It is going to be slow AF.")
            context = CIContext()
        }
    }
    
    /// Render a thumbnail using the provided image and filter name.
    func renderFilterThumbnail(baseImage: UIImage, filterName: String) -> UIImage? {
        guard
            let filter = CIFilter(name: filterName),
            let ci = CIImage(image: baseImage)
            else {
                print("ERROR: Could not set up filter.")
                return nil
        }
        let imageSize = baseImage.size
        filter.setValue(ci, forKey: kCIInputImageKey)
        guard let output = AestheticsManager.applyAesthetics(to: filter, withImageSize: imageSize) else {
            print("ERROR: Unable to read filter output.")
            return nil
        }
        let imageBounds = CGRect(x: 0.0, y: 0.0, width: imageSize.width, height: imageSize.height)
        guard let renderedImage = context.createCGImage(output, from: imageBounds) else {
            print("ERROR: Unable to render image.")
            return nil
        }
        let finalImage = UIImage(cgImage: renderedImage, scale: baseImage.scale, orientation: baseImage.imageOrientation)
        return finalImage
    }
    
    /// Render a full-resolution image using the provided CIImage.
    func render(image: CIImage, bounds: CGRect? = nil) -> UIImage? {
        let imageBounds = bounds ?? image.extent
        var finalImage: UIImage? = nil
        if let cg = self.context.createCGImage(image, from: imageBounds) {
            finalImage = UIImage(cgImage: cg)
        } else {
            print("ERROR: Unable to render image.")
        }
        return finalImage
    }
}

