//
//  AestheticsManager.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/8/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import CoreImage

/// This class is a 1-stop shop for applying aesthetic effects to images. Currently, I'm only setting the effect center.
/// Radius might be another one to work with, but different filters have wildly different uses for the radius value, so it's hard to generalize.
final class AestheticsManager {
    static func applyAesthetics(to filter: CIFilter, withImageSize imageSize: CGSize) {
        let keys = filter.inputKeys
        
        if keys.contains(kCIInputCenterKey) {
            filter.setValue(CIVector(x: imageSize.width / 2.0, y: imageSize.height / 2.0), forKey: kCIInputCenterKey)
        }
    }
}
