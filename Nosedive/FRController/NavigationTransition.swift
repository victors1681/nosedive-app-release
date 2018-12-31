//
//  NavigationTransition.swift
//  Nosedive
//
//  Created by Victor Santos on 2/20/18.
//  Copyright © 2018 itsoluclick. All rights reserved.
//

import UIKit

class NavigationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval = 0.0
    var isPresenting: Bool
    var originFrame: CGRect
    var image: UIImage
    
    init(duration: TimeInterval, isPresenting: Bool, originFrame: CGRect, image: UIImage) {
        
        self.duration = duration
        self.isPresenting = isPresenting
        self.originFrame = originFrame
        self.image = image
        
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        
        self.isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let detailView = isPresenting ? toView : fromView
        
//        guard let artwork = detailView.viewWithTag(CustomAnimatorTag) as? UIImageView else { return }
//        artwork.image = image
//        artwork.alpha = 0
        
//        let transitionImageView = UIImageView(frame: isPresenting ? originFrame : artwork.frame)
//        transitionImageView.image = image
//
//        container.addSubview(transitionImageView)
        
        toView.frame = isPresenting ?  CGRect(x: fromView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height) : toView.frame
        toView.alpha = isPresenting ? 0 : 1
        toView.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, animations: {
           // transitionImageView.frame = self.isPresenting ? artwork.frame : self.originFrame
            detailView.frame = self.isPresenting ? fromView.frame : CGRect(x: toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
            detailView.alpha = self.isPresenting ? 1 : 0
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
          //  transitionImageView.removeFromSuperview()
           // artwork.alpha = 1
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
}
