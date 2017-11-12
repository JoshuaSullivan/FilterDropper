//
//  ThumbnailCacheService.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

/// This class implements a simple cache for the thumbnails generated for each filter.
class ThumbnailCache {
    
    enum CacheError: Error {
        /// The operation to convert UIImage into JPEG data failed.
        case unableToCreateJPEGRepresentation
    }
    
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
    
    /// Save an image using the provided key.
    func store(thumbnail: UIImage, withKey key: String) throws {
        let proposedURL = url(for: key)
        guard let imageData = UIImageJPEGRepresentation(thumbnail, 0.8) else {
            print("ERROR: Unable to convert image to JPEG format.")
            throw CacheError.unableToCreateJPEGRepresentation
        }
        try imageData.write(to: proposedURL)
    }
    
    /// Load an image using the provided key. If no image is found for the key, the operation returns nil.
    func retreive(thumbnailWithKey key: String) -> UIImage? {
        let proposedURL = url(for: key)
        do {
            let data = try Data.init(contentsOf: proposedURL)
            return UIImage(data: data, scale: UIScreen.main.scale)
        } catch {
            print("ERROR: Unable to read image: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Returns whether or not the cache contains an image for the provided key.
    func contains(key: String) -> Bool {
        let proposedURL = url(for: key)
        return (try? proposedURL.checkPromisedItemIsReachable()) ?? false
    }
    
    /// Construct the standard URL for a given storage key.
    private func url(for key: String) -> URL {
        return storageURL.appendingPathComponent(key).appendingPathExtension("jpg")
    }
}

