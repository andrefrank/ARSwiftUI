//
//  ARModel.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import SwiftUI
import ARKit
import RealityKit


/// The ARDataModel facilitates between the ARSession and related ARView and the ContentView
///
/// - Saving  ARWorldmaps and restoring ARWorldmaps
/// - Setup the ARConfiguration
/// - Create the virtual Sphere objects
/// - Add/Remove the virtual entities
///
class ARDataModel:ObservableObject {
    @AppStorage("shouldRloadWorldmap") var shouldReloadWorldmap:Bool=false
    
   @Published var arView:TrackedARView!
   @Published var enableAR:Bool=true
   @Published var snapshotImage:UIImage?=nil
   @Published var canSaveWorldMap:Bool = false
    
    private var wrappedSnapshotImage:UIImage?=nil{
        didSet {
            if let image = wrappedSnapshotImage {
                snapshotImage = image.resize(CGSize(width: 100,height: 200))
            } else {
                
                snapshotImage = nil
            }
        }
    }
    
   @Published var sessionState:String?
    
   var worldMapURL:URL? {
        get {
            return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
                .appendingPathComponent("worldmap")
        }
       
    }
    
    private (set) var anchoredEntities:[ARAnchor:Entity?]=[:] {
        didSet {
            print(anchoredEntities.count)
        }
    }
    
    init(){
        if enableAR {
            arView = TrackedARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        }
    }
    
    func reloadARSession(){
        self.wrappedSnapshotImage=nil
        setupARConfiguration()
    }
    
    func setupARConfiguration(using worldMap:ARWorldMap?=nil, debugOptions:ARView.DebugOptions=[.showFeaturePoints]){
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal]
        
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
        }
        
        arView.debugOptions = debugOptions
        
        arView.session.run(configuration, options: [.removeExistingAnchors,.resetTracking])
    }
    
    private func getWorldMap(url:URL) -> ARWorldMap? {
        do {
            let data = try Data(contentsOf: url)
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
        } catch {
            print("Can't load Worldmap")
            return nil
        }
    }
    
    func sphereEntity(forAnchor anchor:ARAnchor, in view:ARView) -> Entity {
        let newAnchorEntity = AnchorEntity.init(anchor: anchor)
        
        let transform = anchor.transform
        
        //Create virtual object
        let entity = SphereModel.init(transform:Transform(matrix:transform))
        newAnchorEntity.addChild(entity)
        
        view.scene.addAnchor(newAnchorEntity)
        
        return entity
    }
    
    func addAnchoredEntity(_ entity:Entity,for anchor:ARAnchor){
        self.anchoredEntities[anchor] = entity
    }
    
    func removeAchoredEntity(_ entity:Entity, for anchor:ARAnchor){
        self.anchoredEntities.removeValue(forKey: anchor)
    }
    
    func anchorsFor(_ worldMap:ARWorldMap){
        //Remove stored entities
        anchoredEntities.removeAll()
        //Remove scene anchors this will delete all virtual objects
        arView.scene.anchors.removeAll()
        
        for anchor in worldMap.anchors {
            guard anchor.name == "sphereAnchor" else {continue}
            self.anchoredEntities[anchor] = nil
        }
    }
    
    
}

extension ARDataModel {
    
    func loadARExperience(url:URL){
        
        self.wrappedSnapshotImage = nil
        
        if let worldMapURL = worldMapURL, let worldMap = getWorldMap(url: worldMapURL){
            if let snapshotAnchor = worldMap.anchors.compactMap({ $0 as? ARSnapshotAnchor
            }).first {
                self.wrappedSnapshotImage = UIImage(data: snapshotAnchor.snaphotImageData)
            } else {
                print("No snapshot available for this Experience")
            }
            
            worldMap.anchors.removeAll { $0 is ARSnapshotAnchor}
            
        
            setupARConfiguration(using: worldMap)
            
            //Reload ARAnchors from WorldMap
            anchorsFor(worldMap)
            
        }
    }
    
    func saveARExperience(withURL url:URL){
        guard let arView = self.arView else {return}
        
        self.wrappedSnapshotImage=nil
        
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let worldMap = worldMap, error == nil  else {
                return
            }
            
            Task {
                guard let snapshotAnchor = await ARSnapshotAnchor(using:arView) else {
                    fatalError("Couldn't create snapshot")
                }
                
                self.wrappedSnapshotImage = UIImage(data: snapshotAnchor.snaphotImageData)
                worldMap.anchors.append(snapshotAnchor)
                
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                    try data.write(to: url)
                    
                } catch {
                    print("Can't save worldmap \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    
    
}
