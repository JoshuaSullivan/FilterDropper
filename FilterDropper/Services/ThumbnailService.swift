//
//  ThumbnailService.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit
import CoreImage

final class ThumbnailService {
    
    typealias ThumbnailCompletion = (UIImage?) -> Void
    private static let defaultImage = #imageLiteral(resourceName: "tulip")
    
    // Singleton
    private static let _shared = ThumbnailService()
    class var shared: ThumbnailService {
        return _shared
    }
    
    // Properties
    private var cache = ThumbnailCache()
    private let queue: OperationQueue
    private var queueObservationToken: NSKeyValueObservation
    
    init() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        let keyPath = \OperationQueue.operationCount
        queueObservationToken = queue.observe(keyPath, changeHandler: { (queue, change) in
            debugPrint("Queue operation count: \(queue.operationCount)")
            if queue.operationCount == 0 {
                debugPrint("Thumbnail generation complete.")
            }
        })
        self.queue = queue
    }
    
    deinit {
        queueObservationToken.invalidate()
    }
    
    func generateThumbnailsIfNeeded(for filterNames: [String]) {
        guard let cache = cache else { return }
        debugPrint("Beginning thumbnail generation.")
        let operations: [GeneratePreviewOperation] = filterNames.map({
            let op = GeneratePreviewOperation(baseImage: ThumbnailService.defaultImage, filterName: $0, cache: cache)
            op.queuePriority = .low
            return op
        })
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    func thumbnail(for filterName: String, completion: @escaping ThumbnailCompletion) {
        
        // Check the cache for the image.
        if let image = cache?.retreive(thumbnailWithKey: filterName) {
            completion(image)
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            // Try to render the image.
            guard let image = RenderService.shared.renderFilterThumbnail(baseImage: ThumbnailService.defaultImage, filterName: filterName) else {
                self.fulfill(completion: completion, with: nil)
                return
            }
            
            // Try to cache the image.
            if let cache = self.cache {
                try? cache.store(thumbnail: image, withKey: filterName)
            }
            
            // Return the image.
            self.fulfill(completion: completion, with: image)
        }
        
        
    }
    
    private func fulfill(completion: @escaping ThumbnailCompletion, with image: UIImage?) {
        DispatchQueue.main.async {
            completion(image)
        }
    }
    
}
