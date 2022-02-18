//
//  Image + Extension.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 13.02.22.
//

import SwiftUI

extension Image {
    ///  Center crops the image
    /// - Returns: The cropped image according to the given dimension
    ///
    ///   To work properly the given dimension should consider the ratio between width and height of the image
    func centerCropped() -> some View {
        return GeometryReader { proxy in
            self
            .resizable()
            .frame(width: proxy.size.width, height: proxy.size.height)
            .scaledToFill()
            .clipped()
        }
    }
}

extension UIImage {
    func resize(_ newSize:CGSize, preserveAspectRatio:Bool=true) -> UIImage {
        let widthRatio = newSize.width / self.size.width
        let heightRatio = newSize.height / self.size.height
        
        
        //Define target size for different paths'
        var targetSize:CGSize = .zero
        
        //Check preserve ratio
        if preserveAspectRatio {
            let scaleFactor = min(widthRatio, heightRatio)
            
            targetSize.width = self.size.width * scaleFactor
            targetSize.height = self.size.height * scaleFactor
        } else {
            targetSize.width = self.size.width * widthRatio
            targetSize.height = self.size.height * heightRatio
        }
        
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
}
