//
//  View + Extension.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 09.02.22.
//

import SwiftUI


extension View {
    /// Creates a hidable/showable toolbar with the Content
    /// - Returns: The view with the toolbar items attached at the bottom
    ///
    ///  The toolbar works in NavigationViews only. To show/hide the toolbar toggle the 'show' method parameter value.
    func toolbar<Content>(show:Bool, content: () -> Content) -> some View where Content:ToolbarContent {
        Group {
        if show {
            self
                .toolbar(content: content)
                .animation(.easeInOut, value: show)
                
        } else {
            self
                .animation(.easeInOut, value: show)
        }
        }
    }
}
