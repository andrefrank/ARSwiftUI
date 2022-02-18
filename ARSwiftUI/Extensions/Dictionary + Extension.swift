//
//  Dictionary + Extension.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 17.02.22.
//

import Foundation

extension Dictionary where Value: Equatable {
    func key(from value: Value) -> Key? {
        return self.first(where: { $0.value == value })?.key
    }
}
