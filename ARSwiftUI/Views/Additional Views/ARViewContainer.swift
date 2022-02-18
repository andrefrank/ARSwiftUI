//
//  ARContainer.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer:UIViewRepresentable {
    @EnvironmentObject var dataModel:ARDataModel
    
    func makeUIView(context: Context) -> TrackedARView {
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal]
        
        setupCoachingView()
        
        dataModel.arView.session.delegate = context.coordinator
        dataModel.setupARConfiguration(using: nil)
        
        
        return dataModel.arView
    }
    
    func setupCoachingView(){
        let coachingView = ARCoachingOverlayView(frame: .zero)
        coachingView.translatesAutoresizingMaskIntoConstraints = false
        
        self.dataModel.arView.addSubview(coachingView)
        
        coachingView.leftAnchor.constraint(equalTo: self.dataModel.arView.leftAnchor).isActive = true
        coachingView.widthAnchor.constraint(equalTo: self.dataModel.arView.widthAnchor).isActive = true
        coachingView.topAnchor.constraint(equalTo: self.dataModel.arView.topAnchor).isActive = true
        coachingView.heightAnchor.constraint(equalTo: self.dataModel.arView.heightAnchor).isActive = true
        
        
        coachingView.goal = .horizontalPlane
        coachingView.activatesAutomatically = true
        coachingView.session = dataModel.arView.session
    }
    
    func updateUIView(_ uiView: TrackedARView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    
    class Coordinator:NSObject {
        let parent:ARViewContainer
        
        var trackedObject:Entity?=nil
        var currentTrackingPosition:CGPoint?=nil
        var trackedRaycast:ARTrackedRaycast?=nil
        private let updateQueue = DispatchQueue(label: "com.serial.updateQueue")
        
        var currentWorldMapStatus:ARFrame.WorldMappingStatus = .notAvailable
        
        init(parent:ARViewContainer){
            self.parent = parent
            super.init()
            
            setupGesture()
        }
        
        func setupGesture(){
            
            let panGesture = ThresholdPanGestureRecognizer(target: self, action: #selector(handleThresholdGesture(_:)))
            parent.dataModel.arView.addGestureRecognizer(panGesture)
            
        }
    }
}



extension ARViewContainer.Coordinator {
    
    fileprivate func virtualObjectPlane(_ arView:ARView, _ planeType:ARRaycastQuery.TargetAlignment = .horizontal,_ location:CGPoint) -> ARRaycastResult? {
        
        //4. Search for Horizontal planes in the real world at the tapped location
        guard let raycastQuery = arView.makeRaycastQuery(from: location, allowing: ARRaycastQuery.Target.existingPlaneInfinite, alignment: planeType) else {
                print("RaycastQuery not possible right now maybe tracking limited")
            return nil}
        
        guard let raycastResult = arView.session.raycast(raycastQuery).first else {
                print("No plane in the real world at tapped location found")
            return nil
        }
        
        return raycastResult
    }
    
    
    fileprivate func updateTrackingPosition(object:Entity, gesture:UIPanGestureRecognizer) -> CGPoint? {
        guard let arView = self.parent.dataModel.arView else {return nil}
        
        //get relative movement of touch
        let translation = gesture.translation(in:arView )
        //Convert position of virtual object in real world to CGPoint in ARView
        let objectPosition = arView.project(object.position)
        
        // Use last known CGPoint position or if present the object position
        guard let currentPosition = currentTrackingPosition ?? objectPosition else {return nil}
        
        //Calculate new position according to the touch movement
       let newPosition = CGPoint(x: currentPosition.x+translation.x, y: currentPosition.y+translation.y)
       
        currentTrackingPosition = newPosition
       
        return newPosition
    }
    
    //Used when virtual object will be moved
    fileprivate func raycast3DAndUpdateObjectPosition(_ object:Entity?, query:ARRaycastQuery){
        guard let arView = self.parent.dataModel.arView else {return}
        
        let results = arView.session.raycast(query)

        guard let result = results.first else {return}
        if let trackedObject = object,query.targetAlignment == .horizontal {
            let transform = Transform(matrix: result.worldTransform)
            trackedObject.position = transform.translation
            
            let previousObjectOrientation = trackedObject.orientation
            let currentObjectOrientation = transform.rotation
           // trackedObject.orientation = currentObjectOrientation
            trackedObject.orientation = simd_slerp(previousObjectOrientation, currentObjectOrientation, 0.1)
        } else if let trackedObject = object {
            trackedObject.transform = Transform(matrix: result.worldTransform)
        }
    }
    
    //Used when virtual object will set down
    fileprivate func raycast3DAndPlaceObject(_ object:Entity?, from query:ARRaycastQuery) -> ARTrackedRaycast?{
        guard let arView = self.parent.dataModel.arView,let object = object else {
            return nil
        }
        
        
        return arView.session.trackedRaycast(query) {  results in
            guard let result = results.first else {
                fatalError("Unexpected case: The raycast result should return at least one result")
            }
            
            print("Active tracked raycast detected:\(result)")
            
            object.transform = Transform(matrix: result.worldTransform)
            
            guard let anchor = self.parent.dataModel.anchoredEntities.key(from: object) else {
                fatalError("Each virtual object should have an ARAnchor")
            }
            
            self.updateQueue.async {
                self.parent.dataModel.removeAchoredEntity(object, for: anchor)
                
                arView.session.remove(anchor: anchor)
               
                let newAnchor = ARAnchor(name: "sphereAnchor", transform: result.worldTransform)
                arView.session.add(anchor: newAnchor)
            }
        }
    }
    
    fileprivate func stopRaycastTracking(){
        self.currentTrackingPosition = nil
        self.trackedRaycast?.stopTracking()
        self.trackedRaycast=nil
        self.trackedObject=nil
        
    }
}


extension ARViewContainer.Coordinator : ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        guard let arView = self.parent.dataModel.arView else {return}
        
        //Create Virtual objects when anchors with named 'sphereAnchor'
        for anchor in anchors {
            guard anchor.name == "sphereAnchor" else {continue}
            //Don't add virtual object multiple time for this anchor
            guard !self.parent.dataModel.anchoredEntities.keys.contains(anchor) else {continue}
            
            let entity = self.parent.dataModel.sphereEntity(forAnchor: anchor, in: arView)
            self.parent.dataModel.addAnchoredEntity(entity, for: anchor)
        }
    }
    
    
    @MainActor func setSessionState(_ text:String){
        parent.dataModel.sessionState = text
        
        if currentWorldMapStatus == .mapped {
            self.parent.dataModel.canSaveWorldMap = true
            
        } else {
            self.parent.dataModel.canSaveWorldMap = false
        }
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        if frame.worldMappingStatus != currentWorldMapStatus {
               currentWorldMapStatus = frame.worldMappingStatus
            
            Task {
                var statusText=""
                
                switch frame.worldMappingStatus {
                case .extending:
                    statusText = "World map: Still accessing environment"
                case .limited:
                    statusText = "World map: Limited access"
                case .mapped:
                    statusText = "Found World map"
                default:
                    break
                }
                
               await setSessionState(statusText)
                
            }
            
        }
    }
    
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var sessionStateText:String=""

        switch camera.trackingState {
        case .notAvailable:
            sessionStateText = "Tracking not available"
        case .limited(let reason):
            switch reason {
            case .initializing:
              sessionStateText =  "Limited Tracking due to initializeing"
            case .excessiveMotion:
               sessionStateText =  "Limited Tracking due to exzessive motion"
            case .insufficientFeatures:
                sessionStateText = "Limited Tracking due to insufficent feature points"
            case .relocalizing:
                sessionStateText = "Limited Tracking due to relocalizing - Reload again"
            @unknown default:
                fatalError("Unexpected reason")
            }
        case .normal:
            sessionStateText = "Tracking normal"
           // self.parent.dataModel.worldMapIsReload = false
        }
        
        Task { [weak self, sessionStateText] in
            await self?.setSessionState(sessionStateText)
        }
    }
    
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}

extension ARViewContainer.Coordinator {
    
    @objc func handleThresholdGesture(_ gesture:ThresholdPanGestureRecognizer){
        switch  gesture.type{
        case .tap:
            handleTap(gesture)
        case .pan:
            handlePan(gesture)
        case .none:
            print("Unexpected gesture path")
        }
    }
    
    
    func handleTap(_ gesture:ThresholdPanGestureRecognizer){
        
        //1. Fetch arView object from model
        guard let arView = self.parent.dataModel.arView else {
            fatalError("ARView not present - Unexpected error")
        }
        
    
        //2. Get tapped location point from ARView
        let location = gesture.location(in: arView)
        
       
        guard trackedObject == nil else {
            return
        }

        //3. Check if entity at the given point already exists then do nothing right now
        if let entity = arView.entity(at: location) {
            trackedObject = entity
            return
        }
        
       //4. Get intersection of ray and found horizontal plane if any available
        guard let raycastResult = virtualObjectPlane(arView, .horizontal, location) else {return}
        
        
        //5. Get real world transform to place virtual object into real world at given point
        let transform = raycastResult.worldTransform
       
        //Create session anchor - this will call didAddAnchor in the session delegate
        //and create the object
        let sessionAnchor = ARAnchor(name: "sphereAnchor", transform:transform)
        arView.session.add(anchor: sessionAnchor)
        
    }
    
    
    func handlePan(_ gesture:ThresholdPanGestureRecognizer){
      
        //1. Fetch arView object from model
        guard let arView = self.parent.dataModel.arView else {
            fatalError("ARView not present - Unexpected error")
        }
        
        let location = gesture.location(in:arView)
        
        switch gesture.state {
        case .began:
            
            //3. Check if entity at the given point already exists then do nothing right now
            if let entity = arView.entity(at: location) {
                trackedObject = entity
            }

        case .changed:
            if let trackedObject = self.trackedObject {
            if let newPoint = updateTrackingPosition(object: trackedObject, gesture: gesture) {
                if let query = self.parent.dataModel.arView.makeRaycastQuery(from: newPoint, allowing: .existingPlaneInfinite, alignment: .horizontal){
                    
                    raycast3DAndUpdateObjectPosition(trackedObject, query: query)
                    
                    }
                }
            }
            
            //Reset translation
            gesture.setTranslation(.zero, in: self.parent.dataModel.arView)
        case .ended:
            if let trackedObject = self.trackedObject {
            
                // Update the object by using a one-time position request.
                
              // if let query = arView.makeRaycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal) {
                    
                 //   trackedRaycast = self.raycast3DAndPlaceObject(trackedObject, from: query)
                
             //   } else {
                    
                    guard let anchor = self.parent.dataModel.anchoredEntities.key(from: trackedObject) else {
                        fatalError("Each virtual object should have an ARAnchor")
                    }
                    self.parent.dataModel.removeAchoredEntity(trackedObject, for: anchor)
                    
                    arView.session.remove(anchor: anchor)
                    
                    let transform = trackedObject.transformMatrix(relativeTo: nil)
                    let newAnchor = ARAnchor(name: "sphereAnchor", transform: transform)
                    
                    self.parent.dataModel.removeAchoredEntity(trackedObject, for: anchor)
                    arView.session.add(anchor: newAnchor)
                    
               // }
            }
            
            fallthrough
        default:
           stopRaycastTracking()
        }
        
    }
}
