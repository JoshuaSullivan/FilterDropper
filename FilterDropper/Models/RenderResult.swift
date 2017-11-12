//
//  RenderResult.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 11/1/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

/// A simple struct to bind the URLs for the preview and full-resolution renders of a dropped image.
struct RenderResult: Codable {
    let previewURL: URL
    let fullResolutionURL: URL
}
