//
//  DeviceRotationModifier.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 18.02.22.
//

import SwiftUI

struct DeviceRotationModifier:ViewModifier {
    let action:(UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
          content
            .onAppear(perform: nil)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification, object: nil)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onOrientationChange(perform action:@escaping(UIDeviceOrientation) -> Void) -> some View{
        self.modifier(DeviceRotationModifier(action: action))
    }
}
