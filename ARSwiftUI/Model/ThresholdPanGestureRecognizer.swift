//
//  ThresholdGestureRecognizer.swift
//  ARSwiftUI
//
//  Created by Andre Frank on 15.02.22.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass


/// A custom UIRecognizer which combines a Tap Gesture and a Pan gesture
class ThresholdPanGestureRecognizer:UIPanGestureRecognizer {
    ///Custom gesture type
    enum GestureType:Int {
        case none
        case tap
        case pan
    }
    
    ///The treshold value before it recognize a pan gesture
    static let kcPanThreshold:CGFloat = 5
    private var magnitude:CGFloat = 0
    
    /// The current type which will provided
    private (set) var type:GestureType = .none
    
    
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
      super.touchesBegan(touches, with: event)
        //Start with initialized values
        self.magnitude = 0
        self.type = .none
        
        //Fail on multiple touches otherwise accept touch with .possible state
        _ = checkSingleTouch(touches)
    }
    
    func checkSingleTouch(_ touches:Set<UITouch>)->Bool{
        if touches.count != 1 {
            state = .failed
            return false
        } else {
            state = .possible
            self.type = .none
        }
        return true
    }
    
    
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        //Check failure/end/cancelled state
        guard state != .failed && state != .ended && state != .cancelled  else {return}
        //Again check single touch occurrence
        guard touches.count == 1 else {
            state = .failed
            return
        }
        
        // get move length of touch
        self.magnitude = self.translation(in: view).length

        // Threshold value exceeded than interpret the touch as pan gesture
        if self.magnitude > Self.kcPanThreshold {
            
            //Set pan state and gesture state to .changed
            self.type = .pan
            state = .changed
            
            ///Clear translation
           // self.setTranslation(.zero, in: view)
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
      // super.touchesEnded(touches, with: event)
        
        //Interpret gesture as tap if magnitude is smaller as the treshold value
        //and the last state indicates a pan gesture
        if self.magnitude <= Self.kcPanThreshold && self.type != .pan {
            self.type = .tap
        }
        
        //Gesture ended
        state = .ended
    }
}
