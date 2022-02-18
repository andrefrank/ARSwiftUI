//
//  CGPoint + Extension.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 15.02.22.
//

import UIKit

extension CGPoint {
    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}
