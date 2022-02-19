//
//  SnapshotAnchor.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 10.02.22.
//

import UIKit
import ARKit
import RealityKit

/// Custom Anchor which creates an snapshot of the saved World map
class ARSnapshotAnchor: ARAnchor {
    ///Archived data object from the snapshot
    let snaphotImageData:Data
    
    //MARK: - Custom Initialisation
    
    /// Create snapshot from specified ARView
    ///
    /// Due to the current API to fetch a snapshot from ARView which uses a completion handler,
    /// this initializer is used in an  asynchrounous context only.
    /// This helps to keep the code sequentially and clean with a fully initialized object
    @MainActor convenience init?(using captureView:ARView) async {
        var imageData:Data?=nil
        
        //Create asynchrounous task which promises to return the data of an snapshot image
        //or nil
        let imageSnapshotTask:Task<Data?,Never> = Task {
            
            let snaphotImage = await withCheckedContinuation { continuation in
                captureView.snapshot(saveToHDR: false) { image in
                    continuation.resume(returning: image)
                }
            }
            
           return snaphotImage?.pngData()
        }
        
        //Await for imageData
        imageData = await imageSnapshotTask.value

        //Create the snapshot anchor
        if let imageData = imageData,let fakeTransform = captureView.session.currentFrame?.camera.transform {
            self.init(imageData: imageData, transform: fakeTransform)
        } else {
            return nil
        }
    }
    
    
    //Designated initializer
    init(imageData:Data, transform:float4x4){
        self.snaphotImageData = imageData
        super.init(name: "snapshot", transform: transform)
    }
    
    //MARK: - Default Initialisation
    
    //Required initializer from ARAnchor
    required init(anchor: ARAnchor) {
        guard let anchor = anchor as? ARSnapshotAnchor else
        {fatalError("ARSnapshotAnchor is required as parameter")}
        
        self.snaphotImageData = anchor.snaphotImageData
        super.init(anchor: anchor)
        
    }
    
    
    //MARK: - NSKeyedArchiver methods to save and restore ARSnapshotAnchor
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
