//
//  Dictionary + Extension.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 17.02.22.
//

import Foundation

extension Dictionary where Value: Equatable {
    /// Get the key for a specific value in a Dictionary
    /// - Parameter value: the value to be searched
    /// - Returns:The key for the value or nil if the value isn't present in the dictionary
    ///
    ///  The method works best when the values are unique. However, otherwise the first found key for the value is returned
    func key(from value: Value) -> Key? {
        return self.first(where: { $0.value == value })?.key
    }
}
