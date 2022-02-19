//
//  ARToolBar.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import SwiftUI

struct ARToolBar:ToolbarContent {
    @Binding var enableSaveAction:Bool
    
    let loadAction:() -> Void
    let reloadAction:() -> Void
    let saveAction:() -> Void
    let goToARSettings:() -> Void
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement:.bottomBar) {
                Button {
                    // Load World map
                    loadAction()
                } label: {
                    VStack {
                        Image(systemName: "arrow.down.circle")
                        Text("Load")
                    }
                }.foregroundColor(Color(uiColor: .label))

                Spacer()
                Button {
                    // Reload AR Session
                    reloadAction()
                } label: {
                    VStack {
                        Image(systemName: "goforward")
                        Text("Reload")
                    }
                }.foregroundColor(Color(uiColor: .label))

                Spacer()
                Button {
                    // Save World map
                    saveAction()
                } label: {
                    VStack {
                        Image(systemName: "rotate.3d")
                            
                        Text("Save")
                    }
                    .foregroundColor(enableSaveAction ? .white : .gray)
                }.foregroundColor(Color(uiColor: .label))
                .disabled(!enableSaveAction)
            
            
            Spacer()
            Button {
              //Show/Edit Settings
              goToARSettings()
            } label: {
                VStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            }.foregroundColor(Color(uiColor: .label))
            
        }
    }
}
