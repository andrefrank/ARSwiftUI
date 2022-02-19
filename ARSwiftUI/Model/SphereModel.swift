//
//  SphereModel.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import Foundation
import RealityKit
import ARKit


/// A predefined virtual Sphere which can be placed and moved in an AR app
class SphereModel:Entity,HasAnchoring,HasModel,HasCollision {
    
    private var size:Float=0.02
    private var defaultName = "Sphere"
    private var color = UIColor.white
    
    
    internal required init() {
        super.init()
        
        self.size = 0.02
        self.color = .white
        self.defaultName = "Sphere"
        
        setupModel()
    }
    
    //The designated initializer which can be used to override the predefined visual apsects of the object
    required init(size:Float,name:String,color:UIColor,transform:Transform) {
        super.init()
        
        self.size = size
        self.defaultName = name
        self.color = color
        
        self.transform = transform
        
        self.setupModel()
    }
    
    //Initializer with the predefined properties
    convenience init(transform:Transform){
        self.init(size:0.02, name: "Sphere", color: .white, transform: transform)
    }
    
    
    required convenience init(position:SIMD3<Float>){
        self.init()
        
        self.position = position
        
        setupModel()
        
    }
    
    //Design the virtual model according the predefined properties
    private func setupModel(){
        let mesh = MeshResource.generateSphere(radius: self.size)
        let material = SimpleMaterial(color: self.color, isMetallic: false)
        self.components[ModelComponent] = ModelComponent(mesh: mesh, materials: [material])
        /// Enable Tap and Pan gesture
        self.generateCollisionShapes(recursive: true)
    }
    
}
