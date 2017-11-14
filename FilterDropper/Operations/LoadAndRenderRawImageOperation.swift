//
//  LoadAndRenderRawImageOperation.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/13/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

class LoadAndRenderRawImageOperation: Operation {
    
    typealias Completion = (UIImage?) -> Void
    
    let url: URL
    let uti: String
    let completion: Completion
    
    init(url: URL, uti: String, completion: @escaping Completion) {
        self.url = url
        self.uti = uti
        self.completion = completion
        super.init()
    }
    
    override func main() {
        let options = [kCGImageSourceTypeIdentifierHint as String : uti]
        guard
            let filter = CIFilter(imageURL: url, options: options),
            let image = filter.outputImage
        else {
            print("ERROR: Unable to create raw image filter or get its output.")
            complete(with: nil)
            return
        }
        guard let rendered = RenderService.shared.render(image: image, bounds: nil, isRaw: true) else {
            print("Failed to render image.")
            complete(with: nil)
            return
        }
        complete(with: rendered)
    }
    
    private func complete(with image: UIImage?) {
        DispatchQueue.main.async {
            self.completion(image)
        }
    }
    
}
