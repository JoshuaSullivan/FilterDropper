//
//  UIDevice+Model.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

extension UIDevice {
    
    /// Checks to see if the current device can really handle Metal rendering.
    /// - Note: Many of the first-generation of 64-bit processors technically can do Metal, but
    ///         they are abysmally slow at it. This method allows Metal to be used only on devices
    ///         which can experience a performance benefit from it.
    var isMetalCapable: Bool {
        if TARGET_IPHONE_SIMULATOR != 0 || TARGET_OS_SIMULATOR != 0 {
            return false
        }
        let model = hardwareModel
        switch model.idiom {
        case .phone: return model.generation >= 8
        case .pad: return model.generation >= 5
        default:
            assertionFailure("What kind of device are we on!?")
            return false
        }
    }
    
    /// An easier way to inspect the current device type.
    struct HardwareModel {
        /// The hardware family (iPhone, iPad, TV, etc.)
        let idiom: UIUserInterfaceIdiom
        
        /// The hardware generation.
        let generation: Int
        
        /// The model within that hardware generation.
        let model: Int
    }
    
    fileprivate var hardwareModelString: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    /// Provides an easy-to-inspect struct of the current hardware.
    var hardwareModel: HardwareModel {
        let model = self.hardwareModelString as NSString
        let version = model.substring(from: model.length - 3)
        let versionComponents = version.components(separatedBy: ",").flatMap({ Int($0) })
        let idiom = self.userInterfaceIdiom
        guard versionComponents.count >= 2 else {
            return HardwareModel(idiom: idiom, generation: 0, model: 0)
        }
        return HardwareModel(idiom: idiom, generation: versionComponents[0], model: versionComponents[1])
    }
}

