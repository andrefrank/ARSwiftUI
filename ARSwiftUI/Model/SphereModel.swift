//
//  SphereModel.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import Foundation
import RealityKit
import ARKit


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
    
    required init(size:Float,name:String,color:UIColor,transform:Transform) {
        super.init()
        
        self.size = size
        self.defaultName = name
        self.color = color
        
        self.transform = transform
        
        self.setupModel()
    }
    
    convenience init(transform:Transform){
        self.init(size:0.02, name: "Sphere", color: .white, transform: transform)
    }
    
    required convenience init(position:SIMD3<Float>){
        self.init()
        
        self.position = position
        
        setupModel()
        
    }
    
    private func setupModel(){
        let mesh = MeshResource.generateSphere(radius: self.size)
        let material = SimpleMaterial(color: self.color, isMetallic: false)
        self.components[ModelComponent] = ModelComponent(mesh: mesh, materials: [material])
        
        self.generateCollisionShapes(recursive: true)
    }
    
}
