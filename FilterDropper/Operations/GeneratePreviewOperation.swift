//
//  GeneratePreviewOperation.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

class GeneratePreviewOperation: Operation {
    
    let baseImage: UIImage
    let filterName: String
    let cache: ThumbnailCache
    
    init(baseImage: UIImage, filterName: String, cache: ThumbnailCache) {
        self.baseImage = baseImage
        self.filterName = filterName
        self.cache = cache
    }
    
    override func main() {
//        debugPrint("Starting generate thumbnail operation for '\(filterName)'.")
        guard !cache.contains(key: filterName) else {
            // We don't need to do anything.
//            debugPrint("The cache already contained an image for this key. Skipping...")
            return
        }
        if let image = RenderService.shared.renderFilterThumbnail(baseImage: baseImage, filterName: filterName) {
//            debugPrint("Successfully created thumbnail.")
            do {
                try cache.store(thumbnail: image, withKey: filterName)
//                debugPrint("Successfully cached thumbnail.")
            } catch {
                print("ERROR: Unable to save thumbnail to cache: \(error.localizedDescription)")
            }
        }
//        debugPrint("Generate thumbnail operation complete.")
    }
}
