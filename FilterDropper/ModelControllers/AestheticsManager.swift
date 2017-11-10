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
        
        let minSide = min(imageSize.width, imageSize.height)
        
        switch filter.name {
        case "CIBloom", "CIGloom":
            filter.setValue(minSide * 0.05, forKey: kCIInputRadiusKey)
            filter.setValue(0.7, forKey: kCIInputIntensityKey)
        case "CICircleSplashDistortion":
            filter.setValue(minSide * 0.35, forKey: kCIInputRadiusKey)
        case "CICircularWrap":
            filter.setValue(minSide * 0.15, forKey: kCIInputRadiusKey)
        case "CICrystallize":
            filter.setValue(minSide * 0.025, forKey: kCIInputRadiusKey)
        case "CIDepthOfField":
            let p0 = CIVector(x: imageSize.width * 0.15, y: imageSize.height * 0.3)
            let p1 = CIVector(x: imageSize.width * 0.85, y: imageSize.height * 0.7)
            filter.setValue(p0, forKey: "inputPoint0")
            filter.setValue(p1, forKey: "inputPoint1")
            filter.setValue(minSide * 0.02, forKey: kCIInputRadiusKey)
        case "CIDotScreen":
            filter.setValue(CGFloat.pi / 6.0, forKey: kCIInputAngleKey)
            filter.setValue(minSide * 0.01, forKey: kCIInputWidthKey)
        case "CIEdges":
            filter.setValue(5.0, forKey: kCIInputIntensityKey)
        case "CIEdgeWork":
            filter.setValue(12.0, forKey: kCIInputRadiusKey)
        case "CIEightfoldReflectedTile", "CIFourfoldReflectedTile", "CIFourfoldRotatedTile", "CIFourfoldTranslatedTile", "CIParallelogramTile", "CISixfoldReflectedTile", "CISixfoldRotatedTile", "CITriangleTile", "CITwelvefoldReflectedTile":
            filter.setValue(CGFloat.pi / 6.0, forKey: kCIInputAngleKey)
            filter.setValue(minSide * 0.3, forKey: kCIInputWidthKey)
        case "CIGlideReflectedTile":
            filter.setValue(CGFloat.pi / 6.0, forKey: kCIInputAngleKey)
            filter.setValue(minSide * 0.1, forKey: kCIInputWidthKey)
        case "CIGlassLozenge":
            let r = minSide * 0.2
            let tl = CIVector(x: r, y: r)
            let br = CIVector(x: imageSize.width - r, y: imageSize.height - r)
            filter.setValue(tl, forKey: "inputPoint0")
            filter.setValue(br, forKey: "inputPoint1")
            filter.setValue(r * 0.75, forKey: kCIInputRadiusKey)
        default:
            break
        }
        JSONDecoder
    }
}
