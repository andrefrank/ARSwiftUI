//: [Previous](@previous)

import SwiftUI
import PlaygroundSupport


PlaygroundPage.current.needsIndefiniteExecution = true

extension Image {
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


//1.The image we want to resize
let image = UIImage(named: "Image.png")
//2.The target size which will be a square
let targetSize = CGSize(width: 100, height: 100)

//3. Get ratio between old and new width/height
let widthRatio =  targetSize.width / image!.size.width
let heightRatio =  targetSize.height / image!.size.height

//4. Calculate scale factor (min value of the former ratios) to ensure we do not stretch the smaller side of the image's source rectangle
let scaleFactor = min(widthRatio, heightRatio)



//5. Calculate new imageSize
let newImageSize = CGSize(width: image!.size.width * scaleFactor, height: image!.size.height * scaleFactor)

//6. Draw scaled image
let renderer = UIGraphicsImageRenderer(size: newImageSize, format: UIGraphicsImageRendererFormat.default())
let newScaledImage = renderer.image { context in
    image!.draw(in: CGRect(origin: .zero, size: newImageSize))
}

newScaledImage


struct ContentView:View {
    typealias scaledSize = (width:CGFloat, height:CGFloat)
    //This implies that height is greater then width of the image
    @State private var imageHeight:CGFloat=50
    
    
    var scaled:scaledSize {
        var width:CGFloat
        var height:CGFloat
        
        if image!.size.width >= image!.size.height {
            width = 100
            height = 100 * image!.size.height / image!.size.width
        } else {
            height = 100
            width = 100 * image!.size.width / image!.size.height
        }
        
        return scaledSize(width:width,height:height)
    }
    
    var imageRatio:CGFloat{
        return image!.size.width / image!.size.height
    }
    
    
    var body: some View {
        
        VStack {
            Spacer()
            Image(uiImage: image!)
                .centerCroped()
               .frame(width:imageHeight*imageRatio, height:imageHeight)
            Spacer()
            //Change size of image
            Slider(value: $imageHeight, in: 1...1700) {
                Text("Crop Image size")
                    .padding()
            }.padding()
            
        }.frame(width: 400, height: 600)
    }
    
    
}

let view = UIHostingController(rootView:ContentView())
PlaygroundPage.current.setLiveView(view)


//: [Next](@next)
