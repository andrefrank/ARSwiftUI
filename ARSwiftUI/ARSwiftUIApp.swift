//
//  ARSwiftUIApp.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import SwiftUI

@main
struct ARSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject( ARDataModel() )
        }
    }
}
