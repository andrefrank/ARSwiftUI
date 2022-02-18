//: [Previous](@previous)

import UIKit
import UIKit.UIGestureRecognizerSubclass
import PlaygroundSupport


class CustomViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = ThresholdPanGestureRecognizer(target: self, action: #selector(handleThresholdGesture(_:)))
        view.addGestureRecognizer(gesture)
        view.backgroundColor = .systemBrown
    }
    
    
    @objc func handleThresholdGesture(_ gesture:ThresholdPanGestureRecognizer){
        let tuple = (gesture.type,gesture.state)
        
        switch tuple {
        case (.none, .began):
            print("None")
        case (.tap, .ended):
            print("Tapped \(gesture.location(in: view))")
        case (.pan, .changed):
            print("Pan")
        default:
            break
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.setLiveView(CustomViewController())

//: [Next](@next)
