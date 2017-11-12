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
    static func applyAesthetics(to filter: CIFilter, withImageSize imageSize: CGSize) -> CIImage? {
        let keys = filter.inputKeys
        
        let center = CIVector(x: imageSize.width / 2.0, y: imageSize.height / 2.0)
        if keys.contains(kCIInputCenterKey) {
            filter.setValue(center, forKey: kCIInputCenterKey)
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
        case "CIDotScreen", "CIHatchedScreen", "CILineScreen":
            filter.setValue(CGFloat.pi / 6.0, forKey: kCIInputAngleKey)
            filter.setValue(minSide * 0.01, forKey: kCIInputWidthKey)
        case "CIDroste":
            let p0 = CIVector(x: imageSize.width * 0.6, y: imageSize.height * 0.6)
            let p1 = CIVector(x: imageSize.width * 0.4, y: imageSize.height * 0.4)
            filter.setValue(p0, forKey: "inputInsetPoint0")
            filter.setValue(p1, forKey: "inputInsetPoint1")
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
        case "CIHexagonalPixellate", "CIPixellate":
            filter.setValue(minSide * 0.02, forKey: kCIInputScaleKey)
        case "CIHoleDistortion":
            filter.setValue(minSide * 0.25, forKey: kCIInputRadiusKey)
        case "CIKaleidoscope":
            filter.setValue(CGFloat.pi / 6.0, forKey: kCIInputAngleKey)
        case "CILightTunnel":
            filter.setValue(minSide * 0.3, forKey: kCIInputRadiusKey)
            filter.setValue(CGFloat.pi, forKey: "inputRotation")
        case "CILineOverlay":
            filter.setValue(0.15, forKey: "inputThreshold")
            filter.setValue(1.5, forKey: "inputEdgeIntensity")
            guard
                let compositingFilter = CIFilter(name: "CISourceAtopCompositing"),
                let srcImage = filter.value(forKey: kCIInputImageKey) as? CIImage,
                let filterImage = filter.outputImage
            else {
                let blended = applyBackground(color: .white, to: filter)
                return blended.outputImage
            }
            compositingFilter.setValue(filterImage, forKey: kCIInputImageKey)
            compositingFilter.setValue(srcImage, forKey: kCIInputBackgroundImageKey)
            return compositingFilter.outputImage
        case "CIMotionBlur":
            filter.setValue(minSide * 0.05, forKey: kCIInputRadiusKey)
        case "CIOpTile":
            filter.setValue(minSide * 0.1, forKey: kCIInputWidthKey)
            filter.setValue(1.8, forKey: kCIInputScaleKey)
        case "CIPinchDistortion":
            filter.setValue(minSide * 0.35, forKey: kCIInputRadiusKey)
            filter.setValue(0.7, forKey: kCIInputScaleKey)
        case "CIPointillize":
            filter.setValue(minSide * 0.02, forKey: kCIInputRadiusKey)
        case "CISpotLight":
            let pos = CIVector(x: imageSize.width / 2.0, y: imageSize.height * 1.5, z: minSide * 0.3)
            let pointAt = CIVector(x: imageSize.width * 0.5, y: imageSize.height * 0.65, z: 0.0)
            filter.setValue(pos, forKey: "inputLightPosition")
            filter.setValue(pointAt, forKey: "inputLightPointsAt")
            filter.setValue(0.0125, forKey: "inputConcentration")
        case "CITorusLensDistortion":
            filter.setValue(minSide * 0.45, forKey: kCIInputRadiusKey)
            filter.setValue(minSide * 0.3, forKey: kCIInputWidthKey)
        case "CITriangleKaleidoscope":
            filter.setValue(center, forKey: "inputPoint")
            filter.setValue(minSide * 0.3, forKey: "inputSize")
        case "CITwirlDistortion":
            filter.setValue(minSide * 0.4, forKey: kCIInputRadiusKey)
        case "CIUnsharpMask":
            filter.setValue(0.7, forKey: "inputIntensity")
            filter.setValue(4.0, forKey: kCIInputRadiusKey)
        case "CIVibrance":
            filter.setValue(0.4, forKey: "inputAmount")
        case "CIVignetteEffect":
            filter.setValue(minSide * 0.45, forKey: kCIInputRadiusKey)
        default:
            break
        }
        let blended = applyBackground(color: .black, to: filter)
        return blended.outputImage
    }
    
    static func applyBackground(color: CIColor, to filter: CIFilter) -> CIFilter {
        guard let image = filter.outputImage else {
            print("Could not read output image from filter.")
            return filter
        }
        guard
            let colorFilter = CIFilter(name: "CIConstantColorGenerator"),
            let blendFilter = CIFilter(name: "CISourceOverCompositing")
        else {
            print("Could not create blend or compositing filter.")
            return filter
        }
        colorFilter.setValue(color, forKey: kCIInputColorKey)
        blendFilter.setValue(image, forKey: kCIInputImageKey)
        blendFilter.setValue(colorFilter.outputImage!, forKey: kCIInputBackgroundImageKey)
        return blendFilter
    }
}
