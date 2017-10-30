//: Playground - noun: a place where people can play

import CoreImage
import Foundation

extension String {
    func contains(substringFrom stringArray: [String], caseInsensitive: Bool = false) -> Bool {
        let str = caseInsensitive ? self.lowercased() : self
        let arr = caseInsensitive ? stringArray.map({ $0.lowercased() }) : stringArray
        let contained: Bool = arr.reduce(false) { (matchFound, testString) -> Bool in
            return matchFound || str.contains(testString)
        }
        return contained
    }
}

let allFilterNames = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
let forbiddenSubstrings = ["Transition", "Generator", "Histogram", "Cube", "Convolution", "Blend", "Compositing", "Crop", "Area", "Gradient"]
let filteredNames = allFilterNames.filter { filterName in
    return !filterName.contains(substringFrom: forbiddenSubstrings, caseInsensitive: true)
}

print("\(filteredNames.joined(separator: "\n"))")

//filteredNames.forEach {
//    filterName in
//    guard let filter = CIFilter(name: filterName) else {
//        debugPrint("ERROR: Unable to create '\(filterName)' filter.")
//        return
//    }
//    guard let localizedName = CIFilter.localizedName(forFilterName: filterName) else {
//        debugPrint("Error: The '\(filterName)' filter has no localized name.")
//        return
//    }
//    print("\(filterName) – \(localizedName)")
//}


