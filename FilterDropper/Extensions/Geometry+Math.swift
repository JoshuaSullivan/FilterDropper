//
//  UIRect+Math.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/2/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

func * (rect: CGRect, scalar:CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width * scalar, height: rect.height * scalar)
}

func * (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

func / (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width / scalar, height: size.height / scalar)
}
