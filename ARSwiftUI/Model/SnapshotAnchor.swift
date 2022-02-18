//
//  SnapshotAnchor.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 10.02.22.
//

import UIKit
import ARKit
import RealityKit

class ARSnapshotAnchor: ARAnchor {
    let snaphotImageData:Data
    
    
    
    @MainActor convenience init?(using captureView:ARView) async {
        var imageData:Data?=nil
        
        let imageSnapshotTask:Task<Data?,Never> = Task {
            
            let snaphotImage = await withCheckedContinuation { continuation in
                captureView.snapshot(saveToHDR: false) { image in
                    continuation.resume(returning: image)
                }
            }
            
           return snaphotImage?.pngData()
        }
        
        imageData = await imageSnapshotTask.value

        if let imageData = imageData,let fakeTransform = captureView.session.currentFrame?.camera.transform {
            self.init(imageData: imageData, transform: fakeTransform)
        } else {
            return nil
        }
    }
    
    init(imageData:Data, transform:float4x4){
        self.snaphotImageData = imageData
        super.init(name: "snapshot", transform: transform)
    }
    
    
    
    required init(anchor: ARAnchor) {
        guard let anchor = anchor as? ARSnapshotAnchor else
        {fatalError("ARSnapshotAnchor is required as parameter")}
        
        self.snaphotImageData = anchor.snaphotImageData
        super.init(anchor: anchor)
        
    }
    
    required init?(coder: NSCoder) {
        guard let snapshot =  coder.decodeObject(forKey: "snapshot") as? Data else {
           return nil
        }
        
        self.snaphotImageData = snapshot
        
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        
        coder.encode(self.snaphotImageData,forKey: "snapshot")
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}
