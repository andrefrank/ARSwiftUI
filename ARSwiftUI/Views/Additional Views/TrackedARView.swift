//
//  TrackingARView.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 12.02.22.
//

import SwiftUI
import ARKit
import RealityKit

class TrackedARView: ARView {
    
    override init(frame frameRect: CGRect, cameraMode: ARView.CameraMode, automaticallyConfigureSession: Bool) {
        super.init(frame: frameRect, cameraMode: .ar, automaticallyConfigureSession: true)
    }
    
    @MainActor @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
}
