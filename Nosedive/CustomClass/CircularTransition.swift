//
//  CircularTransition.swift
//  Nosedive
//
//  Created by Victor Santos on 1/9/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

public protocol CircularTransitionDelegate: class {
    func transitionDismissCallBack(controller: CircularTransition)
}

public class CircularTransition: NSObject {
    
    weak var delegate:CircularTransitionDelegate?
    
    open var circle = UIView()
    public typealias CallBakTypeFunc = ()-> Void
    open var runMethodAfterCompletion: CallBakTypeFunc?
    
    open var startingPoint = CGPoint.zero {
        didSet {
            circle.center = startingPoint
        }
    }
    
    var circleColor = #colorLiteral(red: 1, green: 0.7931860479, blue: 0.9015205925, alpha: 1)
    
    var duration = 0.3
    
    enum CircularTransitionMode: Int {
        case present, dismiss, pop
    }
    
    var transitionMode: CircularTransitionMode = .present
    
    
}

extension CircularTransition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if transitionMode == .present {
            
            if let presentedView = transitionContext.view(forKey: .to){
                let viewCenter = presentedView.center
                let viewSize = presentedView.frame.size
                
                let effect = UIBlurEffect(style: .light)
                circle = UIVisualEffectView(effect: effect)
                circle.layer.masksToBounds = true
                circle.frame = getFrameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
       
                circle.layer.cornerRadius = circle.frame.height / 2
                circle.center = startingPoint
                //circle.backgroundColor = circleColor
                circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                containerView.addSubview(circle)
               
                presentedView.center = startingPoint
                presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                presentedView.alpha = 0
               
                containerView.addSubview(presentedView)
                
                let animation = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
                    self.circle.transform = CGAffineTransform.identity
                    presentedView.transform = CGAffineTransform.identity
                    presentedView.alpha = 0
                    presentedView.center = viewCenter
                })
                
                animation.addCompletion({ (current) in
                    UIView.animate(withDuration: self.duration, animations: {
                        presentedView.alpha = 1
                        self.circle.backgroundColor = .clear
                    })
                })
                
                animation.addCompletion({ (end) in
                    transitionContext.completeTransition(true)
                })
                
                animation.startAnimation()

            }
            
        }else{
            
            let transitionModeKey = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            
            if let returningView = transitionContext.view(forKey: transitionModeKey){
                let viewCenter = returningView.center
                let viewSize = returningView.frame.size
                
                circle.frame = getFrameForCircle(withViewCenter: viewCenter, size: viewSize, startPoint: startingPoint)
                
                circle.layer.cornerRadius = circle.frame.height / 2
                circle.center = startingPoint
               
                circle.backgroundColor = circleColor
                
                let animationBack = UIViewPropertyAnimator(duration: duration,curve: .easeOut, animations: {

                    returningView.alpha = 0

                })
                animationBack.addCompletion({ (current) in
                    let secondAnimation = UIViewPropertyAnimator(duration: self.duration, curve: UIViewAnimationCurve.easeInOut, animations: {
                        self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                        returningView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                        returningView.center = self.startingPoint
                        
                        if self.transitionMode == .pop {
                            containerView.insertSubview(returningView, belowSubview: returningView)
                            containerView.insertSubview(self.circle, belowSubview: returningView)
                        }
                    })
                    
                    secondAnimation.addCompletion({ (end) in
                        returningView.center = viewCenter
                        returningView.removeFromSuperview()
                        self.circle.removeFromSuperview()
                        
                       self.delegate?.transitionDismissCallBack(controller:self)
                        
                        transitionContext.completeTransition(true)
                    })
                    secondAnimation.startAnimation()
    
                })

 
                animationBack.startAnimation()
            }
        }
    }
    
    
    func getFrameForCircle(withViewCenter viewCenter: CGPoint, size viewSize: CGSize, startPoint: CGPoint) -> CGRect {
        let xLength = fmax(startPoint.x, viewSize.width - startPoint.x)
        let yLength = fmax(startPoint.y, viewSize.height - startPoint.y)
        
        let offSetVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offSetVector, height: offSetVector)
        
        
        return CGRect(origin: CGPoint.zero, size: size)
        
    }
}








