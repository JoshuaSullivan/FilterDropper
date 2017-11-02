//
//  UIDevice+Model.swift
//  FilterDropper
//
//  Created by Joshua Sullivan on 10/30/17.
//  Copyright © 2017 Joshua Sullivan. All rights reserved.
//

import UIKit

extension UIDevice {
    
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
    
    struct HardwareModel {
        let idiom: UIUserInterfaceIdiom
        let generation: Int
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

