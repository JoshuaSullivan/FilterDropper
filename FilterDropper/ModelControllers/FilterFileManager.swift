//
//  FilterFileManager.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/14/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import Foundation

class FilterFileManager {
    
    private static let fm = FileManager.default
    private static let savedImagesDirectoryName = "savedImages"
    
    private static var caches: URL {
        do {
            return try fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            print("Could not find caches directory: \(error.localizedDescription) \nTrying documents...")
        }
        do {
            return try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            print("Could not find document directory: \(error.localizedDescription). Nowhere to save, this is a fatal error.")
            fatalError("Could not find a local storage folder for images.")
        }
    }
    
    static let savedImagesDirectory: URL = {
        let dir = caches.appendingPathComponent(savedImagesDirectoryName)
        let exists = (try? dir.checkResourceIsReachable()) ?? false
        if (!exists) {
            do {
                try fm.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("ERROR: Couldn't create saved images directory. Using caches instead.")
                return caches
            }
        }
        return dir
    }()
    
    static var thumbnailDirectory: URL {
        return caches
    }
    
    static func purgeSavedImages() {
        guard
            let fileURLs = try? fm.contentsOfDirectory(at: savedImagesDirectory, includingPropertiesForKeys: nil, options: [])
        else { return }
        for url in fileURLs {
            do {
                try fm.removeItem(at: url)
            } catch {
                debugPrint("Failed to remove item: \(url)")
            }
        }
    }
    
    static func copyRawImage(from url: URL) -> URL? {
        let localURL = savedImagesDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            guard !(try localURL.checkResourceIsReachable()) else {
                // The image alredy exists locally.
                return localURL
            }
            try fm.copyItem(at: url, to: localURL)
            return localURL
        } catch {
            print("ERROR: Unable to copy raw image to local storage: \(error.localizedDescription)")
            return nil
        }
    }
}
