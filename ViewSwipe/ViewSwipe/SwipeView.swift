//
//  SwipeView.swift
//  ViewSwipe
//
//  Created by Lucas Louca on 10/06/15.
//  Copyright (c) 2015 Lucas Louca. All rights reserved.
//

import UIKit

class SwipeView: UIView {
    var panGestureRecognizer : UIPanGestureRecognizer!
    var originalPoint:CGPoint!
    var lastYDistance: CGFloat!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.setup()
    }
    
    func setup() {
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("swiped:"))
        self.addGestureRecognizer(panGestureRecognizer)
        
        self.layer.shadowOffset = CGSizeMake(0.0, 5.00)
        self.layer.shadowRadius = 5
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    /**
    Show/hide shadow.
    
    - parameter show: Bool that if set to true enables the shadow on the view, else disables it.
    */
    func shouldShowShadow(show:Bool){
        if (show) {
            self.layer.shadowOpacity = 0.5
        } else {
            self.layer.shadowOpacity = 0.0
        }
    }
    
    /**
    Called on pan gesture
    */
    func swiped(gestureRecognizer: UIPanGestureRecognizer) {
        let yDistance:CGFloat = gestureRecognizer.translationInView(self).y
        let rotationStrength:CGFloat = min(abs(yDistance/360),1)
        
        switch(gestureRecognizer.state){
        case UIGestureRecognizerState.Began:
            self.originalPoint = self.center
            shouldShowShadow(true)
        case UIGestureRecognizerState.Changed:
            if (yDistance < 0 ) {
                let rotationAngel:CGFloat = (70.0*CGFloat(M_PI)*CGFloat(rotationStrength) / 180.00)
                var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = 1.0 / -500
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, rotationAngel, CGFloat(1.0), CGFloat(0.0), CGFloat(0.0))
                if yDistance > -CGFloat.max {
                    lastYDistance = yDistance
                    rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, yDistance, 0)
                } else {
                    rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, lastYDistance, 0)
                }
                self.layer.transform = rotationAndPerspectiveTransform
            }
        case UIGestureRecognizerState.Ended:
            if rotationStrength == 1 {
                removeViewFromParentWithAnimation()
            } else {
                self.resetViewPositionAndTransformations()
            }
        default:
            break
        }
    }
    
    /**
    Move view back to its original position
    */
    func resetViewPositionAndTransformations(){
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
            self.center = self.originalPoint
            self.transform = CGAffineTransformMakeRotation(0)
            self.shouldShowShadow(false)
            }, completion: {success in })
    }
    
    /**
    Move view to the horizon and eventually remove it from its superview
    */
    func removeViewFromParentWithAnimation() {
        var animations:(()->Void)!
        animations = {
            let rotationAngel:CGFloat = (70.0*CGFloat(M_PI) / 180.00)
            var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
            rotationAndPerspectiveTransform.m34 = 1.0 / -500
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, rotationAngel, CGFloat(1.0), CGFloat(0.0), CGFloat(0.0))
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0, -10000, 0)
            self.layer.transform = rotationAndPerspectiveTransform
        }
        
        UIView.animateWithDuration(0.5, animations: animations , completion: {success in self.removeFromSuperview()})
    }
    
}
