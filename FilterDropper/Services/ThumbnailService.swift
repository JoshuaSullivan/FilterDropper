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
    
    // Singleton
    private static let _shared = ThumbnailService()
    class var shared: ThumbnailService {
        return _shared
    }
    
    private var cache = ThumbnailCache()
    
    func thumbnail(for filterName: String, completion: ThumbnailCompletion) {
        
        // Check the cache for the image.
        if let image = cache?.retreive(thumbnailWithKey: filterName) {
            completion(image)
            return
        }
        
        
    }
    
}

private class ThumbnailCache {
    
    private let storageURL: URL
    
    init?() {
        if let url = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            storageURL = url
        } else if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            storageURL = url
        } else {
            return nil
        }
    }
    
    func store(thumbnail: UIImage, withKey key: String) throws -> Bool {
        let proposedURL = storageURL.appendingPathComponent(key)
        guard let imageData = UIImageJPEGRepresentation(thumbnail, 0.8) else {
            print("ERROR: Unable to convert image to JPEG format.")
            return false
        }
        try imageData.write(to: proposedURL)
        return true
    }
    
    func retreive(thumbnailWithKey key: String) -> UIImage? {
        let proposedURL = storageURL.appendingPathComponent(key)
        do {
            let data = try Data.init(contentsOf: proposedURL)
            return UIImage(data: data, scale: UIScreen.main.scale)
        } catch {
            print("ERROR: Unable to read image: \(error.localizedDescription)")
            return nil
        }
    }
}
