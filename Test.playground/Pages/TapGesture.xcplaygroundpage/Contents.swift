//: [Previous](@previous)

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


class MyView:UIView {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView(){
        self.backgroundColor = .blue
    }
}


class CustomViewController : UIViewController {
    var myView:MyView = {
        return MyView(frame: .zero)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        myView.addGestureRecognizer(gesture)
        
        self.view.addSubview(myView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.myView.frame = view.frame
    }
    
    @objc func handleTap(_ gesture:UIPanGestureRecognizer){
        let location = gesture.location(in: self.myView)
        
        switch gesture.state {
        case .began:
            print("Touches began at location:\(location)")
        case .changed:
            print("Touches changed at location:\(location)")
        case .ended:
            print("Touches ended at location:\(location)")
        case .cancelled:
            print("Touches canceled at location:\(location)")
        default:
            break
        }
    }
}


PlaygroundPage.current.setLiveView(CustomViewController())

//: [Next](@next)
