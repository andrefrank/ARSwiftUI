//
//  DeviceRotationModifier.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 18.02.22.
//

import SwiftUI

/// A custom View Modifiier which notifies SwiftUI Views about device orientation changes
/// using Notification Publisher
struct DeviceRotationModifier:ViewModifier {
    //Target action when orientation did change
    let action:(UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
          content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification, object: nil)) { _ in
                //Call action each time on orientation action
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    
    /// Convenience method for DeviceOrientationModifier
    /// - Parameter action: The performed action when orientation changes
    /// - Returns:No
    func onOrientationChange(perform action:@escaping(UIDeviceOrientation) -> Void) -> some View{
        self.modifier(DeviceRotationModifier(action: action))
    }
}
