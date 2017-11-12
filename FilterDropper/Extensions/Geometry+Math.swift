//
//  UIRect+Math.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/2/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

/// Multiplies the size of the rect by the scalar (origin is unaffected).
func * (rect: CGRect, scalar:CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width * scalar, height: rect.height * scalar)
}

/// Multiplies the width and height by the scalar.
func * (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

/// Divides the width and height by the scalar.
func / (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width / scalar, height: size.height / scalar)
}
