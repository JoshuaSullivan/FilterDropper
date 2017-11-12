//
//  UIImage+Orientation.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/11/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

extension UIImageOrientation {
    
    /// Provides an easy mapping between UIImageOrientation and CGImagePropertyOrientation.
    var cgImageOrientation: CGImagePropertyOrientation {
        switch self {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        case .downMirrored: return .downMirrored
        }
    }
}
