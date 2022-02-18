//
//  ContentView.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import SwiftUI
import RealityKit
import ARKit


struct ContentView: View {
    @EnvironmentObject var dataModel:ARDataModel
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                if let sessionState = self.dataModel.sessionState {
                   Text(sessionState)
                }
                
                if dataModel.enableAR {
                    ZStack(alignment: .leading) {
                        ARViewContainer()
                            .edgesIgnoringSafeArea(.all)
                        
                    if let image = dataModel.snapshotImage {
                            Image(uiImage: image)
                            .border(Color.green,width: 1)
                        }
                    
                   
                    }
                } else {
                    Spacer()
                }
    
            }
            .navigationTitle("ARView")
            .navigationBarTitleDisplayMode(dataModel.enableAR ? .inline : .automatic)
            .toolbar(content: {
                Button {
                  //  withAnimation(.easeInOut(duration: 2)) {
                    self.dataModel.enableAR.toggle()
                  //  }
                    
                } label: {
                    Text(dataModel.enableAR ? "Hide" : "Show")
                }

            })
            .toolbar(show:dataModel.enableAR) {
                ARToolBar(enableSaveAction: $dataModel.canSaveWorldMap, loadAction: {
                    if let worldMapURL = dataModel.worldMapURL {
                        dataModel.loadARExperience(url: worldMapURL)
                    }
                }, reloadAction: {
                    self.dataModel.reloadARSession()
                }, saveAction:{
                    //Save session with world map
                    if let worldMapURL = dataModel.worldMapURL {
                        dataModel.saveARExperience(withURL: worldMapURL)
                    }
                })
           }
            
        }
        .navigationViewStyle(.stack)
        .onOrientationChange { orientation in
            if let worldMapURL = dataModel.worldMapURL {
                dataModel.loadARExperience(url: worldMapURL)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ARDataModel())
    }
}
